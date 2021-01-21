defmodule ShellProcess do
  require Logger
  use GenServer

  def launch(command) do
    GenServer.start_link(ShellProcess, [command, self()])
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  def process_running?(os_pid) when is_integer(os_pid) do
    {_name, exit_code} = System.cmd("ps", ~w(-q #{os_pid} -o comm=))

    exit_code == 0
  end

  # Server
  def init([command, parent]) do
    # Give us a chance to handle parent processes shutting down
    Process.flag(:trap_exit, true)

    port = Port.open({:spawn, command}, [:binary, :exit_status])
    monitor_ref = Port.monitor(port)
    os_pid = case Port.info(port, :os_pid) do
       nil -> :unknown
       {:os_pid, os_pid } -> os_pid
    end

    {:ok,
     %{
       port: port,
       os_pid: os_pid,
       latest_output: nil,
       exit_status: nil,
       parent: parent,
       monitor_ref: monitor_ref
     }}
  end

  # When the Port monitor reports it's being terminated from the beam
  def terminate(reason, %{port: port, monitor_ref: monitor_ref, os_pid: os_pid} = state) do
    IO.puts(
      "** TERMINATE: #{inspect(reason)}. This is the last chance to clean up after this process."
    )

    IO.puts("Final state: #{inspect(state)}")
    IO.puts("Orphaned OS process: #{os_pid}")

    Task.start(fn ->
      # {result, code} = System.cmd("kill", ~w(-9 #{os_pid}))
      IO.inspect System.cmd("sh", ["-c", "kill -9 #{os_pid} > /tmp/out"])
      # IO.puts(result)
      # IO.puts("kill result: #{inspect(result)} #{code}")

    end)

    # Port.demonitor(monitor_ref)

    :shutdown
  end

  # Callback for STDOUT
  def handle_info({_port, {:data, text}}, state) do
    send_parent(state, {:stdout, text})
    {:noreply, state}
  end

  # Callback for when the command exits
  def handle_info({_port, {:exit_status, status}}, state) do
    IO.inspect("Port exit: :exit_status: #{status}")

    new_state = %{state | exit_status: status}
    send_parent(state, {:exit, status})

    Process.exit(self(), :normal)

    {:noreply, new_state}
  end

  # Callback for when the Port exits normally
  def handle_info({:EXIT, _port, :normal}, state) do
    IO.inspect("handle_info: EXIT")

    cleanup(state)

    send_parent(state, {:exit})
    {:noreply, state}
  end

  # Callback for when the process gets an exit signal
  def handle_info({:DOWN, _ref, :process, _object, reason}, state) do
    # Stop trapping exits, we're going to try and stop the command
    cleanup(state)

    Logger.warn(":process DOWN - #{inspect(reason)}")
    # send_parent(state, {:exit})
    {:noreply, state}
  end

  # Callback for when the Port exits normally
  def handle_info({:DOWN, _ref, :port, _object, reason}, %{os_pid: os_pid} = state) do
    Logger.warn(":port DOWN - #{inspect(reason)}")

    # send_parent(state, {:exit})
    {:noreply, state}
  end

  def handle_info(msg, state) do
    IO.puts("Unhandled message: #{inspect(msg)}")
    {:noreply, state}
  end

  def handle_call({:get, key}, pid, state) do
    {:reply, Map.get(state, key), state}
  end

  defp send_parent(%{parent: parent}, msg) do
    send(parent, msg)
  end

  defp cleanup(state) do
    Process.flag(:trap_exit, false)
    Process.exit(self(), :normal)
  end
end

defmodule GenericServer do
  use GenServer

  def init([parent]) do
    # Process.flag(:trap_exit, true)

    {:ok, task} =
      Task.start(fn ->
        Process.sleep(200)
        "foo"
      end)

    Process.monitor(task)

    {:ok, parent}
  end

  def handle_info({:DOWN, ref, :process, object, reason}, state) do
    IO.inspect(self())
    IO.inspect([ref, object])
    send(state, {:done, "foo"})
    Process.exit(self(), :normal)
    {:noreply, state}
  end

  def handle_info({:EXIT, _ref, :normal}, state) do
    {:noreply, state}
  end
end

defmodule ShellProcess.Test do
  use ExUnit.Case, async: false

  # test "fgfdgfd" do
  #   {:ok, pid} = GenServer.start_link(GenericServer, [self()])

  #   assert_receive {:done, "foo"}, 600

  #   alive = Process.alive?(pid)
  #   IO.inspect(alive)
  #   assert !alive, "didn't exit after it was done"

  # end

  # test "can run a simple process"
  # test "sends log lines back to the parent"
  # test "sends the exit code back with it's done"

  # TODO: check out the System.cmd error handling
  # test "sends a premature exit to it's parent"

  # test "stops the system process if the port is closed"
  # test "stops the system process if the outside process is stopped"
  # test "stops 'itself' when the process has completed"

  test "can start a new process" do
    {:ok, pid} = ShellProcess.launch(~s(sh -c 'echo 1; echo 2; exit 2'))

    assert_receive {:stdout, "1\n2\n"}, 500
    assert_receive {:exit, 2}, 2000, "process didn't exit with exit code 0"

    IO.inspect System.cmd("sh", ["-c", "echo foo > /tmp/out"])
    os_pid = ShellProcess.get(pid, :os_pid)

    assert os_pid !== nil, "didn't get a system process id"

    # Uncomment to invoke an error that will cause this parent process to stop
    # that intern invokes `terminate`
    # ShellProcess.get(pid, :wat)
    assert_receive {:stdout, "done\n"}, 500, "didn't get the correct lines from STDOUT"
    assert_receive {:exit, 2}, 2000, "process didn't exit with exit code 0"
    assert !ShellProcess.process_running?(os_pid)

    assert !Process.alive?(pid)

    IO.inspect(pid)

    Process.exit(pid, :normal)

    # Need like a sec to see the effects of the process getting killed.
    Process.sleep(100)


    # result = receive do
    #   any -> IO.inspect(any)
    #   {:done, data} ->
    #     IO.inspect(data)
    #   after 2000 -> :timeout
    # end

    # command = spawn_link(Exec, :command, [~s(sh -c 'sleep 2; echo done'), self()])

    # Runner.await(command)

    # {:ok, pid} = ShellProcess.start_link(%{command: "bash -c 'sleep 1 && echo foo'", arguments: ["-c", "sleep 1"]})

    # IO.puts "process started"

    # ref = Process.monitor(pid)

    # IO.puts "---"
    # receive do
    #   any -> IO.puts "adskdfjdsdkfdjs"
    #   {evt, ^ref, _, _, _} -> IO.inspect("foofoo")
    # after
    #   # Optional timeout
    #   5000 -> :timeout
    # end

    # assert ShellProcess.has_exited?(pid)
    # # assert GenServer.call(pid, {:foo})
  end

  test "returns the exit code" do
    # ShellProcess.execute(~s(sh -c 'sleep 2; echo done'))

    # result = receive do
    #   {:exit_code, code} ->
    # end
  end
end
