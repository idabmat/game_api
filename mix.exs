defmodule GameApi.MixProject do
  use Mix.Project

  def project do
    [
      app: :game_api,
      version: "0.1.0",
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {GameApi, []}
    ]
  end

  def elixirc_paths(:test), do: ["lib", "test/support"]
  def elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.3", only: [:dev], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ecto, "~> 3.4.4"},
      {:elixir_uuid, "~> 1.2"},
      {:jason, "~> 1.2"},
      {:guardian, "~> 2.0"},
      {:plug_cowboy, "~> 2.0"},
      {:phoenix, "~> 1.5.1"},
      {:typed_struct, "~> 0.1.4"},
      {:ueberauth, "~> 0.6"},
      {:ueberauth_google, "~> 0.9"},
      {:vapor, "~> 0.8"}
    ]
  end

  defp aliases do
    [
      test: "test --no-start",
      check: ["format --check-formatted", "credo --strict", "dialyzer"]
    ]
  end
end
