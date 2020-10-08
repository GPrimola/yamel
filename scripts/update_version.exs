
# {:ok, version} = File.read(version_file)
# version = String.trim(version)
# IO.puts("Updating to version #{version}")
# {:ok, mix_exs} = File.read(mix_exs_file)
# {:ok, readme} = File.read(readme_file)
# IO.puts("Updating #{mix_exs_file}...")
# mix_exs = String.replace(mix_exs, ~r/@version \".*\"/, "@version \"#{version}\"", global: false)
# mix_exs_file_update = File.write!(mix_exs_file, mix_exs)
# if mix_exs_file_update == :ok,
#   do: IO.puts("#{mix_exs_file} updated successfully!"),
# else: raise "Could not update #{mix_exs_file} to version #{version}. #{inspect(mix_exs_file_update)}"
#
# IO.puts("Updating #{readme_file}...")
# readme = String.replace(readme, ~r/{:yamel, \"~> .*\"}/, "{:yamel, \"~> #{version}\"}")
# readme_file_update = File.write!(readme_file, readme)
#
# if readme_file_update == :ok,
#   do: IO.puts("#{readme_file} updated successfully!"),
# else: raise "Could not update #{readme_file} to version #{version}. #{inspect(readme_file_update)}"

defmodule UpdateVersion do
  @version_file "./version"
  @mix_exs_file "./mix.exs"
  @readme_file "./README.md"

  def update() do
    with {:ok, version} <- get_version(),
      {:ok, mix_exs} <- File.read(@mix_exs_file),
      {:ok, readme} <- File.read(@readme_file),
      {:ok, _mix_exs} <- update_mix(mix_exs, version),
      {:ok, _readme} <- update_readme(readme, version) do
        IO.puts("\nThe application was updated to version #{version}!")
      else
        {:error, reason} ->
          raise reason
      end
  end

  def get_version() do
    {:ok, version} = File.read(@version_file)
    {:ok, String.trim(version)}
  end

  def update_mix(mix_exs, version) do
    IO.puts("Updating #{@mix_exs_file}...")
    mix_exs = String.replace(mix_exs, ~r/@version \".*\"/, "@version \"#{version}\"", global: false)

    case File.write!(@mix_exs_file, mix_exs) do
      :ok ->
        IO.puts("#{@mix_exs_file} updated successfully!")
        {:ok, mix_exs}
      error -> {:error, "Could not update #{@mix_exs_file} to version #{version}. #{inspect(error)}"}
    end
  end

  def update_readme(readme, version) do
    IO.puts("Updating #{@readme_file}...")
    readme = String.replace(readme, ~r/{:yamel, \"~> .*\"}/, "{:yamel, \"~> #{version}\"}")

    case File.write!(@readme_file, readme) do
      :ok ->
        IO.puts("#{@readme_file} updated successfully!")
        {:ok, readme}

      error ->
        {:error, "Could not update #{@readme_file} to version #{version}. #{inspect(error)}"}
    end
  end
end

UpdateVersion.update()
