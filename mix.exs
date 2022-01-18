defmodule Rubik.MixProject do
  use Mix.Project

  def project do
    [
      app: :rubik,
      version: "0.1.0",
      elixir: "~> 1.12",
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
      {:decimal, "~> 2.0"},
      {:jason, "~> 1.0"},

      # Tests, Analysis
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false}
    ]
  end
end
