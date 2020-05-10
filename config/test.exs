use Mix.Config

config :game_api, Web.Endpoint,
  http: [port: 4002],
  debug_errors: false,
  server: false

config :logger, :level, :warn
