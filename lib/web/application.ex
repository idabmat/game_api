defmodule Web.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias Vapor.Provider.Env
  alias Web.Router

  def start(_type, _args) do
    providers = [
      %Env{
        bindings: [
          {:port, "PORT", default: 4000, map: &String.to_integer/1}
        ]
      }
    ]

    config = Vapor.load!(providers)

    children = [
      {Plug.Cowboy, scheme: :http, plug: Router, options: [port: config.port]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Web.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
