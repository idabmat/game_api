defmodule Configuration do
  @moduledoc false

  defstruct [:name]

  alias Vapor.Provider.{Dotenv, Env, Group}

  def load! do
    config = Vapor.load!(providers())
    inject_config(config)
    config
  end

  def unload do
    Application.delete_env(:ueberauth, Ueberauth.Strategy.Google.OAuth)
    Application.delete_env(:game_api, Auth.Token.Guardian)
  end

  defp inject_config(config) do
    Application.put_env(:ueberauth, Ueberauth.Strategy.Google.OAuth,
      client_id: config.google[:client_id],
      client_secret: config.google[:client_secret]
    )

    Application.put_env(:game_api, Auth.Token.Guardian,
      issuer: "game_api",
      secret_key: config.guardian[:secret_key]
    )
  end

  defp providers do
    [
      %Dotenv{},
      %Group{
        name: :phoenix,
        providers: phoenix_config()
      },
      %Group{
        name: :google,
        providers: google_config()
      },
      %Group{
        name: :guardian,
        providers: guardian_config()
      },
      %Group{
        name: :gateways,
        providers: gateways_config()
      }
    ]
  end

  defp phoenix_config do
    [
      %Env{
        bindings: [
          {:host, "HOST", default: "localhost"}
        ]
      }
    ]
  end

  defp google_config do
    [
      %Env{
        bindings: [
          {:client_id, "GOOGLE_CLIENT_ID"},
          {:client_secret, "GOOGLE_CLIENT_SECRET"}
        ]
      }
    ]
  end

  defp guardian_config do
    [
      %Env{
        bindings: [
          {:secret_key, "GUARDIAN_SECRET_KEY"}
        ]
      }
    ]
  end

  defp gateways_config do
    [
      %Env{
        bindings: [
          {:token, "AUTH_TOKEN_GATEWAY", default: Auth.Token.Guardian, map: &string_to_module/1},
          {:account, "AUTH_ACCOUNT_GATEWAY",
           default: Auth.Account.InMemory, map: &string_to_module/1}
        ]
      }
    ]
  end

  defp string_to_module(string) do
    String.to_existing_atom("Elixir.#{string}")
  end
end
