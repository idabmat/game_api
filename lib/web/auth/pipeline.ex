defmodule Web.Auth.Pipeline do
  @moduledoc false

  use Guardian.Plug.Pipeline, otp_app: :game_api, module: Auth.Token.Guardian, error_handler: Web.Auth.ErrorHandler
  plug(Guardian.Plug.VerifyHeader)
  plug(Guardian.Plug.EnsureAuthenticated)
end
