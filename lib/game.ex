defmodule Game do
  @moduledoc """
  Top-level module for managing games
  """

  alias Auth.Account
  alias Game.CreateLobby
  alias Game.Lobby

  @spec create_lobby(String.t(), String.t(), Account.t()) ::
          {:ok, Lobby.t()} | {:error, [{atom(), [atom()]}]}
  def create_lobby(lobby_name, player_name, account),
    do:
      CreateLobby.execute(lobby_name, player_name, account,
        lobby_gateway: game_gateways(:lobby_gateway),
        id_gateway: game_gateways(:id_gateway)
      )

  defp game_gateways(gateway) do
    Application.get_env(:game_api, __MODULE__)[gateway]
  end
end
