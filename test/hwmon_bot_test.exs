defmodule HwmonBotTest do
  use ExUnit.Case
  doctest HwmonBot

  test "greets the world" do
    assert HwmonBot.hello() == :world
  end
end
