defmodule Game.CreateLobby do
  @moduledoc """
  Creating a named lobby for a given account.
  """

  alias Auth.Account
  alias Ecto.Changeset
  alias Game.Lobby
  alias Game.Player

  @spec execute(String.t(), String.t(), Account.t(),
          lobby_gateway: module(),
          id_gateway: module()
        ) ::
          {:ok, Lobby.t()} | {:error, [{atom(), [atom()]}]}
  def execute(lobby_name, player_name, %Account{} = account,
        lobby_gateway: lobby_gateway,
        id_gateway: id_gateway
      )
      when byte_size(lobby_name) != 0 and byte_size(player_name) != 0 do
    lobby = %Lobby{
      uid: id_gateway.generate(),
      name: lobby_name,
      players: [
        %Player{name: player_name, account_id: {account.provider, account.uid}}
      ]
    }

    insert_lobby(lobby, lobby_gateway)
  end

  def execute(lobby_name, player_name, _account, _gateways) do
    data = %{}
    types = %{lobby_name: :string, player_name: :string}
    params = %{lobby_name: lobby_name, player_name: player_name}

    errors =
      {data, types}
      |> Changeset.cast(params, Map.keys(types))
      |> Changeset.validate_required([:lobby_name, :player_name], message: :cant_be_blank)
      |> Map.get(:errors, [])
      |> Enum.map(fn {field, {error, _validation}} -> {field, [error]} end)

    {:error, errors}
  end

  @spec insert_lobby(Lobby.t(), module()) :: {:ok, Lobby.t()} | {:error, keyword([atom()])}
  defp insert_lobby(lobby, lobby_gateway) do
    case lobby_gateway.get(lobby.uid) do
      nil ->
        lobby_gateway.set(lobby)
        {:ok, lobby}

      _ ->
        {:error, [{:other, [:try_again]}]}
    end
  end
end
