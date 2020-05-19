defmodule Auth do
  @moduledoc """
  Top-level module for managing player accounts
  """

  alias Auth.Account
  alias Auth.Account.InMemory
  alias Auth.CreateSession
  alias Auth.CreateToken
  alias Auth.Token.Guardian

  @spec create_session(map()) :: {:ok, Account.t()} | {:error, [String.t()]}
  def create_session(data), do: CreateSession.execute(data, account_gateway: InMemory)

  @spec create_token(any()) :: {:ok, String.t()} | {:error, [String.t()]}
  def create_token(account), do: CreateToken.execute(account, token_gateway: Guardian)
end
