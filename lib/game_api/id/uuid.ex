defmodule GameApi.ID.UUID do
  @moduledoc """
  Implementation of ID string generation based on UUIDv4
  """

  alias GameApi.ID

  @behaviour ID

  @impl ID
  def generate, do: UUID.uuid4()
end
