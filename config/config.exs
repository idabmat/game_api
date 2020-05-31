import Config

config :game_api, Web.Endpoint,
  render_errors: [view: Web.Views.Error, accepts: ~w(json), layout: false],
  server: true

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :ueberauth, Ueberauth,
  providers: [
    google: {Ueberauth.Strategy.Google, []}
  ]

config :game_api, Auth,
  account_gateway: Auth.Account.InMemory,
  token_gateway: Auth.Token.Guardian

config :game_api, Game,
  lobby_gateway: Game.Lobby.InMemory,
  id_gateway: GameApi.ID.UUID

import_config "#{Mix.env()}.exs"
