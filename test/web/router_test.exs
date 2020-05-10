defmodule Web.RouterTest do
  use Web.ConnCase

  test "returns ok on /", %{conn: conn} do
    conn = get(conn, "/")
    assert json_response(conn, 200) == %{"response" => "ok"}
  end

  test "posting some JSON", %{conn: conn} do
    conn = post(conn, "/", %{foo: :bar})
    assert json_response(conn, 201) == %{"request" => %{"foo" => "bar"}}
  end

  test "return 404 elsewhere", %{conn: conn} do
    {404, _headers, body} =
      assert_error_sent(404, fn ->
        get(conn, "/pokemon")
      end)

    assert Jason.decode!(body) == %{"errors" => %{"detail" => "Not Found"}}
  end
end
