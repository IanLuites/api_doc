defmodule APIDoc.MixProject do
  use Mix.Project

  @version "0.0.1-rc"

  def project do
    [
      app: :api_doc,
      version: @version,
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Testing
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      dialyzer: [ignore_warnings: "dialyzer.ignore-warnings", plt_add_deps: true],

      # Docs
      name: "APIDoc",
      docs: [
        extras: ["README.md"],
        source_ref: "v#{@version}",
        source_url: "https://github.com/IanLuites/api_doc"
      ]
    ]
  end

  def package do
    [
      name: :api_doc,
      maintainers: ["Ian Luites"],
      licenses: ["MIT"],
      files: [
        # Elixir
        "lib",
        "mix.exs",
        "README*",
        "LICENSE"
      ],
      links: %{}
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
      {:analyze, ">= 0.0.0", only: [:dev, :test], runtime: false}
    ]
  end
end
