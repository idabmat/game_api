defmodule Auth.CreateAccountTest do
  use ExUnit.Case, async: false

  alias Auth.Account
  alias Auth.Account.InMemory

  import Auth.CreateAccount, only: [execute: 2]

  setup do
    start_supervised!(InMemory)
    :ok
  end

  test "create a new account" do
    data = %{provider: :foo, uid: "123"}
    assert {:ok, %Account{provider: :foo, uid: "123"}} = execute(data, account_gateway: InMemory)
    assert InMemory.size() == 1
  end

  test "creating an account with missing args" do
    data = %{}
    assert {:error, message} =  execute(data, account_gateway: InMemory)
    assert message == "Missing required keys [:provider, :uid]"
    assert InMemory.size() == 0
  end

  test "updating an existing account" do
    data = %{provider: :foo, uid: "123"}
    assert {:ok, account} =  execute(data, account_gateway: InMemory)
    new_data = %{provider: :foo, uid: "123", email: "foo"}
    assert {:ok, new_account} = execute(new_data, account_gateway: InMemory)
    assert InMemory.size() == 1
    assert new_account.email == "foo"
  end
end
