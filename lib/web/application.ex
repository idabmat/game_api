defmodule Web.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias Vapor.Provider.Env

  def start(_type, _args) do
    config = setup_vapor()

    children = [
      {Web.Endpoint, url: [host: config.host, port: config.port]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Web.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp setup_vapor() do
    providers = [
      %Env{
        bindings: [
          {:port, "PORT", default: 4000, map: &String.to_integer/1},
          {:host, "APP_NAME", required: false,  map: fn
            nil -> "localhost"
            app_name -> app_name <> ".gigalixirapp.com"
          end},
        ]
      }
    ]

    Vapor.load!(providers)
  end
end
