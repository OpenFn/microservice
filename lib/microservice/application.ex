defmodule Microservice.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # Dynamic configuration
    Application.put_env(:microservice, :credential_path, System.get_env("CREDENTIAL_PATH"),
      persistent: true
    )

    Application.put_env(:microservice, :expression_path, System.get_env("EXPRESSION_PATH"),
      persistent: true
    )

    Application.put_env(:microservice, :adaptor_path, System.get_env("ADAPTOR_PATH"),
      persistent: true
    )

    Application.put_env(
      :microservice,
      :node_js_sys_path,
      System.get_env("NODE_JS_PATH") <> ":" <> System.get_env("PATH")
    )

    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      MicroserviceWeb.Endpoint
      # Starts a worker by calling: Microservice.Worker.start_link(arg)
      # {Microservice.Worker, arg},
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
end
