defmodule Web.Router do
  use Web, :router

  pipeline :api do
    plug(:accepts, ["json"])
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
end
