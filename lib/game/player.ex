defmodule Game.Player do
  @moduledoc """
  Represent a player from a Lobby
  """

  use TypedStruct

  @derive {Jason.Encoder, only: [:name]}
  typedstruct do
    field(:name, String.t(), enforce: true)
    field(:account_id, {atom(), String.t()}, enforce: true)
  end
end
