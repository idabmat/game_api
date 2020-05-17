defmodule Auth do
  @moduledoc false

  alias Auth.UseCase.CreateSession

  @spec create_session(map()) :: {:ok, map()} | {:error, [String.t()]}
  def create_session(data), do: CreateSession.execute(data)
end
