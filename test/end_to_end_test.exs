defmodule Microservice.EndToEndTest do
  use ExUnit.Case, async: false
  use MicroserviceWeb.ConnCase

  alias Engine.{Message, Job, Run}

  import Microservice.TestUtil

  setup do
    match = fixture(:valid_post_body)
    no_match = fixture(:unmatched_post_body)
    flow_match = fixture(:flow_post_body)
    fail_match = fixture(:fail_post_body)

    conn =
      build_conn()
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")

    {:ok,
     match: match, no_match: no_match, conn: conn, flow_match: flow_match, fail_match: fail_match}
  end

  test "posting data that matches a trigger runs the relevant job", %{conn: conn, match: match} do
    File.rm_rf!("/tmp/microservice-test")
    initial_state = Microservice.Engine.get_job_state(%Job{name: "job-1"})
    assert is_nil(initial_state)

    response = post(conn, "/inbox/", match)
    assert response.status == 202
    assert %{"data" => ["job-1"]} = response.resp_body |> Jason.decode!()

    :timer.sleep(2000)

    final_state = Microservice.Engine.get_job_state(%Job{name: "job-1"})
    assert final_state["data"]["number"] == 4
  end

  test "posting data that doesn't match any triggers doesn't run any jobs", %{
    conn: conn,
    no_match: no_match
  } do
    File.rm_rf!("/tmp/microservice-test")

    response = post(conn, "/inbox/", no_match)
    assert response.status == 202
    assert %{"data" => []} = response.resp_body |> Jason.decode!()
  end

  test "a minutely cron job will be run by quantum every minute", %{} do
    import Crontab.CronExpression

    assert Enum.count(Engine.Scheduler.jobs()) == 1
    assert Engine.Scheduler.find_job(:"trigger-4").state == :active
    assert Engine.Scheduler.find_job(:"trigger-4").schedule == ~e[* * * * * *]
  end

  test "when a run succeeds, subsequent runs may be triggered", %{
    conn: conn,
    flow_match: flow_match
  } do
    File.rm_rf!("/tmp/microservice-test")
    assert Microservice.Engine.get_job_state(%Job{name: "flow-job"}) |> is_nil

    response = post(conn, "/inbox/", flow_match)
    assert response.status == 202
    assert %{"data" => ["job-2"]} = response.resp_body |> Jason.decode!()

    # First "job-2" is run.
    :timer.sleep(2000)
    # Then "flow-job" is run.

    after_success_state = Microservice.Engine.get_job_state(%Job{name: "flow-job"})
    assert after_success_state["data"]["b"] == 6
  end

  test "when a run fails, subsequent runs may be triggered", %{
    conn: conn,
    fail_match: fail_match
  } do
    File.rm_rf!("/tmp/microservice-test")
    assert Microservice.Engine.get_job_state(%Job{name: "catch-job"}) |> is_nil
    response = post(conn, "/inbox/", fail_match)
    assert response.status == 202
    assert %{"data" => ["bad-job"]} = response.resp_body |> Jason.decode!()

    # First "bad-job" is run.
    :timer.sleep(2000)
    # Then "catch-job" is run.

    catch_state = Microservice.Engine.get_job_state(%Job{name: "catch-job"})
    assert catch_state["message"] == "handled it."
  end

  test "credentials are added to a job's inititial state", %{} do
    [%Run{job: %Job{} = job}] =
      Microservice.Engine.handle_message(%Message{body: %{"b" => 2}})

    assert job.credential == "my-secret-credential"

    :timer.sleep(2000)

    final_state = Microservice.Engine.get_job_state(%Job{name: "job-2"})
    assert %{"configuration" => %{"username" => "user@example.com"}} = final_state
  end
end
