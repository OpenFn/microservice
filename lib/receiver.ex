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

    data =
      conn
      |> Map.fetch!(:body_params)
      |> Jason.encode!()
      |> Jason.decode!()

    result =
      case Application.get_env(:microservice, :endpoint_style) do
        "sync" -> Dispatcher.execute(data)
        "async" -> Task.async(Dispatcher, :execute, [data])
      end

    {status, msg, data, errors} =
      case result do
        {:ok, %{log: log, exit_code: 0}} ->
          {:created, "Job suceeded.", log, []}

        {:ok, %{log: log, exit_code: 1}} ->
          {:im_a_teapot, "Job failed.", log, [log]}

        {:ok, %{log: log, exit_code: _big}} ->
          {:internal_server_error, "Job crashed", log, []}

        %Task{} ->
          {:accepted, "Data accepted and processing has begun.", nil, []}
      end

    conn
    |> put_status(status)
    |> json(%{msg: msg, data: data, errors: errors})
  end
end
