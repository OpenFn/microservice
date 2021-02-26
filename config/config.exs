# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# config :microservice,
#   ecto_repos: [Microservice.Repo]

# Configures the endpoint
config :microservice, MicroserviceWeb.Endpoint,
  url: [host: "localhost"],
  http: [port: System.get_env("PORT")],
  secret_key_base: "UcbUPAfkiZ6YaM3PHiy5Cyco99cp+YPp4FFjygQ05/yfybjrh5OaeQAABfHNLqWa",
  render_errors: [view: MicroserviceWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Microservice.PubSub,
  live_view: [signing_salt: "jDLFTx8L"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :microservice, Microservice.Engine, project_config: "file://project.yaml"
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.

import_config "#{Mix.env()}.exs"
