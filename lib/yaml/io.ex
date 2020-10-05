defmodule Yamel.IO do
  @moduledoc """
  Module to work with YAML files in Elixir.
  """

  @spec read!(file_path :: binary()) :: map() | list()
  def read!(file_path),
    do: YamlElixir.read_from_file!(file_path)

  @spec read(file_path :: binary()) :: {:ok, map() | list()} | {:error, reason :: binary()}
  def read(file_path),
    do: YamlElixir.read_from_file(file_path)

  @spec write!(yaml_string :: binary(), file_path :: binary()) :: :ok
  def write!(yaml_string, file_path) do
    YamlElixir.read_from_string!(yaml_string)
    File.write!(file_path, yaml_string)
  end

  @spec write(yaml_string :: binary(), file_path :: binary()) ::
          :ok | {:error, reason :: binary()}
  def write(yaml_string, file_path) do
    with {:ok, _} <- YamlElixir.read_from_string(yaml_string),
         do: File.write(file_path, yaml_string)
  end
end
