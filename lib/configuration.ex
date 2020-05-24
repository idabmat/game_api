defmodule Configuration do
  @moduledoc """
  Generate a Map with all configuration information and inject configuration
  into application environment for compatibility with some library
  """

  alias Vapor.Provider.{Dotenv, Env, Group}

  @doc """
  Loads and injects the configuration.
  """
  def load! do
    config = Vapor.load!(providers())
    inject_config(config)
    config
  end

  @doc """
  Remove injected configuration from application environment.
  """
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
end
