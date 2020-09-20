defmodule Yamel.MixProject do
  use Mix.Project

  def project do
    [
      app: :yamel,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:yaml_elixir, "~> 2.4.0"},
      {:ex_doc, ">= 0.0.0", runtime: false, only: :dev}
    ]
  end
end
