defmodule GameApi do
  @moduledoc """
  Main application module
  """

  use Application
  alias Vapor.Provider.{Dotenv, Env}

  def start(_type, _args) do
    config = setup_vapor()

    children = [
      {Web.Endpoint, url: [host: config.host]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Web.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp setup_vapor do
    providers = [
      %Dotenv{},
      %Env{
        bindings: [
          {:host, "APP_NAME", default: "localhost", map: &(&1 <> ".gigalixirapp.com")}
        ]
      }
    ]

    Vapor.load!(providers)
  end
end
