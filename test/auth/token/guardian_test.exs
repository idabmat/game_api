defmodule Auth.Token.GuardianTest do
  use ExUnit.Case, async: false

  alias Auth.Account
  alias Auth.Token.Guardian

  setup context do
    if context[:with_config] do
      Configuration.load!()
      Dependencies.load!()

      on_exit(fn ->
        Configuration.unload()
        Dependencies.unload()
      end)
    end

    :ok
  end

  @tag :with_config
  test "generating a token for an account" do
    account = %Account{provider: :foobar, uid: "123"}
    assert is_binary(Guardian.set(account))
  end
end
