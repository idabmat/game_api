defmodule Web.Controllers.Secret do
  @moduledoc """
  Bogus controller to test authentication.
  """

  use Web, :controller

  def show(conn, _params) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{status: :ok}))
  end
end
