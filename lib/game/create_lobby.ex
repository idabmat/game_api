defmodule Game.CreateLobby do
  @moduledoc """
  Creating a named lobby for a given account.
  """

  alias Auth.Account
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

    case lobby_gateway.get(lobby.uid) do
      nil ->
        lobby_gateway.set(lobby)
        {:ok, lobby}

      _ ->
        {:error, [{:other, [:try_again]}]}
    end
  end

  def execute(lobby_name, player_name, _account, _gateways) do
    lobby_errors = validate(lobby_name)
    player_errors = validate(player_name)

    errors =
      [{:lobby_name, lobby_errors.errors}, {:player_name, player_errors.errors}]
      |> Enum.reject(fn {_key, errors} -> Enum.empty?(errors) end)

    {:error, errors}
  end

  @spec validate(any()) :: %{value: any(), errors: [atom()]}
  defp validate(value) do
    %{value: value, errors: []}
    |> validate_presence()
    |> validate_filled()
  end

  @spec validate_presence(%{value: any(), errors: [atom()]}) :: %{value: any(), errors: [atom()]}
  defp validate_presence(%{value: nil, errors: errors}),
    do: %{value: nil, errors: [:required | errors]}

  defp validate_presence(%{value: value, errors: errors}), do: %{value: value, errors: errors}

  @spec validate_filled(%{value: any(), errors: [atom()]}) :: %{value: any(), errors: [atom()]}
  defp validate_filled(%{value: "", errors: errors}),
    do: %{value: "", errors: [:cant_be_blank | errors]}

  defp validate_filled(%{value: value, errors: errors}), do: %{value: value, errors: errors}
end
