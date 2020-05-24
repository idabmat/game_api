defmodule GameApi do
  @moduledoc """
  Main application module
  """

  use Application

  def start(_type, _args) do
    config = Configuration.load!()

    children = [
      {Web.Endpoint, url: [host: config.phoenix[:host]]},
      Auth.Account.InMemory
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Web.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
