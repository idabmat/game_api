defmodule GameApi do
  @moduledoc """
  Main application module
  """

  use Application

  @auth_config Application.get_env(:game_api, Auth)
  @game_config Application.get_env(:game_api, Game)

  def start(_type, _args) do
    config = Configuration.load!()

    children = [
      {Web.Endpoint, url: [host: config.phoenix[:host]]},
      @auth_config[:account_gateway],
      @game_config[:lobby_gateway]
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Web.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
