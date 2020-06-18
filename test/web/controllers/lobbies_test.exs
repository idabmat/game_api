defmodule Web.Controllers.LobbiesTest do
  use Web.ConnCase, async: false

  @valid_create_attrs %{lobby_name: "My game", player_name: "Alice"}
  @invalid_create_attrs %{lobby_name: "", player_name: ""}
  @valid_join_attrs %{player_name: "Bob"}
  @invalid_join_atts %{player_name: "Alice"}

  setup do
    Configuration.load!()
    start_supervised!(Auth.Account.InMemory)
    start_supervised!(Game.Lobby.InMemory)

    on_exit(&Configuration.unload/0)

    :ok
  end

  defp fixture(fixture_name, opts \\ [])

  defp fixture(:account, opts) do
    data = Keyword.get(opts, :data, %{provider: :foo, uid: "123"})
    {:ok, account} = Auth.create_account(data)
    account
  end

  defp fixture(:token, opts) do
    account = Keyword.get(opts, :account, fixture(:account))
    {:ok, token} = Auth.create_token(account)
    token
  end

  defp fixture(:lobby, opts) do
    account = Keyword.get(opts, :account, fixture(:account))
    args = Map.put(@valid_create_attrs, :account, account)
    {:ok, lobby} = Game.create_lobby(args)
    lobby
  end

  describe "creating a lobby" do
    test "as an unauthenticated user", %{conn: conn} do
      conn = post(conn, "/lobbies", @valid_create_attrs)
      assert json_response(conn, 401) == %{"errors" => %{"detail" => "unauthenticated"}}
    end

    test "as a non existing user", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer 123")
        |> post("/lobbies", @valid_create_attrs)

      assert json_response(conn, 401) == %{"errors" => %{"detail" => "invalid_token"}}
    end

    test "as an existing authenticated user with valid attributes", %{conn: conn} do
      token = fixture(:token)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post("/lobbies", @valid_create_attrs)

      assert json_response(conn, 201) == %{
               "name" => "My game",
               "players" => [%{"name" => "Alice"}]
             }
    end

    test "as an existing authenticated user with invalid attributes", %{conn: conn} do
      token = fixture(:token)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post("/lobbies", @invalid_create_attrs)

      assert json_response(conn, 400) == %{
               "errors" => %{
                 "lobby_name" => ["cant_be_blank"],
                 "player_name" => ["cant_be_blank"]
               }
             }
    end

    test "as an existing authenticated user with blank params", %{conn: conn} do
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

  describe "joining a lobby" do
    test "as an unauthenticated user", %{conn: conn} do
      lobby_id = fixture(:lobby).uid
      conn = patch(conn, "/lobbies/#{lobby_id}", @valid_join_attrs)
      assert json_response(conn, 401) == %{"errors" => %{"detail" => "unauthenticated"}}
    end

    test "as a non existing user", %{conn: conn} do
      lobby_id = fixture(:lobby).uid

      conn =
        conn
        |> put_req_header("authorization", "Bearer 123")
        |> patch("/lobbies/#{lobby_id}", @valid_join_attrs)

      assert json_response(conn, 401) == %{"errors" => %{"detail" => "invalid_token"}}
    end

    test "as an existing authenticated user with an non existent lobby", %{conn: conn} do
      token = fixture(:token)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> patch("/lobbies/123", @valid_join_attrs)

      assert json_response(conn, 422) == %{"errors" => %{"lobby" => ["not_found"]}}
    end

    test "as an existing authenticated user who already joined lobby", %{conn: conn} do
      token = fixture(:token)
      lobby_id = fixture(:lobby).uid

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> patch("/lobbies/#{lobby_id}", @valid_join_attrs)

      assert json_response(conn, 422) == %{"errors" => %{"player" => ["already_joined"]}}
    end

    test "as an existing authenticated user with invalid args", %{conn: conn} do
      data = %{provider: :foo, uid: "345"}
      account = fixture(:account, data: data)
      token = fixture(:token, account: account)
      lobby_id = fixture(:lobby).uid

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> patch("/lobbies/#{lobby_id}", @invalid_join_atts)

      assert json_response(conn, 422) == %{"errors" => %{"player" => ["name_taken"]}}
    end

    test "as an existing authenticated user with valid args", %{conn: conn} do
      data = %{provider: :foo, uid: "345"}
      account = fixture(:account, data: data)
      token = fixture(:token, account: account)
      lobby_id = fixture(:lobby).uid

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> patch("/lobbies/#{lobby_id}", @valid_join_attrs)

      assert json_response(conn, 200) == %{
               "name" => "My game",
               "players" => [%{"name" => "Alice"}, %{"name" => "Bob"}]
             }
    end
  end
end
