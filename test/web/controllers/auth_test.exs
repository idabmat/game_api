defmodule Web.Controllers.Authtest do
  use Web.ConnCase

  test "google request phase redirects to google.com", %{conn: conn} do
    conn = get(conn, "/auth/google")
    assert String.match?(response(conn, 302), ~r/accounts\.google\.com/)
  end

  test "google callback phase without a code returns an error", %{conn: conn} do
    conn = get(conn, "/auth/google/callback")
    assert json_response(conn, 400) == %{"errors" => ["No code received"]}
  end

  test "unknown provider request phase does nothing", %{conn: conn} do
    conn = get(conn, "/auth/foobar")
    assert json_response(conn, 200) == %{}
  end
end
