defmodule Yamel do
  @moduledoc """
  Defines functions to work with YAML in Elixir.
  """

  @type t :: map() | list()
  @type yaml :: String.t()
  @type keys :: :atom | :string | :atoms | :strings
  @type quotable_types :: :atom | :string | :number | :boolean
  @type decode_opts :: [keys: keys] | []
  @type encode_opts :: [quote: quotable_types] | []
  @type parse_error :: YamlElixir.ParsingError.t()

  @doc ~S"""
  Decodes a YAML string to a map or list, throws if fails.

  Throws `parse_error()` exception if given YAML cannot be parsed.

  ## Options
    * `:keys` - indicates the type for the map's keys. Default: `:string`

  ## Examples

      iex> Yamel.decode!("
      ...>     name: Jane Doe
      ...>     job: Developer
      ...>     skill: Elite
      ...>     employed: True")
      %{"employed" => true, "job" => "Developer", "name" => "Jane Doe", "skill" => "Elite"}

    With option `keys: :atom`

      iex> Yamel.decode!("
      ...>     name: Jane Doe
      ...>     job: Developer
      ...>     skill: Elite
      ...>     employed: True", keys: :atom)
      %{employed: true, job: "Developer", name: "Jane Doe", skill: "Elite"}
  """
  @spec decode!(yaml(), decode_opts()) :: Yamel.t()
  def decode!(yaml_string, options \\ []) do
    keys = Keyword.get(options, :keys, :strings)

    yaml_string
    |> YamlElixir.read_from_string!()
    |> maybe_atom(keys)
  end

  @doc ~S"""
  Decodes a YAML string to a map or list.

  Returns `{:ok, Yamel.t()}` or `{:error, reason}`, where reason is `parse_error()`

  ## Options
    * `:keys` - indicates the type for the map's keys. Default: `:string`

  ## Examples

      iex> Yamel.decode(
      ...> ~s"---
      ...>    - Apple
      ...>    - Orange
      ...>    - Strawberry
      ...>    - Mango")
      {:ok, ["Apple", "Orange","Strawberry", "Mango"]}
  """
  @spec decode(yaml(), decode_opts()) :: {:ok, Yamel.t()} | {:error, parse_error()}
  def decode(yaml_string, options \\ []) do
    keys = Keyword.get(options, :keys, :string)

    case YamlElixir.read_from_string(yaml_string) do
      {:ok, yaml} ->
        {:ok, maybe_atom(yaml, keys)}

      error ->
        error
    end
  end

  @doc ~S"""
  Encodes a YAML term directly into a string, throwing an exception if the term
  can not be encoded.

  ## Options

    * `:quote` - The value types to be quoted.


  ## Examples

      iex> Yamel.encode!(["foo", "bar", "baz"])
      "- foo\n- bar\n- baz\n\n"

      iex> Yamel.encode!([:foo, "bar", 123, true], quote: [:string, :atom, :number])
      "- \"foo\"\n- \"bar\"\n- \"123\"\n- true\n\n"

      iex> Yamel.encode!([:foo, "bar", 12.3, true], quote: [:string, :boolean])
      "- foo\n- \"bar\"\n- 12.3\n- \"true\"\n\n"

  """
  @spec encode!(Yamel.t(), encode_opts()) :: yaml()
  def encode!(map_or_list, opts \\ [])

  def encode!(map_or_list, opts)
      when is_map(map_or_list) or is_list(map_or_list),
      do: to_yaml!(map_or_list, opts)

  def encode!(value, _opts),
    do: raise(ArgumentError, "Unsupported value: #{inspect(value)}")

  @doc ~S"""
  Encodes a YAML term. Returns `{:ok, yaml()}` where the second term is the
  encoded YAML term. Otherwise, returns `{:error, reason}` with `reason`
  being a string stating the error reason.

  ## Options

    * `:quote` - The value types to be quoted.


  ## Examples

      iex> Yamel.encode(["foo", "bar", "baz"])
      {:ok, "- foo\n- bar\n- baz\n\n"}

      iex> Yamel.encode([:foo, "bar", 123, true], quote: [:string, :atom, :number])
      {:ok, "- \"foo\"\n- \"bar\"\n- \"123\"\n- true\n\n"}

      iex> Yamel.encode([:foo, "bar", 12.3, true], quote: [:string, :boolean])
      {:ok, "- foo\n- \"bar\"\n- 12.3\n- \"true\"\n\n"}

  """
  @spec encode(Yamel.t(), encode_opts()) :: {:ok, yaml()} | {:error, reason :: String.t()}
  def encode(map_or_list, opts \\ [])

  def encode(map_or_list, opts) when is_map(map_or_list) or is_list(map_or_list),
    do: {:ok, to_yaml!(map_or_list, opts)}

  def encode(value, _opts), do: {:error, "Unsupported value: #{inspect(value)}"}

  defp maybe_atom({:ok, yaml}, keys), do: {:ok, maybe_atom(yaml, keys)}

  defp maybe_atom({:error, _reason} = error, _keys), do: error

  defp maybe_atom(map, keys) when is_map(map) and keys in [:atom, :atoms] do
    for {key, value} <- map, into: %{} do
      cond do
        is_atom(key) -> {key, maybe_atom(value, :atoms)}
        true -> {String.to_atom(key), maybe_atom(value, :atoms)}
      end
    end
  end

  defp maybe_atom(list, keys) when is_list(list) and keys in [:atom, :atoms] do
    for value <- list, into: [] do
      cond do
        is_map(value) -> maybe_atom(value, :atoms)
        true -> value
      end
    end
  end

  defp maybe_atom(yaml, _keys), do: yaml

  @spec to_yaml!(Yamel.t(), opts :: keyword()) :: yaml()
  defp to_yaml!(map_or_list, opts)

  defp to_yaml!(map_or_list, opts) do
    opts_map =
      opts
      |> Enum.map(fn
        opt when is_tuple(opt) -> opt
        opt -> {opt, true}
      end)
      |> Map.new()
      |> Map.update(:indentation, "", & &1)
      |> Map.update(:quote, [], & &1)

    map_or_list
    |> serialize(opts_map)
    |> Enum.join()
    |> Kernel.<>("\n")
  end

  defp serialize({key, value}, %{indentation: indentation} = opts)
       when is_map(value) or is_list(value),
       do:
         "#{indentation}#{key}:\n#{
           serialize(value, Map.put(opts, :indentation, "#{indentation}  "))
         }"

  defp serialize({key, value}, %{indentation: indentation} = opts),
    do: "#{indentation}#{key}: #{serialize(value, opts)}"

  defp serialize(bitstring, %{quote: quoted} = _opts) when is_bitstring(bitstring) do
    if Enum.member?(quoted, :string),
      do: "\"#{bitstring}\"\n",
      else: "#{bitstring}\n"
  end

  defp serialize(number, %{quote: quoted} = _opts) when is_number(number) do
    if Enum.member?(quoted, :number),
      do: "\"#{number}\"\n",
      else: "#{number}\n"
  end

  defp serialize(boolean, %{quote: quoted} = _opts) when is_boolean(boolean) do
    if Enum.member?(quoted, :boolean),
      do: "\"#{boolean}\"\n",
      else: "#{boolean}\n"
  end

  defp serialize(atom, %{quote: quoted} = _opts) when is_atom(atom) do
    if Enum.member?(quoted, :atom),
      do: "\"#{atom}\"\n",
      else: "#{atom}\n"
  end

  defp serialize(map, opts)
       when is_map(map),
       do: Enum.map(map, &serialize(&1, opts))

  defp serialize(list_or_tuple, %{indentation: indentation} = opts)
       when is_list(list_or_tuple) do
    Enum.map(list_or_tuple, fn
      value when is_list(value) or is_map(value) or is_tuple(value) ->
        "#{indentation}-\n#{serialize(value, Map.put(opts, :indentation, "#{indentation}  "))}"

      value ->
        "#{indentation}- #{serialize(value, opts)}"
    end)
  end
end
