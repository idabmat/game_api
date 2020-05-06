defmodule GameApiTest do
  use ExUnit.Case
  doctest GameApi

  test "greets the world" do
    assert GameApi.hello() == :world
  end
end
