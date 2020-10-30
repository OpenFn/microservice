defmodule Microservice.EndToEndTest do
  use ExUnit.Case, async: false
  use MicroserviceWeb.ConnCase

  import Microservice.TestUtil

  setup do
    json = fixture(:valid_post_body)

    conn =
      build_conn()
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")

    {:ok, json: json, conn: conn}
  end

  test "posting data to /inbox runs a job and returns a 202", %{conn: conn, json: json} do
    Application.put_env(:microservice, :endpoint_style, "sync", persistent: false)

    response = post(conn, "/inbox/", json)

    {:ok, final_state_file} = File.read("./tmp/output.json")
    final_state = Jason.decode!(final_state_file)
    assert [1, 2, 3, 4] = final_state["data"]["array"]
    assert true = final_state["newKey"]
    File.rm("./tmp/output.json")

    assert response.status == 201

    assert %{
             "data" => ["Something in the logs.", "Finished.", ""],
             "errors" => [],
             "msg" => "Job suceeded."
           } = Jason.decode!(response.resp_body)
  end
end
