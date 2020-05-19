defmodule Auth.Account do
  @moduledoc """
  Defines:
  - Structure of an account
  - Interface to be implemented by persistence gateways
  """

  use TypedStruct

  @derive {Jason.Encoder, only: [:uid, :email, :image]}
  typedstruct do
    field(:provider, atom(), enforce: true)
    field(:uid, String.t(), enforce: true)
    field(:email, String.t())
    field(:image, String.t())
  end

  @callback get({atom(), String.t()}) :: t() | nil
  @callback set(t()) :: :ok

  @spec key(t()) :: String.t()
  def key(account) do
    Atom.to_string(account.provider) <> ":#{account.uid}"
  end
end
