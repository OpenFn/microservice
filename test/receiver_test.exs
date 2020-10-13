defmodule Microservice.ReceiverTest do
  use ExUnit.Case, async: false
  use MicroserviceWeb.ConnCase

  import Microservice.TestUtil
  alias Microservice.Receiver

  setup do
    json = fixture(:short_post_body)
    bad_json = fixture(:bad_post_body)

    # upload = %Plug.Upload{path: "test/fixtures/open_rosa.xml", filename: "open_rosa.xml"}

    conn =
      build_conn()
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")

    {
      :ok,
      # upload: upload
      bad_json: bad_json, json: json, conn: conn
    }
  end

  test "posting valid JSON to /inbox returns a 202", %{conn: conn, json: json} do
    response = post(conn, "/inbox/", json)

    assert response.status == 200
    assert response.resp_body == "{\"message\":\"Payload received. Thanks.\"}"

    assert response.params ==
             %{
               "array" => [1, 2, 3],
               "boolean" => true,
               "null" => nil,
               "number" => 2,
               "object" => %{"a" => 1},
               "string" => "here"
             }

    payload = %{
      "body" => %{
        "__query_params" => %{},
        "array" => [1, 2, 3],
        "boolean" => true,
        "null" => nil,
        "number" => 2,
        "object" => %{"a" => 1},
        "string" => "here"
      },
      "method" => "POST",
      "headers" => %{
        "accept" => "application/json",
        "content-type" => "application/json",
        "__internal_request_id" => Map.new(response.resp_headers)["x-request-id"]
      }
    }

    # assert_enqueued(worker: ReceiptService, args: payload)
  end

  @tag :skip
  test "post to valid inbox with INVALID json sends 400", %{conn: conn, bad_json: bad_json} do
    url = "http://localhost:4001/inbox/"

    response = post(conn, "/inbox/", bad_json)

    assert 400 == response.status_code

    assert "# Plug.Parsers.ParseError at POST /inbox/" ==
             String.split(response.body, "\n") |> Enum.at(0)

    assert "    ** (Plug.Parsers.ParseError) malformed request, a Jason.DecodeError exception was raised with message \"unexpected byte at position 18: 0x7D ('}')\"" ==
             String.split(response.body, "\n") |> Enum.at(4)
  end
end
