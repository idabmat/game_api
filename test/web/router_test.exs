defmodule Web.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import ExUnit.CaptureLog

  alias Web.Router
  @opts Router.init([])

  test "returns ok on /" do
    assert capture_log(fn ->
             conn = conn(:get, "/") |> Router.call(@opts)

             assert conn.state == :sent
             assert conn.status == 200
             assert Jason.decode!(conn.resp_body) == %{"response" => "ok"}

             assert Enum.member?(
                      conn.resp_headers,
                      {"content-type", "application/json; charset=utf-8"}
                    )
           end) =~ "GET /"
  end

  test "posting some JSON" do
    assert capture_log(fn ->
             conn =
               conn(:post, "/", Jason.encode!(%{foo: "bar"}))
               |> put_req_header("content-type", "application/json")
               |> Router.call(@opts)

             assert conn.state == :sent
             assert conn.status == 201
             assert Jason.decode!(conn.resp_body) == %{"request" => %{"foo" => "bar"}}

             assert Enum.member?(
                      conn.resp_headers,
                      {"content-type", "application/json; charset=utf-8"}
                    )
           end) =~ "POST /"
  end

  test "return 404 elsewhere" do
    assert capture_log(fn ->
             conn = conn(:get, "/pokemon") |> Router.call(@opts)

             assert conn.state == :sent
             assert conn.status == 404
             assert Jason.decode!(conn.resp_body) == %{"error" => "Not found"}

             assert Enum.member?(
                      conn.resp_headers,
                      {"content-type", "application/json; charset=utf-8"}
                    )
           end) =~ "GET /pokemon"
  end
end
