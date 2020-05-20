defmodule Web.RouterTest do
  use Web.ConnCase

  test "returns ok on /health", %{conn: conn} do
    conn = get(conn, "/health")
    assert json_response(conn, 200) == %{"status" => "ok"}
  end

  test "return 404 elsewhere", %{conn: conn} do
    assert_raise Phoenix.Router.NoRouteError, fn ->
      conn = get(conn, "/pokemon")
      assert json_response(conn, 404) == %{"errors" => %{"detail" => "Not Found"}}
    end
  end
end
