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

import_config "#{Mix.env()}.exs"
