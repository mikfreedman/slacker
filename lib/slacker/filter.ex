defmodule Slacker.Filter do
  def match(message, slack, command_prefixes) do
    unless sent_from_me?(message, slack) do
      command_prefixes = List.wrap(command_prefixes)

      Enum.find_value command_prefixes, fn(command_prefix) ->
      match = Regex.named_captures(~r/^\s*@?#{command_prefix}:?\s+(?<message>.*)/i, message.text)

      command = match["message"]

      if command || direct_message?(message) do
          command || message.text
        end
      end
    end
  end

  defp direct_message?(message) do
   Application.get_env(:slacker, :allow_direct_messages) && Regex.match?(~r/^D/, message.channel)
  end

  def sent_from_me?(%{user: sender_id}, %{me: %{id: my_id}}) do
    sender_id == my_id
  end
end
