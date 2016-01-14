defmodule Slacker.Parser do
  def try_parse(message, command_prefix \\ Application.get_env(:slacker, :command_prefix)) do
    match = Regex.named_captures(~r/^\s*@?#{command_prefix}:?\s+(?<command>[\w-]+)\s*(?<message>.*)/i, message)
    if match && match["command"] do
      {:command, match["command"], match["message"]}
    else
      nil
    end
  end
end
