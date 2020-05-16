defmodule Web.Controllers.Auth do
  @moduledoc """
  Controller for authentication requests
  """
  use Web, :controller
  plug(Ueberauth)

  def request(conn, _params) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{}))
  end

  def callback(%{assigns: %{ueberauth_auth: _auth}} = conn, _params) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{status: "Signed in"}))
  end

  def callback(conn, _params) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(400, Jason.encode!(%{status: "Failed to authenticate"}))
  end
end
