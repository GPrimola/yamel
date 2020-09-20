defmodule Yamel.MixProject do
  use Mix.Project

  def project do
    [
      app: :yamel,
      version: "1.0.1",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
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
      {:ex_doc, ">= 0.0.0", runtime: false, only: :dev},
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end

  defp package do
    [
      name: "yamel",
      description: """
      This is a helper to work with Yaml files in Elixir.
      """,
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/GPrimola/yamel"}
    ]
  end
end
