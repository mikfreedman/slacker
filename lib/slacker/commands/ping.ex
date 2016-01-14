defmodule Slacker.Commands.Ping do
  use Slacker.Command

  @usage "ping"
  @short_description "responds with \"pong\""

  def handle_event({{:command, "ping", _message}, meta}, state) do
    respond("pong", meta)
    {:ok, state}
  end
end
