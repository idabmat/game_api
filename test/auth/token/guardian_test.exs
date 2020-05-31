defmodule Auth.Token.GuardianTest do
  use ExUnit.Case, async: false

  alias Auth.Account
  alias Auth.Token.Guardian

  setup context do
    if context[:with_config] do
      Configuration.load!()

      on_exit(&Configuration.unload/0)
    end

    :ok
  end

  @tag :with_config
  test "generating a token for an account" do
    account = %Account{provider: :foobar, uid: "123"}
    assert is_binary(Guardian.set(account))
  end
end
