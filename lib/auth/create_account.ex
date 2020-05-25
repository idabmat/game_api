defmodule Auth.CreateAccount do
  @moduledoc """
  Creating an account
  """

  alias Auth.Account

  @spec execute(map(), account_gateway: module()) ::
          {:ok, Account.t()} | {:error, String.t()}
  def execute(data, account_gateway: account_gateway) do
    try do
      account = struct!(Account, data)
      account_gateway.set(account)

      {:ok, account}
    rescue
      ArgumentError -> {:error, "Missing required keys [:provider, :uid]"}
    end
  end
end
