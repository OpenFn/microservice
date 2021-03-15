defmodule Microservice.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    from_system(:endpoint_style, "ENDPOINT_STYLE", "async")

    project_dir = System.get_env("PROJECT_DIR", "./sample-project")
    project_yaml_path = project_dir <> "/project.yaml"

    unless Application.get_env(:microservice, :environment) == :test do
      Application.put_env(:microservice, Microservice.Engine,
        project_config: "file://" <> project_yaml_path,
        adaptors_path: Path.join(project_dir, "node_modules")
      )

      AdaptorService.adaptors_from_yaml(project_yaml_path)
      |> AdaptorService.install_adaptors(project_dir)
    end

    children = [
      # Microservice.Repo,
      MicroserviceWeb.Telemetry,
      Microservice.Engine,
      {Phoenix.PubSub, name: Microservice.PubSub},
      MicroserviceWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Microservice.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MicroserviceWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  @spec from_system(atom, binary, nil | binary) :: :ok
  def from_system(key, env, default),
    do: Application.put_env(:microservice, key, System.get_env(env, default), persistent: true)

  @spec from_system(atom, binary) :: :ok
  def from_system(key, env), do: from_system(key, env, nil)
end
