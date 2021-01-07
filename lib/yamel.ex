defmodule Yamel do
  @moduledoc """
  Module to work with YAML strings in Elixir.
  """

  @type t :: map() | list()
  @type yaml :: binary()
  @type keys :: :atoms | :strings
  @type decode_opt :: {:keys, keys}

  @doc ~S"""
  Decode a YAML string into it respective data type in elixir, throwing an exception if the
  string can not be encoded

  ## Examples

     iex> Yamel.decode!("
     ...>     name: Jane Doe
     ...>     job: Developer
     ...>     skill: Elite
     ...>     employed: True")
     %{"employed" => true, "job" => "Developer", "name" => "Jane Doe", "skill" => "Elite"}
  """
  @spec decode!(yaml(), [decode_opt]) :: Yamel.t()
  def decode!(yaml_string, options \\ []) do
    keys = Keyword.get(options, :keys, :strings)

    yaml_string
    |> YamlElixir.read_from_string!()
    |> maybe_atom(keys)
  end

  @doc ~S"""
  Decode a YAML string into it respective data type in elixir, returning `{:ok, Yamel.t()}`
  where the second term is the Yamel in Elixir representation. Otherwise, returns `{:error, reason}`
  where `reason` is a `YamlElixir` error module with a message inside

  ## Examples

      iex> Yamel.decode(
      ...> ~s"---
      ...>    - Apple
      ...>    - Orange
      ...>    - Strawberry
      ...>    - Mango")
      {:ok, ["Apple", "Orange","Strawberry", "Mango"]}
  """

  @spec decode(yaml(), [decode_opt]) :: {:ok, Yamel.t()} | {:error, reason :: binary()}
  def decode(yaml_string, options \\ []) do
    keys = Keyword.get(options, :keys, :strings)

    yaml_string
    |> YamlElixir.read_from_string()
    |> maybe_atom(keys)
  end

  @doc ~S"""
  Encodes a YAML term directly into a string, throwing an exception if the term
  can not be encoded.

  ## Examples

      iex> Yamel.encode!(["foo", "bar", "baz"])
      "- foo\n- bar\n- baz\n\n"

  """
  @spec encode!(Yamel.t()) :: yaml()
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

  ## Examples

      iex> Yamel.encode(["foo", "bar", "baz"])
      {:ok, "- foo\n- bar\n- baz\n\n"}

  """
  @spec encode(Yamel.t(), opts :: keyword()) :: {:ok, yaml()} | {:error, reason :: binary()}
  def encode(map_or_list, opts \\ [])

  def encode(map_or_list, opts) when is_map(map_or_list) or is_list(map_or_list),
    do: {:ok, to_yaml!(map_or_list, opts)}

  def encode(value, _opts), do: {:error, "Unsupported value: #{inspect(value)}"}

  defp maybe_atom({:ok, yaml}, keys), do: {:ok, maybe_atom(yaml, keys)}

  defp maybe_atom({:error, _reason} = error, _keys), do: error

  defp maybe_atom(map, :atoms) when is_map(map) do
    for {key, value} <- map, into: %{} do
      cond do
        is_atom(key) -> {key, maybe_atom(value, :atoms)}
        true -> {String.to_atom(key), maybe_atom(value, :atoms)}
      end
    end
  end

  defp maybe_atom(list, :atoms) when is_list(list) do
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

  defp serialize(bitstring, %{quoted: true} = _opts)
       when is_bitstring(bitstring),
       do: "\"#{bitstring}\"\n"

  defp serialize(bitstring, _opts)
       when is_bitstring(bitstring),
       do: "#{bitstring}\n"

  defp serialize(number, %{quoted: true} = _opts)
       when is_number(number),
       do: "\"#{number}\"\n"

  defp serialize(number, _opts)
       when is_number(number),
       do: "#{number}\n"

  defp serialize(atom, %{quoted: true} = _opts)
       when is_atom(atom),
       do: "\"#{atom}\"\n"

  defp serialize(atom, _opts)
       when is_atom(atom),
       do: "#{atom}\n"

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
