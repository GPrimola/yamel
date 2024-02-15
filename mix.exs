defmodule Yamel.MixProject do
  use Mix.Project

  @version "1.1.2"
  @source_url "https://github.com/GPrimola/yamel"
  @logo_path "priv/img/yamel-logo.png"
  @licenses ["Apache-2.0"]

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
      ],
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/yamel.plt"},
        list_unused_filters: true
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
      {:yaml_elixir, "~> 2.8.0"},
      {:ex_doc, ">= 0.0.0", runtime: false, only: :dev},
      {:excoveralls, "~> 0.13.2", only: :test},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      source_url: @source_url,
      logo: @logo_path
    ]
  end

  defp package do
    [
      name: "yamel",
      description: """
      This is a helper to work with Yaml files in Elixir.
      """,
      licenses: @licenses,
      links: %{"GitHub" => @source_url}
    ]
  end
end
