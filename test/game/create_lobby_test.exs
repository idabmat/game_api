defmodule Game.CreateLobbyTest do
  use ExUnit.Case, async: false

  import Game.CreateLobby, only: [execute: 2]

  alias Auth.Account
  alias Game.Lobby.InMemory
  alias GameApi.ID.Constant

  setup do
    start_supervised!(InMemory)
    start_supervised!({Constant, [ids: ["1", "2", "2"]]})
    :ok
  end

  @gateways [lobby_gateway: InMemory, id_gateway: Constant]

  defp fixture(:account), do: %Account{provider: :foo, uid: "123"}

  test "Creating a lobby without a lobby name nor an player name" do
    args = %{lobby_name: "", player_name: "", account: fixture(:account)}

    assert {:errors, errors} = execute(args, @gateways)
    assert {:player_name, [:cant_be_blank]} in errors
    assert {:lobby_name, [:cant_be_blank]} in errors
    assert InMemory.size() == 0
  end

  test "Creating a lobby without a player name" do
    args = %{lobby_name: "My game", player_name: "", account: fixture(:account)}

    assert {:errors, [error]} = execute(args, @gateways)
    assert {:player_name, [:cant_be_blank]} == error
    assert InMemory.size() == 0
  end

  test "Creating a lobby without a lobby name" do
    args = %{lobby_name: "", player_name: "Alice", account: fixture(:account)}

    assert {:errors, [error]} = execute(args, @gateways)
    assert {:lobby_name, [:cant_be_blank]} == error
    assert InMemory.size() == 0
  end

  test "Creating a lobby with a lobby and a player name" do
    args = %{lobby_name: "My game", player_name: "Alice", account: fixture(:account)}

    assert {:ok, lobby} = execute(args, @gateways)
    assert lobby.name == "My game"
    assert [player] = lobby.players
    assert player.name == "Alice"
    assert InMemory.size() == 1
  end

  test "Creating a second lobby with the same name" do
    args = %{lobby_name: "My game", player_name: "Alice", account: fixture(:account)}

    execute(args, @gateways)

    assert {:ok, duplicate} = execute(args, @gateways)
    assert InMemory.size() == 2
  end

  test "When there are ID collisions" do
    # Skip the first facked id value
    Constant.generate()
    args = %{lobby_name: "My game", player_name: "Alice", account: fixture(:account)}

    execute(args, @gateways)

    assert {:errors, [error]} = execute(args, @gateways)
    assert {:other, [:try_again]} == error
    assert InMemory.size() == 1
  end
end
