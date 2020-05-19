defmodule Auth.CreateToken do
  @moduledoc false

  alias Auth.Account

  @spec execute(Account.t(), token_gateway: module()) :: {:ok, String.t()} | {:error, String.t()}
  def execute(account, token_gateway: token_gateway) do
    token_gateway.set(account)
  end
end
