defmodule Slacker.BotTest do
  use ExUnit.Case

  defmodule StubClient do
    def send({:text, json}, pid) do
      Kernel.send pid, json
    end
  end

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

  def channel_joined_event do
    %{
      type: "channel_joined",
      channel: %{name: "the_channel"}
    }
  end

  def generic_type_event do
    %{
      type: "generic_type",
      channel: %{name: "the_channel"}
    }
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

  test "#handle_message dispatches channel joined to the event manager" do
    Slacker.Bot.handle_message(channel_joined_event, slack_details, state)
    assert_receive %{gen_event_message: {{:channel_joined, _channel, _me}, %{slack: slack_details}}}, 100
    assert_receive %{gen_event_message: {{:slack_rtm_event, _message}, _meta}}, 100
  end

  test "#handle_message dispatches an echo command to the event manager" do
    Slacker.Bot.handle_message(echo_message, slack_details, state)
    assert_receive %{gen_event_message: {{:command, "echo", "hello world"}, %{slack: slack_details}}}, 100
  end

  test "#handle_message even dispatches things that are not commands" do
    Slacker.Bot.handle_message(not_a_command_message, slack_details, state)
    assert_receive %{gen_event_message: {{:message, "not a command"}, %{slack: slack_details}}}, 100
    assert_receive %{gen_event_message: {{:slack_rtm_event, _message}, _meta}}, 100
  end

  test "#handle_info responds with slack_state" do
    slack = %{foo: "bar"}
    Slacker.Bot.handle_info({:slack_state, self}, slack, {})
    assert_receive {:slack_state, slack}, 100
  end

  test "#handle_message with generic type should pass through message to rtm" do
    Slacker.Bot.handle_message(generic_type_event, slack_details, state)
    message = generic_type_event
    assert_receive %{gen_event_message: {{:slack_rtm_event, ^message}, _meta}}, 100
  end

  test "#handle_info with :reply_raw sends raw json through socket" do
    slack = %{socket: self, client: StubClient}

    {:ok, :state} = Slacker.Bot.handle_info({:reply_raw, "{\"hello\":\"world\"}"}, slack, :state)

    assert_receive "{\"hello\":\"world\"}", 100
  end
end
