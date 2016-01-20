defmodule Slacker.Event do
  defmacro __using__(_opts) do
    quote do
      @before_compile unquote(__MODULE__)
      use GenEvent

      def respond(reply_text, %{bot_pid: bot_pid, message: message}) do
        send bot_pid, {:reply, message, reply_text}
      end
    end
  end
end
