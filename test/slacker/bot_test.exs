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

  def channel_join_message do
    %{
      type: "message",
      subtype: "channel_join",
      text: "<@U2147483828|cal> has joined the channel",
      channel: "the_channel",
      user: "U2147483828",
    }
  end
  
  def channel_leave_message do
    %{
      type: "message",
      subtype: "channel_leave",
      text: "<@U2147483828|cal> has left the channel",
      channel: "the_channel",
      user: "U2147483828",
    }
  end

  def slack_details do
    %{
      me: %{
        id: "abc_123",
      }
    }
  end

  def state do
    %{
      event_manager: new_event_manager,
      command_prefixes: ["slacker"],
    }
  end

  test "#handle_message dispatches an channel_join event to the event manager" do
    Slacker.Bot.handle_message(channel_join_message, slack_details, state)
    assert_receive %{gen_event_message: {{:event, "channel_join", "U2147483828"}, _meta}}, 100
  end
  
  test "#handle_message dispatches an channel_leave event to the event manager" do
      Slacker.Bot.handle_message(channel_leave_message, slack_details, state)
      assert_receive %{gen_event_message: {{:event, "channel_leave", "U2147483828"}, _meta}}, 100
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
