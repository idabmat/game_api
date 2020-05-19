defmodule Auth.Token.Constant do
  @moduledoc """
  Implementation of the Auth.Token behaviour based on an Agent.

  This implementation uses a constant string as the token. The constant should
  be provided when initializing the Agent.
  """

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
