defmodule Slacker.Commands.MessageCount do
  use Slacker.Command

  @usage "message_count"
  @short_description "responds with the number of messages it has seen"

  def init(args) do
    {:ok, 0}
  end

  def handle_event({{:command, "message_count", _message}, meta}, count) do
    respond("I have seen #{count} messages.", meta)
    {:ok, count}
  end

  def handle_event({{:message, _message}, meta}, count) do
    {:ok, count + 1}
  end
end
