defmodule Web.Controllers.Auth do
  @moduledoc """
  Controller for authentication requests
  """
  use Web, :controller
  plug(Ueberauth)

  @spec request(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def request(conn, _params) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{}))
  end

  @spec callback(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def callback(%{assigns: %{ueberauth_failure: failure}} = conn, _params) do
    {:error, errors} = Auth.create_session(failure)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(400, Jason.encode!(%{errors: errors}))
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    with {:ok, account} <- Auth.create_session(auth),
         {:ok, token} <- Auth.create_token(account) do
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, Jason.encode!(%{token: token}))
    else
      {:error, errors} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Jason.encode!(%{errors: errors}))
    end
  end
end
