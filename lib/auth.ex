defmodule Auth do
  @moduledoc """
  Top-level module for managing player accounts
  """

  alias Auth.Account
  alias Auth.CreateSession
  alias Auth.CreateToken

  @spec create_session(map()) :: {:ok, Account.t()} | {:error, [String.t()]}
  def create_session(data),
    do: CreateSession.execute(data, account_gateway: auth_gateways(:account_gateway))

  @spec create_token(any()) :: {:ok, String.t()} | {:error, [String.t()]}
  def create_token(account),
    do: CreateToken.execute(account, token_gateway: auth_gateways(:token_gateway))

  defp auth_gateways(gateway) do
    Application.get_env(:game_api, __MODULE__)[gateway]
  end
end
