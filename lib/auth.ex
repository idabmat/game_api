defmodule Auth do
  @moduledoc """
  Top-level module for managing player accounts
  """

  alias Auth.Account
  alias Auth.Account.InMemory
  alias Auth.UseCase.CreateSession

  @spec create_session(map()) :: {:ok, Account.t()} | {:error, [String.t()]}
  def create_session(data), do: CreateSession.execute(data, account_gateway: InMemory)
end
