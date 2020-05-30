defmodule Game.JoinLobby do
  @moduledoc """
  Joining an existing lobby
  """

  alias Auth.Account
  alias Game.Lobby
  alias Game.Player

  @type errors :: [{:lobby, [atom()]} | {:player, [atom()]}]
  @type gateways :: [lobby_gateway: module(), account_gateway: module()]

  @spec execute(String.t(), String.t(), String.t(), gateways()) ::
          {:error, errors()}
  def execute(lobby_id, player_name, account_id, gateways) do
    account = get_resource(account_id, gateways[:account_gateway])
    lobby = get_resource(lobby_id, gateways[:lobby_gateway])
    player_errors = validate_player(account, player_name)
    lobby_errors = validate_lobby(lobby)

    errors =
      [{:lobby, lobby_errors}, {:player, player_errors}]
      |> Enum.reject(fn {_key, value} -> Enum.empty?(value) end)

    case errors do
      [] -> insert_player(lobby, account_id, player_name, gateways[:lobby_gateway])
      _ -> {:error, errors}
    end
  end

  defp get_resource(resource_id, resource_gateway) do
    resource_gateway.get(resource_id)
  end

  defp insert_player(lobby, account_id, player_name, lobby_gateway) do
    player = %Player{name: player_name, account_id: account_id}
    updated_lobby = %Lobby{lobby | players: [player | lobby.players]}

    case lobby_gateway.set(updated_lobby) do
      :ok -> :ok
      _ -> {:error, [{:player, [:already_joined]}]}
    end
  end

  @spec validate_player(nil | Account.t(), nil | String.t()) :: [atom()]
  defp validate_player(nil, nil), do: [:not_found, :must_have_name]
  defp validate_player(nil, ""), do: [:not_found, :must_have_name]
  defp validate_player(_, nil), do: [:must_have_name]
  defp validate_player(_, ""), do: [:must_have_name]
  defp validate_player(nil, _), do: [:not_found]
  defp validate_player(_, _), do: []

  @spec validate_lobby(nil | Lobby.t()) :: [atom()]
  defp validate_lobby(nil), do: [:not_found]
  defp validate_lobby(_), do: []
end
