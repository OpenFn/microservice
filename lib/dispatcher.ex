defmodule Dispatcher do
  require Logger

  @spec execute(map) :: %{
          exit_code: non_neg_integer,
          final_state: any,
          log: [binary],
          success: boolean
        }
  @doc """
  Run a job with the OpenFn/Core cli in an isolated NodeVM, given paths for
  state, expression, and final_state, killing that NodeVM after a specified
  number of seconds.
  """
  def execute(state) when is_map(state) do
    Logger.debug("Dispatcher.execute/1 called with #{inspect(state)}")

    Application.get_env(:microservice, :max_run_duration, "60")
    |> String.to_integer()
    |> :timer.seconds()
    |> :timer.kill_after()

    config =
      Application.get_env(:microservice, :credential_path, "{}")
      |> File.read!()
      |> Jason.decode!()

    {:ok, state_path} = Temp.path(%{prefix: "state", suffix: ".json"})

    File.write!(
      state_path,
      Map.put(state, :configuration, config) |> Jason.encode!()
    )

    expression_path = Application.get_env(:microservice, :expression_path, nil)
    adaptor_path = Application.get_env(:microservice, :adaptor_path, nil)
    final_state_path = Application.get_env(:microservice, :final_state_path, nil)

    arguments = [
      "core",
      "execute",
      "-e",
      expression_path,
      "-l",
      adaptor_path,
      "-s",
      state_path
      | if(final_state_path, do: ["-o", final_state_path], else: [])
    ]

    env = [
      {"NODE_PATH", "./assets/node_modules"},
      {"NODE_ENV", Application.get_env(:microservice, :node_js_env)},
      {"PATH", Application.get_env(:microservice, :node_js_sys_path)}
    ]

    Logger.debug([
      "Executing with:\n",
      "Environment: \n",
      Enum.map(env, fn {k, v} -> "  #{k}: #{v}\n" end),
      "Command: \n  ",
      Enum.join(arguments, " ")
    ])

    System.cmd("env", arguments, env: env, stderr_to_stdout: true)
    |> handle_result(final_state_path)
  end

  defp handle_result(result, final_state_path) do
    Logger.info("Dispatcher finished.")
    handler = Application.get_env(:microservice, :result_handler, nil)

    # TODO: Use a macro to make this work with 'handler(result)'
    case handler do
      nil -> :ok
      _function -> Logger.warn("Handlers not yet supported.")
    end

    case result do
      {stdout, 0} ->
        %{
          log: String.split(stdout, ~r{\n}),
          success: true,
          exit_code: 0,
          final_state: File.read!(final_state_path) |> Jason.decode!()
        }

      {stdout, exit_code} ->
        %{
          log: String.split(stdout, ~r{\n}),
          success: false,
          exit_code: exit_code,
          final_state: nil
        }
    end
  end
end
