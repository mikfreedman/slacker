defmodule Slacker.Commands.PingTest do
  use ExUnit.Case

  test "it pongs" do
    {:ok, manager} = GenEvent.start_link
    GenEvent.add_handler(manager, Slacker.Commands.Ping, self)

    message = %{ channel: "channel" }
    GenEvent.notify(manager, {{:command, "ping", "hello world"}, %{bot_pid: self, message: message}})
    assert_receive {:reply, message, "pong"}
  end
end
