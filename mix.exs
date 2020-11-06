defmodule Microservice.MixProject do
  use Mix.Project

  def project do
    [
      app: :microservice,
      version: "0.2.1",
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      name: "microservice",
      source_url: "https://github.com/openfn/microservice",
      homepage_url: "https://openfn.github.io/microservice/readme.html",
      docs: [
        main: "readme",
        logo: "assets/logo.png",
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
      extra_applications: [:logger, :runtime_tools, :os_mon]
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
      {:ecto_sql, "~> 3.4"},
      {:ex_doc, "~> 0.23.0", only: :dev, runtime: false},
      {:floki, ">= 0.27.0", only: :test},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_dashboard, "~> 0.3 or ~> 0.2.9"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.14.6"},
      {:phoenix, "~> 1.5.6"},
      {:plug_cowboy, "~> 2.0"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:temp, "~> 0.4.7"}
      # {:phoenix_ecto, "~> 4.1"},
      # {:postgrex, ">= 0.0.0"},
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "cmd npm install --prefix assets"]
      # setup: ["deps.get", "ecto.setup", "cmd npm install --prefix assets"],
      # "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      # "ecto.reset": ["ecto.drop", "ecto.setup"],
      # test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
