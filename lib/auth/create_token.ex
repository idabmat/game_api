defmodule Auth.CreateToken do
  @moduledoc """
  Use case that generates a token for a given account.
  """

  alias Auth.Account

  @spec execute(any(), token_gateway: module()) :: {:ok, String.t()} | {:error, [String.t()]}
  def execute(%Account{} = account, token_gateway: token_gateway) do
    case token_gateway.set(account) do
      token when is_binary(token) -> {:ok, token}
      _ -> {:error, ["Account not found"]}
    end
  end

  def execute(_account, _options), do: {:error, ["Account not found"]}
end
