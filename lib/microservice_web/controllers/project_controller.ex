defmodule MicroserviceWeb.Receiver do
  use MicroserviceWeb, :controller
  require Logger
  alias Engine.Message

  @spec receive(Plug.Conn.t(), any) :: Plug.Conn.t()
  def update(conn, params) do
    Logger.debug("ProjectController.update/2 called")
    IO.inspect(conn, lable: "conn")
    IO.inspect(params, lable: "params")

    conn
    |> put_status(:ok)
end
