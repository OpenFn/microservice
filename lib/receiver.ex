defmodule MicroserviceWeb.Receiver do
  use MicroserviceWeb, :controller
  require Logger

  @spec receive(Plug.Conn.t(), any) :: Plug.Conn.t()
  def receive(conn, _other) do
    Logger.debug("Receiver.receive/2 called")

    # TODO: Add persist option with multi-inbox option.
    # persist? = Application.get_env(:openfn_inbox, :persist, false)
    # multi_inbox? = Application.get_env(:openfn_inbox, :multiple, false)

    # if persist?, do: Application.get_env(:openfn_inbox, :persistence_module).persist

    # if multi_inbox? do
    #   Application.get_env(:openfn_inbox, :inbox_definitions).define
    # end

    body =
      conn
      |> Map.fetch!(:body_params)
      |> Jason.encode!()
      |> Jason.decode!()

    state = %{data: body}

    result =
      case Application.get_env(:microservice, :endpoint_style) do
        "sync" -> Dispatcher.execute(state)
        "async" -> Task.async(Dispatcher, :execute, [state])
      end

    {status, msg, data, errors} =
      case result do
        %{exit_code: 0, log: log} ->
          {:created, "Job suceeded.", log, []}

        %{log: log, exit_code: 1} ->
          {:im_a_teapot, "Job failed.", log, [log]}

        %{exit_code: _big, log: log} ->
          {:internal_server_error, "Job crashed", log, []}

        %Task{} ->
          {:accepted, "Data accepted and processing has begun.", nil, []}
      end

    conn
    |> put_status(status)
    |> json(%{msg: msg, data: data, errors: errors})
  end
end
