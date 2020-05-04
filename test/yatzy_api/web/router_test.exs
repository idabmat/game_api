defmodule YatzyApi.Web.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import ExUnit.CaptureLog

  alias YatzyApi.Web.Router
  @opts Router.init([])

  test "returns ok on /" do
    assert capture_log(fn ->
             conn = conn(:get, "/") |> Router.call(@opts)

             assert conn.state == :sent
             assert conn.status == 200
             assert conn.resp_body == "ok"
           end) =~ "GET /"
  end

  test "return 404 elsewhere" do
    assert capture_log(fn ->
             conn = conn(:get, "/pokemon") |> Router.call(@opts)

             assert conn.state == :sent
             assert conn.status == 404
             assert conn.resp_body == "Not found"
           end) =~ "GET /pokemon"
  end
end
