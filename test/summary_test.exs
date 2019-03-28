defmodule SummaryTest do
  use ExUnit.Case
  doctest Summary

  test "greets the world" do
    assert Summary.hello() == :world
  end
end
