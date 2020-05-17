defmodule GameApi do
  @moduledoc """
  Main application module
  """

  use Application
  alias Vapor.Provider.{Dotenv, Env}

  def start(_type, _args) do
    config = setup_vapor()

    Application.put_env(:ueberauth, Ueberauth.Strategy.Google.OAuth, [
      client_id: config.google_client_id,
      client_secret: config.google_client_secret
    ])

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
          {:host, "HOST", default: "localhost"},
          {:google_client_id, "GOOGLE_CLIENT_ID"},
          {:google_client_secret, "GOOGLE_CLIENT_SECRET"}
        ]
      }
    ]

    Vapor.load!(providers)
  end
end
