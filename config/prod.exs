import Config

config :game_api, Web.Endpoint,
  url: [host: System.get_env("APP_NAME") <> ".gigalixirapp.com", port: 443]

config :logger, level: :info
