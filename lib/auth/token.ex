defmodule Auth.Token do
  @moduledoc """
  Behaviour module to define:
  - how to convert a resource to a token
  - how to get a resource from a token
  """

  alias Auth.Account

  @callback set(Account.t()) :: String.t()
end
