defmodule Web.Router do
  use Web, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/" do
    pipe_through(:api)

    get("/", Web.Controllers.Simple, :show)
    post("/", Web.Controllers.Simple, :create)
  end
end
