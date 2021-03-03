use Mix.Config

config :microservice, :environment, :test

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
# config :microservice, Microservice.Repo,
#   username: "postgres",
#   password: "postgres",
#   database: "microservice_test#{System.get_env("MIX_TEST_PARTITION")}",
#   hostname: "localhost",
#   pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :microservice, MicroserviceWeb.Endpoint,
  http: [port: 4002],
  server: false

config :microservice, Microservice.Engine,
  project_config: "file://test/fixtures/project.yaml",
  job_state_basedir: "/tmp/microservice-test"

# Print only warnings and errors during test
config :logger, level: :warn

config :junit_formatter,
  report_file: "report_file_test.xml",
  report_dir: "./tmp",
  print_report_file: true,
  prepend_project_name?: true
