defmodule Web.RouterTest do
  use Web.ConnCase

  test "returns ok on /health", %{conn: conn} do
    conn = get(conn, "/health")
    assert json_response(conn, 200) == %{"status" => "ok"}
  end

  test "return 404 elsewhere", %{conn: conn} do
    {404, _headers, body} = assert_error_sent(404, fn -> get(conn, "/pokemon") end)
    assert Jason.decode!(body) == %{"errors" => %{"detail" => "Not Found"}}
  end
end
