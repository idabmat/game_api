import Config

config :game_api, Web.Endpoint,
  http: [port: 4000],
  url: [port: 443],
  force_ssl: [hsts: true]

config :logger, level: :info
