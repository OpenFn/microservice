defmodule Microservice.ReceiverTest do
  use ExUnit.Case, async: false
  use MicroserviceWeb.ConnCase

  import Microservice.TestUtil

  setup do
    json = fixture(:valid_post_body)
    bad_json = fixture(:invalid_post_body)

    conn =
      build_conn()
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")

    {:ok, bad_json: bad_json, json: json, conn: conn}
  end

  test "posting valid JSON to /inbox returns a 201 in sync mode", %{conn: conn, json: json} do
    Application.put_env(:microservice, :endpoint_style, "sync", persistent: false)

    Application.put_env(:microservice, :project_config, fixture(:project_config, :yaml),
      persistent: false
    )

    response = post(conn, "/inbox/", json)

    assert response.status == 201

    body = Jason.decode!(response.resp_body)

    assert %{
             "jobs" => [%{"exit_code" => 0, "log" => log}],
             "match_count" => 1,
             "success" => true
           } = body

    assert Regex.match?(~r/Hi there!/, log)

    assert response.params == %{
             "array" => [1, 2, 3],
             "boolean" => true,
             "null" => nil,
             "number" => 2,
             "object" => %{"a" => 1},
             "string" => "here"
           }
  end

  test "posting valid JSON to /inbox returns a 202 in async mode", %{conn: conn, json: json} do
    Application.put_env(:microservice, :endpoint_style, "async", persistent: false)

    Application.put_env(:microservice, :project_config, fixture(:project_config, :yaml),
      persistent: false
    )

    response = post(conn, "/inbox/", json)

    assert response.status == 202

    assert Jason.decode!(response.resp_body) == %{
             "msg" => "Data accepted and processing has begun."
           }

    assert response.params ==
             %{
               "array" => [1, 2, 3],
               "boolean" => true,
               "null" => nil,
               "number" => 2,
               "object" => %{"a" => 1},
               "string" => "here"
             }
  end

  @tag :skip
  test "post to valid inbox with INVALID json sends 404", %{conn: conn, bad_json: bad_json} do
    _url = "http://localhost:4000/inbox/"

    response = post(conn, "/inbox/", bad_json)

    assert 400 == response.status_code

    assert "# Plug.Parsers.ParseError at POST /inbox/" ==
             String.split(response.body, "\n") |> Enum.at(0)

    assert "    ** (Plug.Parsers.ParseError) malformed request, a Jason.DecodeError exception was raised with message \"unexpected byte at position 18: 0x7D ('}')\"" ==
             String.split(response.body, "\n") |> Enum.at(4)
  end
end
