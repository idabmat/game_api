defprotocol Auth.CreateSession do
  @fallback_to_any true
  @spec execute(map(), account_gateway: module()) :: {:ok, map()} | {:error, [String.t()]}
  def execute(auth_data, options \\ [])
end

defimpl Auth.CreateSession, for: Any do
  def execute(_auth_data, _options \\ []), do: {:error, ["Bad request"]}
end

defimpl Auth.CreateSession, for: Ueberauth.Failure do
  def execute(%{errors: errors, provider: :google}, _options) do
    {:error, for(%{message: message} <- errors, do: message)}
  end

  def execute(any, options), do: Auth.CreateSession.Any.execute(any, options)
end

defimpl Auth.CreateSession, for: Ueberauth.Auth do
  alias Auth.Account

  def execute(%{info: info, provider: :google, uid: uid}, account_gateway: account_gateway) do
    profile = %Account{email: info.email, image: info.image, uid: uid, provider: :google}
    account_gateway.set(profile)
    {:ok, profile}
  end

  def execute(any, options), do: Auth.CreateSession.Any.execute(any, options)
end
