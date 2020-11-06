defmodule Microservice.DispatcherTest do
  use ExUnit.Case, async: true
  use MicroserviceWeb.ConnCase

  import Microservice.TestUtil

  test "calling Dispatcher.execute/1 runs a job that fails" do
    result = Dispatcher.execute(%{data: %{a: 1}})

    assert %{exit_code: 1, log: log, success: false} = result

    assert Enum.at(log, 0)
           |> String.contains?("TypeError [Error]: Cannot read property 'push' of undefined")
  end

  test "calling Dispatcher.execute/1 runs a job that succeeds" do
    result = Dispatcher.execute(%{data: %{array: [1, 2, 3]}})

    assert %{exit_code: 0, log: log, success: true} = result
    assert "Something in the logs." = Enum.at(log, 0)
    assert "Finished." = Enum.at(log, 1)
  end
end
