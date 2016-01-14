defmodule Slacker.ParserTest do
  use ExUnit.Case

  test "#try_parse parses out echo command" do
    assert Slacker.Parser.try_parse("slacker echo hello world") == {:command, "echo", "hello world"}
  end

  test "#try_parse supports using @slacker" do
    assert Slacker.Parser.try_parse("@slacker echo hello world") == {:command, "echo", "hello world"}
  end

  test "#try_parse supports using slacker:" do
    assert Slacker.Parser.try_parse("slacker: echo hello world") == {:command, "echo", "hello world"}
  end

  test "#try_parse supports using uppercase" do
    assert Slacker.Parser.try_parse("Slacker echo hello world") == {:command, "echo", "hello world"}
  end

  test "#try_parse supports commands with hyphens" do
    assert Slacker.Parser.try_parse("Slacker foo-bar hello world") == {:command, "foo-bar", "hello world"}
  end

  test "#try_parse supports custom command_prefix" do
    assert Slacker.Parser.try_parse("foobar echo hello world", "foobar") == {:command, "echo", "hello world"}
  end

  test "#try_parse supports empty message after command" do
    assert Slacker.Parser.try_parse("slacker ping") == {:command, "ping", ""}
  end

  test "#try_parse returns nil for invalid command" do
    assert Slacker.Parser.try_parse("foo bar hello world") == nil
  end
end
