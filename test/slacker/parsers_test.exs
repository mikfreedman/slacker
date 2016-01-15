defmodule Slacker.ParsersTest do
  use ExUnit.Case

  test "#try_parse defaults to using config for parsers" do
    assert Slacker.Parsers.try_parse("slacker echo hello world", ["slacker"]) == {:command, "echo", "hello world"}
  end

  defmodule MyCustomParser do
    def try_parse(message) do

      {:command, "test-parser", message}
    end
  end

  test "#try_parse parses out echo command" do
    assert Slacker.Parsers.try_parse("slacker hello world", ["slacker"], [MyCustomParser]) == {:command, "test-parser", "hello world"}
  end

  test "#try_parse supports using @slacker" do
    assert Slacker.Parsers.try_parse("@slacker hello world", ["slacker"], [MyCustomParser]) == {:command, "test-parser", "hello world"}
  end

  test "#try_parse supports using slacker:" do
    assert Slacker.Parsers.try_parse("slacker: hello world", ["slacker"], [MyCustomParser]) == {:command, "test-parser", "hello world"}
  end

  test "#try_parse supports using uppercase" do
    assert Slacker.Parsers.try_parse("Slacker hello world", ["slacker"], [MyCustomParser]) == {:command, "test-parser", "hello world"}
  end

  test "#try_parse supports custom command_prefix" do
    assert Slacker.Parsers.try_parse("foobar hello world", ["foobar"], [MyCustomParser]) == {:command, "test-parser", "hello world"}
  end

  test "#try_parse returns nil if the prefix is not used" do
    assert Slacker.Parsers.try_parse("foo hello world", []) == nil
  end

  test "#try_parse supports an array of command prefixes" do
    assert Slacker.Parsers.try_parse("fb hello world", ["foobar", "fb"], [MyCustomParser]) == {:command, "test-parser", "hello world"}
    assert Slacker.Parsers.try_parse("foobar hello world", ["foobar", "fb"], [MyCustomParser]) == {:command, "test-parser", "hello world"}
  end
end
