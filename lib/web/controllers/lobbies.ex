defmodule Web.Controllers.Lobbies do
  @moduledoc """
  CRUD controller for the Lobby resource
  """

  use Web, :controller

  def create(conn, params) do
    account = conn.private.guardian_default_resource

    case Game.create_lobby(params["lobby_name"], params["player_name"], account) do
      {:ok, lobby} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(201, Jason.encode!(lobby))

      {:error, reasons} ->
        errors = Enum.into(reasons, %{})

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Jason.encode!(%{errors: errors}))
    end
  end
end
