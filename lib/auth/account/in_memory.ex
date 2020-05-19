defmodule Auth.Account.InMemory do
  @moduledoc """
  Implementation of an in memory gateway for accounts.
  """

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
  def get(account_key) do
    Agent.get(__MODULE__, &Map.get(&1, account_key, nil))
  end

  @impl Account
  def set(%Account{} = account) do
    key = Account.key(account)
    Agent.update(__MODULE__, &Map.put(&1, key, account))
  end
end
