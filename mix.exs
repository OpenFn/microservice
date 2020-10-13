defmodule Microservice.MixProject do
  use Mix.Project

  def project do
    [
      app: :microservice,
      version: "0.1.1",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      # Docs
      name: "MyApp",
      source_url: "https://github.com/openfn/microservice",
      homepage_url: "https://www.openfn.org",
      docs: [
        # The main page in the docs
        main: "Microservice",
        # logo: "path/to/logo.png",
        extras: ["README.md"],
        output: "docs"
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Microservice.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:jason, "~> 1.0"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix, "~> 1.4.12"},
      {:plug_cowboy, "~> 2.4"},
      {:temp, "~> 0.4.7"}
    ]
  end
end
