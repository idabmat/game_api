defmodule Dependencies do
  @moduledoc """
  Setup dependencies and inject them in application environment.
  """

  alias Vapor.Provider.{Dotenv, Env, Group}

  def load! do
    deps = Vapor.load!(providers())
    inject_config(deps)
    deps
  end

  def unload do
    Application.delete_env(:game_api, Auth)
  end

  defp providers do
    [
      %Dotenv{},
      %Group{
        name: :auth,
        providers: auth_gateways()
      },
      %Group{
        name: :game,
        providers: game_gateways()
      }
    ]
  end

  defp auth_gateways do
    [
      %Env{
        bindings: [
          {:account_gateway, "AUTH_ACCOUNT_GATEWAY",
           default: Auth.Account.InMemory, map: &string_to_module/1},
          {:token_gateway, "AUTH_TOKEN_GATEWAY",
           default: Auth.Token.Guardian, map: &string_to_module/1}
        ]
      }
    ]
  end

  defp game_gateways do
    [
      %Env{
        bindings: [
          {:lobby_gateway, "GAME_LOBBY_GATEWAY",
           default: Game.Lobby.InMemory, map: &string_to_module/1},
          {:id_gateway, "GAME_ID_GATEWAY", default: GameApi.ID.UUID, map: &string_to_module/1}
        ]
      }
    ]
  end

  defp string_to_module(string) do
    String.to_existing_atom("Elixir.#{string}")
  end

  defp inject_config(config) do
    Application.put_env(:game_api, Auth,
      account_gateway: config.auth[:account_gateway],
      token_gateway: config.auth[:token_gateway]
    )

    Application.put_env(:game_api, Game,
      lobby_gateway: config.game[:lobby_gateway],
      id_gateway: config.game[:id_gateway]
    )
  end
end
