defmodule Yamel do
  @moduledoc """
  Documentation for `Yamel`.
  """

  @type t :: map() | list()
  @type yaml :: binary()

  @spec decode!(yaml(), atoms: boolean()) :: Yamel.t()
  def decode!(yaml_string, options \\ []) do
    atoms = Keyword.get(options, :atoms)

    yaml_string
    |> YamlElixir.read_from_string!()
    |> maybe_atom(atoms)
  end

  @spec decode(yaml(), atoms: boolean()) :: {:ok, Yamel.t()} | {:error, reason :: binary()}
  def decode(yaml_string, options \\ []) do
    atoms = Keyword.get(options, :atoms)

    yaml_string
    |> YamlElixir.read_from_string()
    |> maybe_atom(atoms)
  end

  @spec encode!(Yamel.t()) :: yaml()
  def encode!(map_or_list)

  def encode!(map_or_list)
      when is_map(map_or_list) or is_list(map_or_list),
      do: to_yaml!(map_or_list)

  def encode!(value),
    do: raise(ArgumentError, "Unsupported value: #{inspect(value)}")

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

  defp maybe_atom({:ok, yaml}, atoms), do: {:ok, maybe_atom(yaml, atoms)}

  defp maybe_atom({:error, _reason} = error, _atoms), do: error

  defp maybe_atom(map, true) when is_map(map) do
    for {key, value} <- map, into: %{} do
      cond do
        is_atom(key) -> {key, maybe_atom(value, true)}
        true -> {String.to_atom(key), maybe_atom(value, true)}
      end
    end
  end

  defp maybe_atom(list, true) when is_list(list) do
    for value <- list, into: [] do
      cond do
        is_map(value) -> maybe_atom(value, true)
        true -> value
      end
    end
  end

  defp maybe_atom(yaml, _atoms), do: yaml

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
