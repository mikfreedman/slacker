defmodule Slacker.Bot do
  require Logger
  use Slack

  def handle_connect(slack, _) do
    Logger.info fn -> "Connected to Slack." end

    Process.register(self, __MODULE__)

    commands = Application.get_env(:slacker, :commands)
    event_manager = setup_event_manager(commands)

    command_prefixes = List.wrap(Application.get_env(:slacker, :command_prefix)) ++ [ "<@#{slack.me.id}>" ]

    {:ok, %{event_manager: event_manager, command_prefixes: command_prefixes}}
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

  def handle_message(message = %{type: "channel_joined", channel: channel}, slack, state = %{event_manager: event_manager})do
    Logger.debug fn -> "Notifying for channel_joined #{channel.name}" end

    meta = %{bot_pid: self, message: message, slack: slack}
    GenEvent.notify(event_manager, {{:channel_joined, channel, me: slack.me}, meta})
    {:ok, state}
  end

  def handle_message(message = %{type: "message"}, slack, state = %{event_manager: event_manager, command_prefixes: command_prefixes}) do
    Logger.debug fn -> "Received message from slack: #{message.text}" end
    meta = %{bot_pid: self, message: message, user: slack.users[message.user], slack: slack}
    # Try to match command pattern then dispatch that
    if matched = Slacker.Filter.match(message, slack, command_prefixes) do
      Logger.debug fn -> "Matched message: #{inspect(matched)}" end

      command = Slacker.Parsers.try_parse(matched)
      if command do
        Logger.debug fn -> "Notifying for command: #{inspect(command)}" end
        GenEvent.notify(event_manager, {command, meta})
      end
    end

    # Dispatch everything as :message
    unless Slacker.Filter.sent_from_me?(message, slack) do
      GenEvent.notify(event_manager, {{:message, message.text}, meta})
    end

    {:ok, state}
  end

  def handle_message(_message, _slack, state) do
    {:ok, state}
  end

  def handle_info({:reply, slack_id, reply_text}, slack, state) do
    send_message(reply_text, slack_id, slack)

    {:ok, state}
  end

  def handle_info({:reply_raw, reply_json}, slack, state) do
    send_raw(reply_json, slack)

    {:ok, state}
  end

  def handle_info({:slack_state, pid}, slack, state) do
    send pid, {:slack_state, slack}

    {:ok, state}
  end
end
