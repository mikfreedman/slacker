defmodule Slacker.Parsers.PrefixTest do
  use ExUnit.Case

  test "#try_parse parses out echo command" do
    assert Slacker.Parsers.Prefix.try_parse("echo hello world") == {:command, "echo", "hello world"}
  end

  test "#try_parse supports commands with hyphens" do
    assert Slacker.Parsers.Prefix.try_parse("foo-bar hello world") == {:command, "foo-bar", "hello world"}
  end

  test "#try_parse supports empty message after command" do
    assert Slacker.Parsers.Prefix.try_parse("ping") == {:command, "ping", ""}
  end

  test "#try_parse returns nil for invalid command" do
    assert Slacker.Parsers.Prefix.try_parse("") == nil
  end
end
