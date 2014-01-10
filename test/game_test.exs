defmodule GameTest do
  use ExUnit.Case

  import MixtureMind.Game

  test "generates random new codes" do
    refute new_code(4) == new_code(4)
  end

  test "gets color code of proper length" do
    assert String.length(new_code 5) == 5
  end

  test "instructions list colors" do
    assert Regex.match?(%r/red, green, blue, purple, yellow, white/, instructions)
  end

  test "guess matches code is a win" do
    assert guess("RBWG", "rbwg") == :win
  end

  test "guess contains nothing correct" do
    assert guess("RBWG", "ypyp") == "    "
  end

  test "various guess results are correct" do
    assert guess("RBWG", "rppp") == "X   "
    assert guess("RBWG", "rywp") == "X X "
    assert guess("RBWG", "pbgg") == " X X"
    assert guess("RBWG", "ybwg") == " XXX"

    assert guess("RBWG", "bypp") == "-   "
    assert guess("RBWG", "rwpp") == "X-  "
    assert guess("RBWG", "rygp") == "X - "
    assert guess("RBWG", "pbgp") == " X- "
    assert guess("RBWG", "grWy") == "--X "
  end
end
