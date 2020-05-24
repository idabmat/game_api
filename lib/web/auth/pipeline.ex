defmodule Web.Auth.Pipeline do
  @moduledoc """
  Guardian Plug to authenticate requests.
  """

  use Guardian.Plug.Pipeline,
    otp_app: :game_api,
    module: Auth.Token.Guardian,
    error_handler: Web.Auth.ErrorHandler

  plug(Guardian.Plug.VerifyHeader)
  plug(Guardian.Plug.EnsureAuthenticated)
end
