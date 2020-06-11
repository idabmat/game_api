defmodule Web.Controllers.LobbiesTest do
  use Web.ConnCase, async: false

  @create_attrs %{lobby_name: "My game", player_name: "Alice"}
  @invalid_attrs %{lobby_name: "", player_name: ""}

  setup context do
    if context[:with_config] do
      Configuration.load!()
      start_supervised!(Auth.Account.InMemory)
      start_supervised!(Game.Lobby.InMemory)

      on_exit(&Configuration.unload/0)
    end

    :ok
  end

  defp fixture(:account) do
    data = %{provider: :foo, uid: "123"}
    {:ok, account} = Auth.create_account(data)
    account
  end

  defp fixture(:token) do
    account = fixture(:account)
    {:ok, token} = Auth.create_token(account)
    token
  end

  describe "creating a lobby" do
    test "as an unauthenticated user", %{conn: conn} do
      conn = post(conn, "/lobbies", @create_attrs)
      assert json_response(conn, 401) == %{"errors" => %{"detail" => "unauthenticated"}}
    end

    test "as a non existing user", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer 123")
        |> post("/lobbies", @create_attrs)

      assert json_response(conn, 401) == %{"errors" => %{"detail" => "invalid_token"}}
    end

    @tag :with_config
    test "as an existing authenticated user with valid attributes", %{conn: conn} do
      token = fixture(:token)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post("/lobbies", @create_attrs)

      assert json_response(conn, 201) == %{
               "name" => "My game",
               "players" => [%{"name" => "Alice"}]
             }
    end

    @tag :with_config
    test "as an existing authenticated user with invalid attributes", %{conn: conn} do
      token = fixture(:token)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post("/lobbies", @invalid_attrs)

      assert json_response(conn, 400) == %{
               "errors" => %{
                 "lobby_name" => ["cant_be_blank"],
                 "player_name" => ["cant_be_blank"]
               }
             }
    end

    @tag :with_config
    test "as an existing authenticated user without params", %{conn: conn} do
      token = fixture(:token)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post("/lobbies", %{})

      assert json_response(conn, 400) == %{
               "errors" => %{
                 "lobby_name" => ["cant_be_blank"],
                 "player_name" => ["cant_be_blank"]
               }
             }
    end
  end
end
