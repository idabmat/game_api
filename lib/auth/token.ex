defmodule Auth.Token do
  @moduledoc false

  alias Auth.Account

  @callback set(Account.t()) :: String.t()
end
