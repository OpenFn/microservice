defmodule Microservice.Repeater do
  use GenServer

  require Logger

  def start_link(), do: GenServer.start_link(__MODULE__, %{})
  def start_link(state), do: GenServer.start_link(__MODULE__, state)

  def init(state) do
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, state) do
    Logger.warn(fn -> "Timer job running with #{inspect(state)}" end)

    %{exit_code: exit_code, final_state: next_state} = Dispatcher.execute(state)

    schedule_work()
    {:noreply, next_state}
  end

  defp schedule_work() do
    milliseconds = System.get_env("FREQUENCY") |> String.to_integer()
    Process.send_after(self(), :work, milliseconds)
  end
end
