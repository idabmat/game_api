defmodule Auth.Token.GuardianTest do
  use ExUnit.Case, async: true

  alias Auth.Account
  alias Auth.Token.Guardian

  test "generating a token for an account" do
    account = %Account{provider: :foobar, uid: "123"}
    assert is_binary(Guardian.set(account))
  end
end
