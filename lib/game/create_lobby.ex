defmodule Game.CreateLobby do
  @moduledoc """
  Creating a named lobby for a given account.
  """

  alias Auth.Account
  alias Ecto.Changeset
  alias Game.Lobby
  alias Game.Player

  @type args :: %{lobby_name: String.t(), player_name: String.t(), account: Account.t()}
  @type errors :: [lobby_name: [atom()], player_name: [atom()], other: [atom()]]
  @type gateways :: [lobby_gateway: module(), id_gateway: module()]
  @type response :: {:ok, Lobby.t()} | {:errors, errors()}

  @spec execute(args(), gateways()) :: response()
  def execute(%{lobby_name: lobby_name, player_name: player_name} = args, gateways) do
    case validate(%{lobby_name: lobby_name, player_name: player_name}) do
      [] ->
        lobby = build_lobby(args, gateways[:id_gateway])
        insert_lobby(lobby, gateways[:lobby_gateway])

      errors ->
        {:errors, errors}
    end
  end

  @spec build_lobby(args(), module()) :: Lobby.t()
  defp build_lobby(
         %{lobby_name: lobby_name, player_name: player_name, account: account},
         id_gateway
       ) do
    %Lobby{
      uid: id_gateway.generate(),
      name: lobby_name,
      players: [
        %Player{name: player_name, account_id: {account.provider, account.uid}}
      ]
    }
  end

  @spec validate(%{lobby_name: String.t(), player_name: String.t()}) :: keyword([atom()])
  defp validate(params) do
    data = %{}
    types = %{lobby_name: :string, player_name: :string}

    {data, types}
    |> Changeset.cast(params, Map.keys(types))
    |> Changeset.validate_required([:lobby_name, :player_name], message: :cant_be_blank)
    |> Map.get(:errors, [])
    |> Enum.map(fn {field, {error, _validation}} -> {field, [error]} end)
  end

  @spec insert_lobby(Lobby.t(), module()) :: response()
  defp insert_lobby(lobby, lobby_gateway) do
    case lobby_gateway.get(lobby.uid) do
      nil ->
        lobby_gateway.set(lobby)
        {:ok, lobby}

      _ ->
        {:errors, [other: [:try_again]]}
    end
  end
end
