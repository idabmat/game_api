defmodule Auth.Account do
  @moduledoc false

  @callback get({atom(), String.t()}) :: %{} | nil

  @callback set(%{provider: atom(), uid: String.t()}) :: :ok
end
