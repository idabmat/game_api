defmodule GameApi.ID.Constant do
  @moduledoc """
  Implementation of ID string generation returning a constant strings
  """
  use Agent
  alias GameApi.ID

  @behaviour ID

  def start_link(options \\ []) do
    ids = Keyword.get(options, :ids, [])
    Agent.start_link(fn -> {0, ids} end, name: __MODULE__)
  end

  @impl ID
  def generate do
    Agent.get_and_update(__MODULE__, fn {counter, ids} ->
      id = Enum.at(ids, counter, "1")
      {id, {counter + 1, ids}}
    end)
  end
end
