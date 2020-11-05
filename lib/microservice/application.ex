defmodule Microservice.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # Dynamic configuration section ============================================
    from_system(:credential_path, "CREDENTIAL_PATH")
    from_system(:expression_path, "EXPRESSION_PATH")
    from_system(:adaptor_path, "ADAPTOR_PATH")
    from_system(:final_state_path, "FINAL_STATE_PATH")
    from_system(:endpoint_style, "ENDPOINT_STYLE", "async")

    Application.put_env(
      :microservice,
      :node_js_sys_path,
      System.get_env("NODE_JS_PATH", "./") <> ":" <> System.get_env("PATH")
    )

    children = [
      # Start the Ecto repository
      # Microservice.Repo,
      # Start the Telemetry supervisor
      # MicroserviceWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Microservice.PubSub},
      # Start the Endpoint (http/https)
      MicroserviceWeb.Endpoint
      # Start a worker by calling: Microservice.Worker.start_link(arg)
      # {Microservice.Worker, arg}
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
