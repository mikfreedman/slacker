defmodule Slacker.Filter do
  def match(message, slack, command_prefixes) do
    unless sent_from_me?(message, slack) do
      command_prefixes = List.wrap(command_prefixes)

      Enum.find_value command_prefixes, fn(command_prefix) ->
      match = Regex.named_captures(~r/^\s*@?#{command_prefix}:?\s+(?<message>.*)/i, message.text)
      if match && match["message"] do
          match["message"]
        end
      end
    end
  end

  def sent_from_me?(%{user: sender_id}, %{me: %{id: my_id}}) do
    sender_id == my_id
  end
end
