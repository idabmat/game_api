defmodule DependenciesTest do
  use ExUnit.Case, async: false

  setup context do
    if env = context[:insert_env] do
      {name, value} = env
      System.put_env(name, value)
      on_exit(fn -> System.delete_env(name) end)
    end

    :ok
  end

  test "reading dependencies from load" do
    deps = Dependencies.load!()
    assert deps.auth[:account_gateway] == Auth.Account.InMemory
    Dependencies.unload()
  end

  test "reading dependencies from application env" do
    Dependencies.load!()
    assert Application.get_env(:game_api, Auth)[:account_gateway] == Auth.Account.InMemory
    Dependencies.unload()
  end

  test "unloading dependencies from application env" do
    Dependencies.load!()
    Dependencies.unload()
    assert Application.get_env(:game_api, Auth) == nil
  end

  @tag insert_env: {"AUTH_TOKEN_GATEWAY", "Auth.Token.Constant"}
  test "overriding gateway" do
    deps = Dependencies.load!()
    assert deps.auth[:token_gateway] == Auth.Token.Constant
    Dependencies.unload()
  end

  @tag insert_env: {"AUTH_TOKEN_GATEWAY", "FooBar"}
  test "setting an non existent module as a gateway" do
    assert_raise ArgumentError, &Dependencies.load!/0
  end
end
