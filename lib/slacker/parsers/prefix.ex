defmodule Slacker.Parsers.Prefix do
  def try_parse(message) do
    match = Regex.named_captures(~r/(?<command>[\w-]+)\s*(?<message>.*)/i, message)
    if match && match["command"] do
      {:command, match["command"], match["message"]}
    else
      nil
    end
  end
end
