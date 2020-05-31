defmodule Game.JoinLobbyTest do
  use ExUnit.Case, async: false

  import Game.JoinLobby, only: [execute: 2]

  alias Auth.Account
  alias Auth.Account.InMemory, as: InMemoryAccount
  alias Game.Lobby
  alias Game.Lobby.InMemory, as: InMemoryLobby

  setup do
    start_supervised!(InMemoryLobby)
    start_supervised!(InMemoryAccount)
    :ok
  end

  @gateways [lobby_gateway: InMemoryLobby, account_gateway: InMemoryAccount]

  defp fixture(fixture_type, custom_fields \\ [])

  defp fixture(:account, custom_fields) do
    account = struct!(%Account{provider: :foo, uid: "123"}, custom_fields)
    InMemoryAccount.set(account)
    account
  end

  defp fixture(:lobby, custom_fields) do
    lobby = struct!(%Lobby{name: "My party", uid: "456", players: []}, custom_fields)
    InMemoryLobby.set(lobby)
    lobby
  end

  test "joining a non existent lobby, with an non existent account, without a name" do
    args = %{lobby_id: "456", account_id: "foo:123", player_name: ""}

    assert execute(args, @gateways) ==
             {:error, [lobby: [:not_found], player: [:not_found, :must_have_name]]}
  end

  test "joining an existent lobby, with an non existing account, without a name" do
    args = %{lobby_id: fixture(:lobby).uid, account_id: "foo:123", player_name: ""}

    assert execute(args, @gateways) ==
             {:error, [{:player, [:not_found, :must_have_name]}]}
  end

  test "joining a non existent lobby, with an existing account, without a name" do
    account_id = fixture(:account) |> Account.key()
    args = %{lobby_id: "456", account_id: account_id, player_name: ""}

    assert execute(args, @gateways) ==
             {:error, [{:lobby, [:not_found]}, {:player, [:must_have_name]}]}
  end

  test "joining a non existent lobby, with an non existing account, with a name" do
    args = %{lobby_id: "456", account_id: "foo:123", player_name: "Alice"}

    assert execute(args, @gateways) ==
             {:error, [{:lobby, [:not_found]}, {:player, [:not_found]}]}
  end

  test "joining an existent lobby, with an existing account, with a name" do
    lobby_id = fixture(:lobby).uid
    account_id = fixture(:account) |> Account.key()
    args = %{lobby_id: lobby_id, account_id: account_id, player_name: "Alice"}

    assert execute(args, @gateways) == :ok
    updated_lobby = InMemoryLobby.get(lobby_id)
    refute Enum.empty?(updated_lobby.players)
  end

  test "joining a lobby twice with a different name and same account" do
    lobby_id = fixture(:lobby).uid
    account_id = fixture(:account) |> Account.key()
    first_args = %{lobby_id: lobby_id, account_id: account_id, player_name: "Alice"}
    second_args = %{lobby_id: lobby_id, account_id: account_id, player_name: "Bob"}

    assert execute(first_args, @gateways) == :ok
    assert execute(second_args, @gateways) == {:error, [player: [:already_joined]]}
  end

  test "joining a lobby twice with a same name and different account" do
    lobby_id = fixture(:lobby).uid
    account_id = fixture(:account) |> Account.key()
    second_account_id = fixture(:account, provider: :bar) |> Account.key()
    first_args = %{lobby_id: lobby_id, account_id: account_id, player_name: "Alice"}
    second_args = %{lobby_id: lobby_id, account_id: second_account_id, player_name: "Alice"}

    assert execute(first_args, @gateways) == :ok
    assert execute(second_args, @gateways) == {:error, [player: [:name_taken]]}
  end
end
