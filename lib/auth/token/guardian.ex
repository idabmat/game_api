defmodule Auth.Token.Guardian do
  @moduledoc """
  Implementation of the Auth.Token behaviour based on the Guardian library.
  """

  use Guardian, otp_app: :game_api

  alias Auth.Account
  alias Auth.Token

  @behaviour Token

  @impl Token
  def set(%Account{} = account) do
    {:ok, token, _claims} = encode_and_sign(account, %{})
    token
  end

  @impl Guardian
  def subject_for_token(%Account{} = account, _claims), do: {:ok, Account.key(account)}
  def subject_for_token(_, _), do: {:error, :account_not_found}

  @impl Guardian
  def resource_from_claims(claims) do
    sub = claims["sub"]
    dependencies = Application.get_env(:game_api, Auth)
    account_gateway = dependencies[:account_gateway]

    case account_gateway.get(sub) do
      nil -> {:error, :no_resource_found}
      account -> {:ok, account}
    end
  end
end
