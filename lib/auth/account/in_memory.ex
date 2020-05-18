defmodule Auth.Account.InMemory do
  @moduledoc false

  alias Auth.Account
  use Agent

  @behaviour Account

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def size do
    Agent.get(__MODULE__, &map_size/1)
  end

  @impl Account
  def get({provider, uid}) do
    key = compute_key(provider, uid)
    Agent.get(__MODULE__, &Map.get(&1, key, nil))
  end

  @impl Account
  def set(%Account{provider: provider, uid: uid} = account) do
    key = compute_key(provider, uid)
    Agent.update(__MODULE__, &Map.put(&1, key, account))
  end

  defp compute_key(provider, uid) do
    Atom.to_string(provider) <> ":#{uid}"
  end
end
