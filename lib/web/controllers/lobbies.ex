defmodule Web.Controllers.Lobbies do
  @moduledoc """
  CRUD controller for the Lobby resource
  """

  use Web, :controller

  def create(conn, params) do
    account = conn.private.guardian_default_resource

    args = %{
      lobby_name: params["lobby_name"],
      player_name: params["player_name"],
      account: account
    }

    case Game.create_lobby(args) do
      {:ok, lobby} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(201, Jason.encode!(lobby))

      {:errors, reasons} ->
        errors = Enum.into(reasons, %{})

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Jason.encode!(%{errors: errors}))
    end
  end

  def update(conn, params) do
    account = conn.private.guardian_default_resource

    args = %{
      lobby_id: params["lobby_id"],
      player_name: params["player_name"],
      account: account
    }

    case Game.join_lobby(args) do
      {:ok, lobby} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(lobby))

      {:error, reasons} ->
        errors = Enum.into(reasons, %{})

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(404, Jason.encode!(%{errors: errors}))
    end
  end
end
