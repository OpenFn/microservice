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

    Task.async(ShellWorker, :execute, [data])

    conn
    |> put_status(:ok)
    |> json(%{message: "Payload received. Thanks."})
  end
end
