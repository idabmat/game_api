defmodule Auth do
  @moduledoc """
  Top-level module for managing player accounts
  """

  alias Auth.UseCase.CreateSession

  @spec create_session(map()) :: {:ok, map()} | {:error, [String.t()]}
  def create_session(data), do: CreateSession.execute(data)
end
