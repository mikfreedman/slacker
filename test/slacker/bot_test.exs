defmodule Slacker.BotTest do
  use ExUnit.Case

  defmodule EventHandler do
    use GenEvent

    def handle_event(message, test_pid) do
      send test_pid, %{gen_event_message: message}
      {:ok, test_pid}
    end
  end

  def new_event_manager do
    _self = self
    {:ok, event_manager} = GenEvent.start_link

    :ok = GenEvent.add_mon_handler(event_manager, EventHandler, self)
    event_manager
  end

  def echo_message do
    %{
      type: "message",
      text: "@slacker echo hello world",
      channel: "the_channel",
      user: "the_author_id",
    }
  end

  def not_a_command_message do
    put_in(echo_message[:text], "not a command")
  end

  def slack_details do
    %{
      me: %{
        id: "abc_123",
      },
      users: %{}
    }
  end

  def state do
    %{
      event_manager: new_event_manager,
      command_prefixes: ["slacker"],
    }
  end

  test "#handle_message dispatches an echo command to the event manager" do
    Slacker.Bot.handle_message(echo_message, slack_details, state)
    assert_receive %{gen_event_message: {{:command, "echo", "hello world"}, _meta}}, 100
  end

  test '#handle_message even dispatches things that are not commands' do
    Slacker.Bot.handle_message(not_a_command_message, slack_details, state)
    assert_receive %{gen_event_message: {{:message, "not a command"}, _meta}}, 100
  end
end
