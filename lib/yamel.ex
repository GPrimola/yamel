defmodule Yamel do
  @moduledoc """
  Documentation for `Yamel`.
  """

  @type t :: map() | list()
  @type yaml :: binary()

  @spec decode!(yaml()) :: Yamel.t()
  defdelegate decode!(yaml_string), to: YamlElixir, as: :read_from_string!

  @spec decode(yaml()) :: {:ok, Yamel.t()} | {:error, reason :: binary()}
  defdelegate decode(yaml_string), to: YamlElixir, as: :read_from_string

  @doc ~S"""
  Encodes a YAML term directly into a string, throwing an exception if the term
  can not be encoded.

  ## Examples

      iex> Yamel.encode!(["foo", "bar", "baz"])
      "- foo\n- bar\n- baz\n\n"

  """
  @spec encode!(Yamel.t()) :: yaml()
  def encode!(map_or_list)

  def encode!(map_or_list)
      when is_map(map_or_list) or is_list(map_or_list),
      do: to_yaml!(map_or_list)

  def encode!(value),
    do: raise(ArgumentError, "Unsupported value: #{inspect(value)}")

  @doc ~S"""
  Encodes a YAML term. Returns `{:ok, yaml()}` where the second term is the
  encoded YAML term. Otherwise, returns `{:error, reason}` with `reason`
  being a string stating the error reason.

  ## Examples

      iex> Yamel.encode(["foo", "bar", "baz"])
      {:ok, "- foo\n- bar\n- baz\n\n"}

  """
  @spec encode(Yamel.t()) :: {:ok, yaml()} | {:error, reason :: binary()}
  def encode(map_or_list)

  def encode(map_or_list) when is_map(map_or_list) or is_list(map_or_list),
    do: {:ok, to_yaml!(map_or_list)}

  def encode(value), do: {:error, "Unsupported value: #{inspect(value)}"}

  @spec to_yaml!(Yamel.t()) :: yaml()
  defp to_yaml!(map_or_list) do
    map_or_list
    |> serialize()
    |> Enum.join()
    |> Kernel.<>("\n")
  end

  defp serialize(value), do: serialize(value, "")

  defp serialize({key, value}, indentation)
       when is_map(value) or is_list(value),
       do: "#{indentation}#{key}:\n#{serialize(value, "#{indentation}  ")}"

  defp serialize({key, value}, indentation),
    do: "#{indentation}#{key}: #{serialize(value, indentation)}"

  defp serialize(bitstring, _indentation)
       when is_bitstring(bitstring),
       do: "#{bitstring}\n"
  defp serialize(number, _indentation)
       when is_number(number),
       do: "#{number}\n"
  defp serialize(atom, _indentation)
       when is_atom(atom),
       do: "#{atom}\n"

  defp serialize(map, indentation)
       when is_map(map),
       do: Enum.map(map, &serialize(&1, indentation))

  defp serialize(list_or_tuple, indentation)
       when is_list(list_or_tuple) do
    Enum.map(list_or_tuple, fn
      value when is_list(value) or is_map(value) or is_tuple(value) ->
        "#{indentation}-\n#{serialize(value, "#{indentation}  ")}"

      value ->
        "#{indentation}- #{serialize(value)}"
    end)
  end
end
