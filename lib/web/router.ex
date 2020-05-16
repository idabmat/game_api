defmodule Web.Router do
  use Web, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/" do
    pipe_through(:api)

    get("/health", Web.Controllers.HealthCheck, :show)
  end
end
