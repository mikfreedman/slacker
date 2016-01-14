defmodule Slacker.Command do
  defmacro __using__(_opts) do
    quote do
      @before_compile unquote(__MODULE__)
      use GenEvent

      def respond(reply_text, %{bot_pid: bot_pid, message: message}) do
        send bot_pid, {:reply, message, reply_text}
      end
    end
  end

  defmacro __before_compile__(_env) do
    quote do

      if Module.get_attribute(__MODULE__, :usage) && Module.get_attribute(__MODULE__, :short_description) do
        def handle_event({{:command, "help", ""}, meta}, parent) do
          message = get_help_message(@usage, @short_description)
          if message do
            respond(message, meta)
          end
          {:ok, parent}
        end
      end

      def handle_event(_, parent) do
        {:ok, parent}
      end

      def get_help_message(usage, short_description) do
        "`#{Application.get_env(:slacker, :command_prefix)} #{usage}`: #{short_description}"
      end
    end
  end
end
