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

  @gateways [lobby_gateway: InMemoryLobby]

  defp fixture(fixture_type, custom_fields \\ [])

  defp fixture(:account, custom_fields) do
    account = struct!(%Account{provider: :foo, uid: "123"}, custom_fields)
    InMemoryAccount.set(account)
    account
  end

  defp fixture(:lobby, custom_fields) do
    lobby = struct!(%Lobby{name: "My party", uid: "456", players: []}, custom_fields)
    @gateways[:lobby_gateway].set(lobby)
    lobby
  end

  test "joining a non existent lobby, without a name" do
    account = fixture(:account)
    args = %{lobby_id: "456", account: account, player_name: ""}

    assert execute(args, @gateways) == {:error, [lobby: [:not_found], player: [:must_have_name]]}
  end

  test "joining a non existent lobby, with a name" do
    account = fixture(:account)
    args = %{lobby_id: "456", account: account, player_name: "Alice"}

    assert execute(args, @gateways) == {:error, [lobby: [:not_found]]}
  end

  test "joining an existent lobby, without a name" do
    account = fixture(:account)
    args = %{lobby_id: fixture(:lobby).uid, account: account, player_name: ""}

    assert execute(args, @gateways) == {:error, [player: [:must_have_name]]}
  end

  test "joining an existent lobby, with a name" do
    lobby_id = fixture(:lobby).uid
    account = fixture(:account)
    args = %{lobby_id: lobby_id, account: account, player_name: "Alice"}

    assert {:ok, lobby} = execute(args, @gateways)
    updated_lobby = InMemoryLobby.get(lobby_id)
    assert lobby == updated_lobby
  end

  test "joining a lobby twice with a different name and same account" do
    lobby_id = fixture(:lobby).uid
    account = fixture(:account)
    first_args = %{lobby_id: lobby_id, account: account, player_name: "Alice"}
    second_args = %{lobby_id: lobby_id, account: account, player_name: "Bob"}

    assert {:ok, _lobby} = execute(first_args, @gateways)
    assert execute(second_args, @gateways) == {:error, [player: [:already_joined]]}
  end

  test "joining a lobby twice with a same name and different account" do
    lobby_id = fixture(:lobby).uid
    account = fixture(:account)
    second_account = fixture(:account, provider: :bar)
    first_args = %{lobby_id: lobby_id, account: account, player_name: "Alice"}
    second_args = %{lobby_id: lobby_id, account: second_account, player_name: "Alice"}

    assert {:ok, _lobby} = execute(first_args, @gateways)
    assert execute(second_args, @gateways) == {:error, [player: [:name_taken]]}
  end
end
