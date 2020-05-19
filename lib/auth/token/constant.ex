defmodule Auth.Token.Constant do
  @moduledoc false

  alias Auth.Account
  alias Auth.Token
  use Agent

  @behaviour Token

  def start_link(constant: constant) do
    Agent.start_link(fn -> %{constant => nil} end, name: __MODULE__)
  end

  @impl Token
  def set(%Account{} = account) do
    Agent.get_and_update(__MODULE__, fn state ->
      constant = Map.keys(state) |> List.first()
      {constant, Map.put(state, constant, account)}
    end)
  end
end
