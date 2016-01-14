defmodule Slacker.Bot do
  use Slack

  def handle_connect(_, _) do
    commands = Application.get_env(:slacker, :commands)
    event_manager = setup_event_manager(commands)
    {:ok, %{event_manager: event_manager}}
  end

  def setup_event_manager(commands) do
    # Start the GenEvent manager
    {:ok, event_manager} = GenEvent.start_link

    Process.monitor(event_manager)

    Enum.each commands, fn(c) ->
      :ok = GenEvent.add_mon_handler(event_manager, c, self)
    end

    event_manager
  end

  def handle_message(message = %{type: "message", text: text}, slack, state = %{event_manager: event_manager}) do

    unless sent_from_me?(message, slack) do
      command = Slacker.Parser.try_parse(text)
      if command do
        meta = %{bot_pid: self, message: message}
        GenEvent.notify(event_manager, {command, meta})
      end
    end

    {:ok, state}
  end

  def handle_info({:reply, message, reply_text}, slack, state) do
    send_message(reply_text, message.channel, slack)

    {:ok, state}
  end

  def sent_from_me?(%{user: sender_id}, %{me: %{id: my_id}}) do
    sender_id == my_id
  end

  def handle_message(_message, _slack, state) do
    {:ok, state}
  end
end
