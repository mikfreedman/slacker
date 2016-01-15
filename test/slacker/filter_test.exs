defmodule Slacker.FilterTest do
  use ExUnit.Case

  def slack do
   %{ me: %{ id: "1" } }
  end

  test "#match parses out echo command" do
    assert Slacker.Filter.match(%{user: "2", text: "slacker hello world"}, slack, ["slacker"]) == "hello world"
  end

  test "#match supports using @slacker" do
    assert Slacker.Filter.match(%{user: "2", text: "@slacker hello world"}, slack, ["slacker"]) == "hello world"
  end

  test "#match supports using slacker:" do
    assert Slacker.Filter.match(%{user: "2", text: "slacker: hello world"}, slack, ["slacker"]) == "hello world"
  end

  test "#match supports using uppercase" do
    assert Slacker.Filter.match(%{user: "2", text: "Slacker hello world"}, slack, ["slacker"]) == "hello world"
  end

  test "#match supports custom command_prefix" do
    assert Slacker.Filter.match(%{user: "2", text: "foobar hello world"}, slack, ["foobar"]) == "hello world"
  end

  test "#match supports ignoring messages from me" do
    assert Slacker.Filter.match(%{user: "1", text: "foobar hello world"}, slack, ["foobar"]) == nil
  end

  test "#match returns nil if the prefix is not used" do
    assert Slacker.Filter.match(%{user: "2", text: "foobar hello world"}, slack, []) == nil
  end
  test "#match returns nil if the prefix is not used" do
    assert Slacker.Filter.match(%{user: "2", text: "fb hello world"}, slack, ["foobar", "fb"]) == "hello world"
    assert Slacker.Filter.match(%{user: "2", text: "foobar hello world"}, slack, ["foobar", "fb"]) == "hello world"
  end
end
