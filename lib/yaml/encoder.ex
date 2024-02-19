defmodule Yamel.EncodeError do
  @type t :: %__MODULE__{message: String.t(), value: any}

  defexception message: nil, value: nil

  def message(%{message: nil, value: value}) do
    "unable to encode value: #{inspect(value)}"
  end

  def message(%{message: message}) do
    message
  end
end

defmodule Yamel.Encoder.Helper do
  defguard is_scalar(value)
           when is_atom(value) or
                  is_binary(value) or
                  is_bitstring(value) or
                  is_boolean(value) or
                  is_nil(value) or
                  is_number(value)

  # https://yaml.org/spec/1.2.2/#61-indentation-spaces
  @spec calculate_indentation(Yamel.Encoder.opts()) :: String.t()
  def calculate_indentation(%{node_level: level, indent_size: indent_size}),
    do: String.pad_trailing("", level * indent_size, " ")

  # when 'value' is a complex type
  @spec serialize({key :: any(), value :: any()}, Yamel.Encoder.opts()) :: String.t()
  def serialize({key, value}, opts) when is_map(value) or is_list(value) do
    indent = calculate_indentation(opts)
    opts = Map.update(opts, :node_level, 0, &(&1 + 1))
    "#{indent}#{key}:\n#{Yamel.Encoder.encode(value, opts)}"
  end

  # when 'value' is an scalar
  def serialize({key, value}, opts) do
    indent = calculate_indentation(opts)
    opts = Map.update(opts, :node_level, 0, &(&1 + 1))
    "#{indent}#{key}: #{Yamel.Encoder.encode(value, opts)}"
  end
end

defmodule Yamel.Encode do
  @moduledoc false

  alias Yamel.EncodeError

  defmacro __using__(_) do
    quote do
      alias Yamel.EncodeError
      alias String.Chars

      @compile {:inline, encode_name: 1}

      # Fast path encoding string keys
      defp encode_name(value) when is_binary(value) do
        value
      end

      defp encode_name(value) do
        case Chars.impl_for(value) do
          nil ->
            raise EncodeError,
              value: value,
              message: "expected a String.Chars encodable value, got: #{inspect(value)}"

          impl ->
            impl.to_string(value)
        end
      end
    end
  end
end

defprotocol Yamel.Encoder do
  @fallback_to_any true

  @type quotable_type ::
          :atom
          | :string
          | :number
          | :integer
          | :float
          | :boolean
          # quotes all scalars
          | true

  @typedoc """
  `:node_level`: along with `:indent_size` calculates the indentation. 0 - root level; 1 - 2 spaces indent; 3 - 4 spaces indent
  `:indent_size`: multiplier for indentation. Default 2
  `:quote`: which scalar types to be surrounded by quotes
  `:quote_type`: use single quotes (' - :single) or double quotes (" - double)
  `:empty_value`: how to deal with empty ("") values: leave blank (:blank) or use quotes (:quoted - default)
  """
  @type opts :: %{
          required(:node_level) => non_neg_integer(),
          required(:indent_size) => pos_integer(),
          optional(:quote) => quotable_type()
        }

  @spec encode(t, opts) :: iodata
  def encode(value, opts \\ %{node_level: 0, indent_size: 2})
end

defimpl Yamel.Encoder, for: Atom do
  def encode(nil, opts) do
    types = opts[:quote] || []

    if true in types or :atom in types,
      do: "\"null\"\n",
      else: "null\n"
  end

  def encode(false, opts) do
    types = opts[:quote] || []

    if true in types or :boolean in types,
      do: "\"false\"\n",
      else: "false\n"
  end

  def encode(true, opts) do
    types = opts[:quote] || []

    if true in types or :boolean in types,
      do: "\"true\"\n",
      else: "true\n"
  end

  def encode(value, opts) do
    types = opts[:quote] || []

    if true in types or :atom in types,
      do: "\"#{value}\"\n",
      else: "#{value}\n"
  end
end

defimpl Yamel.Encoder, for: BitString do
  use Bitwise

  def encode("", %{empty: :blank}), do: ""
  def encode("", %{quote_type: :single}), do: "''"
  def encode("", _opts), do: "\"\""

  def encode(bitstring, opts) do
    types = opts[:quote] || []

    if true in types or :string in types,
      do: "\"#{bitstring}\"\n",
      else: "#{bitstring}\n"
  end
end

defimpl Yamel.Encoder, for: Integer do
  def encode(integer, opts) do
    types = opts[:quote] || []

    if true in types or :number in types or :integer in types,
      do: "\"#{integer}\"\n",
      else: "#{integer}\n"
  end
end

defimpl Yamel.Encoder, for: Float do
  def encode(float, opts) do
    types = opts[:quote] || []

    if true in types or :number in types or :float in types,
      do: "\"#{float}\"\n",
      else: "#{float}\n"
  end
end

defimpl Yamel.Encoder, for: Map do
  import Yamel.Encoder.Helper

  def encode(map, opts),
    do:
      map
      |> Enum.map(&serialize(&1, opts))
      |> Enum.join()
end

defimpl Yamel.Encoder, for: [List, Tuple] do
  import Yamel.Encoder.Helper

  def encode(tuple, opts) when is_tuple(tuple),
    do:
      tuple
      |> Tuple.to_list()
      |> encode(opts)

  def encode(list, opts) do
    indent = calculate_indentation(opts)
    opts = Map.update(opts, :node_level, 0, &(&1 + 1))

    list
    |> Enum.map(fn
      value when is_scalar(value) ->
        "#{indent}- #{Yamel.Encoder.encode(value, opts)}"

      %{__struct__: strct} = value when strct in [Date, DateTime, NaiveDateTime, Time] ->
        "#{indent}- #{Yamel.Encoder.encode(value, opts)}"

      value when is_list(value) or is_map(value) ->
        "#{indent}-\n#{Yamel.Encoder.encode(value, opts)}"

      {_key, _value} = value ->
        "#{indent}-\n#{serialize(value, opts)}"

      value when is_tuple(value) ->
        "#{indent}-\n#{Yamel.Encoder.encode(Tuple.to_list(value), opts)}"
    end)
    |> Enum.join()
  end
end

defimpl Yamel.Encoder, for: [Range, Stream, MapSet, HashSet, Date.Range] do
  def encode(collection, opts) do
    Yamel.Encoder.List.encode(collection, opts)
  end
end

defimpl Yamel.Encoder, for: [Date, DateTime, NaiveDateTime, Time] do
  def encode(value, opts) do
    Yamel.Encoder.encode(@for.to_iso8601(value), opts)
  end
end

defimpl Yamel.Encoder, for: URI do
  def encode(value, opts) do
    Yamel.Encoder.encode(@for.to_string(value), opts)
  end
end

if Code.ensure_loaded?(Decimal) do
  defimpl Yamel.Encoder, for: Decimal do
    def encode(value, _opts) do
      Decimal.to_string(value)
    end
  end
end

defimpl Yamel.Encoder, for: Any do
  alias Yamel.EncodeError

  defmacro __deriving__(module, struct, opts) do
    deriving(module, struct, opts)
  end

  def deriving(module, _struct, opts) do
    only = opts[:only]
    except = opts[:except]

    extractor =
      cond do
        only ->
          quote(do: Map.take(struct, unquote(only)))

        except ->
          except = [:__struct__ | except]
          quote(do: Map.drop(struct, unquote(except)))

        true ->
          quote(do: Map.delete(struct, :__struct__))
      end

    quote do
      defimpl Yamel.Encoder, for: unquote(module) do
        def encode(struct, opts) do
          Yamel.Encoder.Map.encode(unquote(extractor), opts)
        end
      end
    end
  end

  def encode(%{__struct__: _} = struct, opts) do
    struct
    |> Map.from_struct()
    |> Yamel.Encoder.Map.encode(opts)
  end

  def encode(value, _opts) do
    raise EncodeError, value: value
  end
end
