defmodule SnsTest do
  use ExUnit.Case
  doctest Sns

  test "greets the world" do
    assert Sns.hello() == :world
  end
end
