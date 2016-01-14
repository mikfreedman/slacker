# Slacker

This project attempts to create a simple/flexible bot framework using the best
of Elixir/Erlang/OTP for Slack. The recommended use for this framework is to
create your own mix project and bring this in as a dependency. You can define
your own commands or just use the packaged ones and you configure that in your
project.

## Commands
Commands are a way of perfoming an action when someone uses the magic keyword.
The command prefix must be configured, but lets assume it is `"slacker"`. An
example command (that comes packaged with this project) is the `echo` command.

The implementation is very simple:

```elixir
defmodule Slacker.Commands.Echo do
  use Slacker.Command

  @usage "echo <message>"
  @short_description "responds with <message>"

  def handle_event({{:command, "echo", message}, meta}, state) do
    respond(message, meta)
    {:ok, state}
  end
end
```

This framework uses GenEvent for dispatching the commands. You can use all the
deliciousness of pattern matching to match the commands you are interested in.

The important part of the pattern match is `{:command, "echo", message}`. In
the case that someone says `slacker echo hello world` these will come through
like `{:command, "echo", "hello world"}`. The other parts of the pattern match
are just metadata/session data. You can use `meta[:author].user_id` if you want
to know who sent the message.

The module attributes `@usage` and `@short_description` will be included in the
output of `slacker help` if they are defined.

The commands that your bot actually runs must be configured and you can mix and
match between packaged commands and any commands you define.

## Config
The config setup for this project is as follows:

```elixir
config :slacker,
  command_prefix: "slacker",
  slack_api_token: System.get_env("SLACK_API_TOKEN"),
  commands: [Slacker.Commands.Echo, Slacker.Commands.Ping]
```

You must set all of these when you include this dependency in your project,
however you can easily run this project as is and the above credentials will
log you into slack so long as you set the SLACK_API_TOKEN env var.

## Installation

The package can be installed as:

  1. Add slacker to your list of dependencies in `mix.exs`:

        def deps do
          [{:slacker, git: "https://github.com/mikfreedman/slacker.git"}]
        end

  2. Ensure slacker is started before your application:

        def application do
          [applications: [:slacker]]
        end
