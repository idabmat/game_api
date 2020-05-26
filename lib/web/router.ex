defmodule Web.Router do
  use Web, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :api_auth do
    plug(Web.Auth.Pipeline)
  end

  scope "/auth" do
    pipe_through(:api)

    get("/:provider", Web.Controllers.Auth, :request)
    get("/:provider/callback", Web.Controllers.Auth, :callback)
  end

  scope "/" do
    pipe_through(:api)

    get("/health", Web.Controllers.HealthCheck, :show)
  end

  scope "/" do
    pipe_through([:api, :api_auth])

    get("/sekret", Web.Controllers.Secret, :show)
    post("/lobbies", Web.Controllers.Lobbies, :create)
  end
end
