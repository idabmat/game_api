defmodule Web.Auth.ErrorHandler do
  @moduledoc """
  Error response format for requests with failed authentication.
  """

  import Plug.Conn

  def auth_error(conn, {type, _reason}, _opts) do
    body = Jason.encode!(%{errors: %{detail: to_string(type)}})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, body)
  end
end
