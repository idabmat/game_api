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
      case Map.get(lobbies, lobby.uid, nil) do
        nil -> {:ok, Map.put(lobbies, lobby.uid, lobby)}
        _ -> {:error, lobbies}
      end
    end)
  end

  def size do
    Agent.get(__MODULE__, &map_size/1)
  end
end
