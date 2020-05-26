defmodule Game.CreateLobbyTest do
  use ExUnit.Case, async: false

  alias Game.Lobby.InMemory
  alias GameApi.ID.Constant
  import Game.CreateLobby, only: [execute: 4]

  setup do
    start_supervised!(InMemory)
    start_supervised!({Constant, [ids: ["1", "2", "2"]]})
    account = %Auth.Account{provider: :foo, uid: "123"}
    {:ok, %{account: account}}
  end

  test "Creating a lobby without a lobby name nor an player name", %{account: account} do
    lobby_name = ""
    player_name = ""

    assert {:error, errors} =
             execute(lobby_name, player_name, account,
               lobby_gateway: InMemory,
               id_gateway: Constant
             )

    assert {:player_name, [:cant_be_blank]} in errors
    assert {:lobby_name, [:cant_be_blank]} in errors
    assert InMemory.size() == 0
  end

  test "Creating a lobby without a player name", %{account: account} do
    lobby_name = "My game"
    player_name = ""

    assert {:error, [error]} =
             execute(lobby_name, player_name, account,
               lobby_gateway: InMemory,
               id_gateway: Constant
             )

    assert {:player_name, [:cant_be_blank]} == error
    assert InMemory.size() == 0
  end

  test "Creating a lobby without a lobby name", %{account: account} do
    lobby_name = ""
    player_name = "Alice"

    assert {:error, [error]} =
             execute(lobby_name, player_name, account,
               lobby_gateway: InMemory,
               id_gateway: Constant
             )

    assert {:lobby_name, [:cant_be_blank]} == error
    assert InMemory.size() == 0
  end

  test "Creating a lobby with a lobby and a player name", %{account: account} do
    lobby_name = "My game"
    player_name = "Alice"

    assert {:ok, lobby} =
             execute(lobby_name, player_name, account,
               lobby_gateway: InMemory,
               id_gateway: Constant
             )

    assert lobby.name == "My game"
    assert [player] = lobby.players
    assert player.name == "Alice"
    assert InMemory.size() == 1
  end

  test "Creating a second lobby with the same name", %{account: account} do
    lobby_name = "My game"
    player_name = "Alice"

    execute(lobby_name, player_name, account,
      lobby_gateway: InMemory,
      id_gateway: Constant
    )

    assert {:ok, duplicate} =
             execute(lobby_name, player_name, account,
               lobby_gateway: InMemory,
               id_gateway: Constant
             )

    assert InMemory.size() == 2
  end

  test "When there are ID collisions", %{account: account} do
    # Skip the first facked id value
    Constant.generate()
    lobby_name = "My game"
    player_name = "Alice"

    execute(lobby_name, player_name, account,
      lobby_gateway: InMemory,
      id_gateway: Constant
    )

    assert {:error, [error]} =
             execute(lobby_name, player_name, account,
               lobby_gateway: InMemory,
               id_gateway: Constant
             )

    assert {:other, [:try_again]} == error
    assert InMemory.size() == 1
  end
end
