defprotocol Auth.CreateToken do
  @fallback_to_any true

  @spec execute(any(), token_gateway: module()) :: {:ok, String.t()} | {:error, atom()}
  def execute(account, options \\ [])
end

defimpl Auth.CreateToken, for: Any do
  def execute(_account, _options), do: {:error, :account_not_found}
end

defimpl Auth.CreateToken, for: Auth.Account do
  def execute(account, token_gateway: token_gateway) do
    case token_gateway.set(account) do
      token when is_binary(token) -> {:ok, token}
      _ -> {:error, :account_not_found}
    end
  end

  def execute(any, options), do: Auth.CreateToken.Any.execute(any, options)
end
