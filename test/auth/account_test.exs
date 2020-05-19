defmodule Auth.AccountTest do
  use ExUnit.Case, async: true

  alias Auth.Account

  test "generating a key" do
    account = %Account{provider: :foobar, uid: "123"}
    assert "foobar:123" == Account.key(account)
  end
end
