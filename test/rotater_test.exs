defmodule RotaterTest do
  use ExUnit.Case

  test "rotate_left_90_degrees/1 rotates a 3x3 list correctly" do
    list = ["ABC", "DEF", "GHI"]
    expected = ["CFI", "BEH", "ADG"]
    assert Rotator.rotate_left_90_degrees(list) == expected
  end
end
