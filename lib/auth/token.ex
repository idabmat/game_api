defmodule Auth.Token do
  @moduledoc false

  alias Auth.Account

  @callback set(Account.t()) :: {:ok, String.t()} | {:error, atom()}
end
