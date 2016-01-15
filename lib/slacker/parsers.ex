defmodule Slacker.Parsers do
  def try_parse(message, parsers \\ Application.get_env(:slacker, :parsers)) do
    Enum.find_value parsers, fn(parser) ->
      parser.try_parse(message)
    end
  end
end
