defmodule Auth.Account do
  @moduledoc false

  @callback get({atom(), String.t()}) :: t() | nil
  @callback set(t()) :: :ok

  use TypedStruct

  @derive {Jason.Encoder, only: [:uid, :email, :image]}
  typedstruct do
    field(:provider, atom(), enforce: true)
    field(:uid, String.t(), enforce: true)
    field(:email, String.t())
    field(:image, String.t())
  end
end
