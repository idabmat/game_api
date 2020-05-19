defmodule Auth.CreateTokenTest do
  use ExUnit.Case, async: true

  alias Auth.Account
  alias Auth.Token.Constant

  import Auth.CreateToken, only: [execute: 2]

  setup do
    start_supervised!({Constant, constant: "123456789"})
    :ok
  end

  test "without an account" do
    assert {:error, "Account not found"} == execute(nil, token_gateway: Constant)
  end

  test "with an account" do
    account = %Account{provider: :foobar, uid: "123"}
    assert {:ok, "123456789"} == execute(account, token_gateway: Constant)
  end
end
