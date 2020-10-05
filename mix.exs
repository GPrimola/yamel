defmodule Yamel.MixProject do
  use Mix.Project

  @version "1.0.4"
  @source_url "https://github.com/GPrimola/yamel"

  def project do
    [
      app: :yamel,
      version: @version,
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      docs: docs(),
      source_url: @source_url,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
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

  defp docs do
    [
      source_ref: "v#{@version}",
      source_url: @source_url,
      logo: "priv/img/yamel-logo.png"
    ]
  end

  defp package do
    [
      name: "yamel",
      description: """
      This is a helper to work with Yaml files in Elixir.
      """,
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url}
    ]
  end
end
