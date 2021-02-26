defmodule Microservice.EndToEndTest do
  use ExUnit.Case, async: false
  use MicroserviceWeb.ConnCase

  import Microservice.TestUtil

  setup do
    match = fixture(:valid_post_body)
    no_match = fixture(:unmatched_post_body)

    conn =
      build_conn()
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")

    {:ok, match: match, no_match: no_match, conn: conn}
  end

  test "posting data to /inbox will return a 202", %{conn: conn, match: match} do
    response = post(conn, "/inbox/", match)
    assert response.status == 202
    assert response.resp_body == "{\"msg\":\"Data accepted and processing has begun.\"}"
  end

  test "posting data that matches a trigger runs the relevant job", %{conn: conn, match: match} do
    response = post(conn, "/inbox/", match)
    :timer.sleep(500)

    final_state = Microservice.Engine.get_job_state(%OpenFn.Job{name: "job-1"})
    assert final_state["calculated"] == 4
  end

  # @tag :skip
  # test "posting data that doesn't match any triggers doesn't run any jobs", %{
  #   conn: conn,
  #   json: json
  # } do
  #   matching_json = Map.put(json, "process", false)
  #   # :timer.sleep(1000)
  #   # TODO: check to make sure nothing has been run
  # end

  # @tag :skip
  # test "a cron job configured to run every second runs 3 times in 3 seconds", %{
  #   conn: conn,
  #   json: json
  # } do
  #   # :timer.sleep(3000)
  #   # :ok
  # end

  # @tag :skip
  # test "flow success: when a run succeeds, a subsequent run may be triggered", %{
  #   conn: conn,
  #   json: json
  # } do
  # end

  # @tag :skip
  # test "flow failure: when a run fails, a subsequent run may be triggered", %{
  #   conn: conn,
  #   json: json
  # } do
  # end
end
