defmodule YatzyApi.Web.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias YatzyApi.Web.Router
  @opts Router.init([])

  test "returns ok on /" do
    conn =
      conn(:get, "/")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "ok"
  end

  test "return 404 elsewhere" do
    conn = conn(:get, "/pokemon") |> Router.call(@opts)
    assert conn.state == :sent
    assert conn.status == 404
    assert conn.resp_body == "Not found"
  end
end
