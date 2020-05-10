defmodule Web.Controllers.Simple do
  @moduledoc false
  use Web, :controller

  def show(conn, _params) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{response: :ok}))
  end

  def create(conn, params) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(201, Jason.encode!(%{request: params}))
  end
end
