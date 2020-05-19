defmodule Auth.CreateToken do
  @moduledoc false

  alias Auth.Account

  @spec execute(any(), token_gateway: module()) :: {:ok, String.t()} | {:error, atom()}
  def execute(%Account{} = account, token_gateway: token_gateway) do
    case token_gateway.set(account) do
      token when is_binary(token) -> {:ok, token}
      _ -> {:error, :account_not_found}
    end
  end

  def execute(_account, _options), do: {:error, :account_not_found}
end
