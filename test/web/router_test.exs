defmodule Web.RouterTest do
  use Web.ConnCase, async: false

  setup context do
    if context[:with_config] do
      start_supervised!(Auth.Account.InMemory)
      Configuration.load!()

      on_exit(&Configuration.unload/0)
    end

    :ok
  end

  test "returns ok on /health", %{conn: conn} do
    conn = get(conn, "/health")
    assert json_response(conn, 200) == %{"status" => "ok"}
  end

  test "return authorization error without token", %{conn: conn} do
    conn = get(conn, "/sekret")
    assert json_response(conn, 401) == %{"errors" => %{"detail" => "unauthenticated"}}
  end

  test "return authorization error on invalid token", %{conn: conn} do
    conn =
      conn
      |> put_req_header("authorization", "Bearer 123")
      |> get("/sekret")

    assert json_response(conn, 401) == %{"errors" => %{"detail" => "invalid_token"}}
  end

  @tag :with_config
  test "return protected endpoint with credentials", %{conn: conn} do
    {:ok, account} = Auth.create_account(%{provider: :foo, uid: "123"})
    {:ok, token} = Auth.create_token(account)

    conn =
      conn
      |> put_req_header("authorization", "Bearer #{token}")
      |> get("/sekret")

    assert json_response(conn, 200) == %{"status" => "ok"}
  end

  test "return 404 elsewhere", %{conn: conn} do
    assert_raise Phoenix.Router.NoRouteError, fn ->
      conn = get(conn, "/pokemon")
      assert json_response(conn, 404) == %{"errors" => %{"detail" => "Not Found"}}
    end
  end
end
