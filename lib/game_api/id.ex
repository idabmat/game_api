defmodule GameApi.ID do
  @moduledoc """
  Interface for generating ID strings
  """

  @callback generate() :: String.t()
end
