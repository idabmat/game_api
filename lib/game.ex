defmodule Game do
  @moduledoc """
  Top-level module for managing games
  """

  alias Game.CreateLobby
  alias Game.JoinLobby

  @spec create_lobby(CreateLobby.args()) :: CreateLobby.response()
  def create_lobby(args) do
    CreateLobby.execute(args,
      lobby_gateway: game_gateways(:lobby_gateway),
      id_gateway: game_gateways(:id_gateway)
    )
  end

  @spec join_lobby(JoinLobby.args()) :: JoinLobby.response()
  def join_lobby(args) do
    JoinLobby.execute(args,
      lobby_gateway: game_gateways(:lobby_gateway)
    )
  end

  defp game_gateways(gateway) do
    Application.get_env(:game_api, __MODULE__)[gateway]
  end
end
