defmodule Game.CreateLobbyTest do
  use ExUnit.Case, async: false

  alias Game.Lobby.InMemory
  alias GameApi.ID.Constant
  import Game.CreateLobby, only: [execute: 2]

  setup do
    start_supervised!(InMemory)
    start_supervised!({Constant, [ids: ["1", "2", "2"]]})
    account = %Auth.Account{provider: :foo, uid: "123"}
    {:ok, %{account: account}}
  end

  defp test_gateways, do: [lobby_gateway: InMemory, id_gateway: Constant]

  test "Creating a lobby without a lobby name nor an player name", %{account: account} do
    args = %{lobby_name: "", player_name: "", account: account}

    assert {:errors, errors} = execute(args, test_gateways())
    assert {:player_name, [:cant_be_blank]} in errors
    assert {:lobby_name, [:cant_be_blank]} in errors
    assert InMemory.size() == 0
  end

  test "Creating a lobby without a player name", %{account: account} do
    args = %{lobby_name: "My game", player_name: "", account: account}

    assert {:errors, [error]} = execute(args, test_gateways())
    assert {:player_name, [:cant_be_blank]} == error
    assert InMemory.size() == 0
  end

  test "Creating a lobby without a lobby name", %{account: account} do
    args = %{lobby_name: "", player_name: "Alice", account: account}

    assert {:errors, [error]} = execute(args, test_gateways())
    assert {:lobby_name, [:cant_be_blank]} == error
    assert InMemory.size() == 0
  end

  test "Creating a lobby with a lobby and a player name", %{account: account} do
    args = %{lobby_name: "My game", player_name: "Alice", account: account}

    assert {:ok, lobby} = execute(args, test_gateways())
    assert lobby.name == "My game"
    assert [player] = lobby.players
    assert player.name == "Alice"
    assert InMemory.size() == 1
  end

  test "Creating a second lobby with the same name", %{account: account} do
    args = %{lobby_name: "My game", player_name: "Alice", account: account}

    execute(args, lobby_gateway: InMemory, id_gateway: Constant)

    assert {:ok, duplicate} = execute(args, test_gateways())
    assert InMemory.size() == 2
  end

  test "When there are ID collisions", %{account: account} do
    # Skip the first facked id value
    Constant.generate()
    args = %{lobby_name: "My game", player_name: "Alice", account: account}

    execute(args, lobby_gateway: InMemory, id_gateway: Constant)

    assert {:errors, [error]} = execute(args, test_gateways())
    assert {:other, [:try_again]} == error
    assert InMemory.size() == 1
  end
end
