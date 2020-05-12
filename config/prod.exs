import Config

config :game_api, Web.Endpoint,
  force_ssl: [hsts: true]

config :logger, level: :info
