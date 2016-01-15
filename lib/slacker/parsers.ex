defmodule Slacker.Parsers do
  def try_parse(message, parsers \\ Application.get_env(:slacker, :parsers), command_prefixes \\ Application.get_env(:slacker, :command_prefix)) do

    # Support single prefix or multiple in a list
    command_prefixes = List.wrap(command_prefixes)

    Enum.find_value command_prefixes, fn(command_prefix) ->
      match = Regex.named_captures(~r/^\s*@?#{command_prefix}:?\s+(?<message>.*)/i, message)
      if match && match["message"] do
        Enum.find_value parsers, fn(parser) ->
          parser.try_parse(match["message"])
        end
      end
    end
  end
end
