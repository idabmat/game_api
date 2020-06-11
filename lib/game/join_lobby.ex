defmodule Game.JoinLobby do
  @moduledoc """
  Joining an existing lobby
  """

  alias Auth.Account
  alias Ecto.Changeset
  alias Game.Lobby
  alias Game.Player

  @type args :: %{lobby_id: String.t(), player_name: String.t(), account_id: String.t()}
  @type errors :: [lobby: [atom()], player: [atom()]]
  @type gateways :: [lobby_gateway: module(), account_gateway: module()]

  @spec execute(args(), gateways()) :: :ok | {:error, errors()}
  def execute(args, gateways) do
    account = get_resource(args.account_id, gateways[:account_gateway])
    lobby = get_resource(args.lobby_id, gateways[:lobby_gateway])

    case validate(lobby, account, args.player_name) do
      [] -> insert_player(lobby, args.account_id, args.player_name, gateways[:lobby_gateway])
      errors -> {:error, errors}
    end
  end

  defp get_resource(resource_id, resource_gateway) do
    resource_gateway.get(resource_id)
  end

  defp validate(lobby, account, player_name) do
    player_errors = validate_player(account, player_name)
    lobby_errors = validate_lobby(lobby)

    [lobby: lobby_errors, player: player_errors]
    |> Enum.reject(fn {_key, value} -> Enum.empty?(value) end)
  end

  defp insert_player(lobby, account_id, player_name, lobby_gateway) do
    player = %Player{name: player_name, account_id: account_id}
    updated_lobby = %Lobby{lobby | players: [player | lobby.players]}

    case lobby_gateway.set(updated_lobby) do
      :ok -> :ok
      {:error, :duplicate_account} -> {:error, [player: [:already_joined]]}
      {:error, :duplicate_name} -> {:error, [player: [:name_taken]]}
    end
  end

  @spec validate_player(nil | Account.t(), nil | String.t()) :: [atom()]
  defp validate_player(account, name) do
    data = %{}
    types = %{account: :map, name: :string}
    params = %{account: account, name: name}
    {data, types}
    |> Changeset.cast(params, Map.keys(types))
    |> Changeset.validate_required(:name, message: :must_have_name)
    |> Changeset.validate_required(:account, message: :not_found)
    |> Map.get(:errors, [])
    |> Enum.map(fn {_field, {error, _validations}} -> error end)
  end

  @spec validate_lobby(nil | Lobby.t()) :: [atom()]
  defp validate_lobby(lobby) do
    data = %{}
    types = %{lobby: :map}
    params = %{lobby: lobby}
    {data, types}
    |> Changeset.cast(params, Map.keys(types))
    |> Changeset.validate_required(:lobby, message: :not_found)
    |> Map.get(:errors, [])
    |> Enum.map(fn {_field, {error, _validations}} -> error end)
  end
end
