defmodule Slacker.Commands.EchoTest do
  use ExUnit.Case

  test "it echoes the message" do
    {:ok, manager} = GenEvent.start_link
    GenEvent.add_handler(manager, Slacker.Commands.Echo, self)

    message = %{ channel: "channel" }
    GenEvent.notify(manager, {{:command, "echo", "funky fried chicken"}, %{bot_pid: self, message: message}})
    assert_receive {:reply, message, "funky fried chicken"}
  end
end
