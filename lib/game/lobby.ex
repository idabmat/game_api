defmodule Game.Lobby do
  @moduledoc """
  Lobby players can create or join to play or watch a game.
  """

  alias Game.Player

  use TypedStruct

  @derive {Jason.Encoder, only: [:name, :players]}
  typedstruct do
    field(:uid, String.t(), enforce: true)
    field(:name, String.t(), enforce: true)
    field(:players, [Player.t()], enforce: true)
  end

  @callback set(t()) :: :ok | {:error, :duplicate_name | :duplicate_account}
  @callback get(String.t()) :: t() | nil
end
