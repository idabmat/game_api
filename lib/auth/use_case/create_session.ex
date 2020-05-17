defprotocol Auth.UseCase.CreateSession do
  @fallback_to_any true
  @spec execute(map()) :: {:ok, map()} | {:error, [String.t()]}
  def execute(_auth_data)
end

defimpl Auth.UseCase.CreateSession, for: Any do
  def execute(_auth_data), do: {:error, ["Bad request"]}
end

defimpl Auth.UseCase.CreateSession, for: Ueberauth.Failure do
  def execute(%{errors: errors, provider: :google}) do
    {:error, for(%{message: message} <- errors, do: message)}
  end

  def execute(any), do: Auth.UseCase.CreateSession.Any.execute(any)
end

defimpl Auth.UseCase.CreateSession, for: Ueberauth.Auth do
  def execute(%{info: info, provider: :google, uid: uid}) do
    {:ok, %{email: info.email, image: info.image, uid: uid}}
  end

  def execute(any), do: Auth.UseCase.CreateSession.Any.execute(any)
end
