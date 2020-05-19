defmodule Auth.CreateToken do
  @moduledoc false

  alias Auth.Account

  @spec execute(Account.t(), token_gateway: module()) :: {:ok, String.t()} | {:error, String.t()}
  def execute(%Account{} = account, token_gateway: token_gateway) do
    token = token_gateway.set(account)
    {:ok, token}
  end

  def execute(_, _), do: {:error, "Account not found"}
end
