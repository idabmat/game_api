defmodule Game.Lobby.InMemory do
  @moduledoc """
  Implementation of a lobby gateway in memory
  """

  use Agent
  alias Game.Lobby

  @behaviour Lobby

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @impl Lobby
  def set(lobby) do
    Agent.get_and_update(__MODULE__, fn lobbies ->
      players = lobby.players

      with {^players, :account} <- {Enum.uniq_by(players, & &1.account_id), :account},
           {^players, :name} <- {Enum.uniq_by(players, & &1.name), :name} do
        {:ok, Map.put(lobbies, lobby.uid, lobby)}
      else
        {_, :account} -> {{:error, :duplicate_account}, lobbies}
        {_, :name} -> {{:error, :duplicate_name}, lobbies}
      end
    end)
  end

  @impl Lobby
  def get(lobby_id) do
    Agent.get(__MODULE__, &Map.get(&1, lobby_id, nil))
  end

  def size do
    Agent.get(__MODULE__, &map_size/1)
  end
end
