import Config

config :game_api, Web.Endpoint,
  http: [port: 4000],
  url: [port: 443]

config :logger, level: :info
