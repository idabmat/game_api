defmodule Auth.Token.Guardian do
  @moduledoc false

  use Guardian, otp_app: :game_api

  alias Auth.Account
  alias Auth.Token
  alias Vapor.Provider.{Dotenv, Env}

  @behaviour Token

  @impl Token
  def set(%Account{} = account) do
    config = setup_vapor()

    {:ok, token, _claims} = encode_and_sign(account, %{}, secret: config.guardian_secret_key)
    token
  end

  @impl Guardian
  def subject_for_token(%Account{} = account, _claims), do: {:ok, Account.key(account)}
  def subject_for_token(_, _), do: {:error, :account_not_found}

  @impl Guardian
  def resource_from_claims(claims) do
    {provider, uid} =
      claims["sub"]
      |> String.split(":")
      |> Enum.into({})

    Account.InMemory.get({provider, uid})
  end

  defp setup_vapor do
    providers = [
      %Dotenv{},
      %Env{
        bindings: [
          {:guardian_secret_key, "GUARDIAN_SECRET_KEY"}
        ]
      }
    ]

    Vapor.load!(providers)
  end
end
