defmodule Slacker.ParsersTest do
  use ExUnit.Case

  test "#try_parse defaults to using config for parsers" do
    assert Slacker.Parsers.try_parse("echo hello world") == {:command, "echo", "hello world"}
  end

  defmodule MyCustomParser do
    def try_parse(message) do

      {:command, "test-parser", message}
    end
  end

  test "#try_parse parses out the command" do
    assert Slacker.Parsers.try_parse("hello world", [MyCustomParser]) == {:command, "test-parser", "hello world"}
  end
end
