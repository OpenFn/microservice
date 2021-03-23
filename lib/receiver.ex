defmodule MicroserviceWeb.Receiver do
  use MicroserviceWeb, :controller
  require Logger
  alias Engine.Message

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

    {status, data} =
      case Application.get_env(:microservice, :endpoint_style) do
        "sync" ->
          handle_sync(%Message{body: body})

        "async" ->
          # Task.async(Microservice.Engine, :handle_message, [
          #   %Message{body: body}
          # ])

          runs = Microservice.Engine.handle_message(%Message{body: body})

          {:accepted,
           %{
             "meta" => %{"message" => "Data accepted and processing has begun."},
             "data" => Enum.map(runs, fn run -> run.job.name end),
             "errors" => []
           }}
      end

    conn
    |> put_status(status)
    |> json(data)
  end

  def handle_sync(message) do
    results = Microservice.Engine.handle_message(message)

    # All jobs pass
    # No jobs pass
    # No jobs match
    [success_count, fail_count] =
      Enum.reduce(
        results,
        [0, 0],
        fn {ret, _result}, [ok, fail] ->
          case ret do
            :ok ->
              [ok + 1, fail]

            :error ->
              [ok, fail + 1]
          end
        end
      )

    match_count = success_count + fail_count

    report = %{
      jobs:
        Enum.map(results, fn {_ret, %{log: log, exit_code: exit_code}} ->
          %{"log" => log, "exit_code" => exit_code}
        end),
      success: fail_count == 0,
      match_count: match_count
    }

    status =
      cond do
        match_count == 0 -> :ok
        fail_count > 0 -> :partial_content
        true -> :created
      end

    {status, report}
  end
end
