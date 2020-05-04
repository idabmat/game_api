defmodule YatzyApiTest do
  use ExUnit.Case
  doctest YatzyApi

  test "greets the world" do
    assert YatzyApi.hello() == :world
  end
end
