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

### Listening For Arbitrary Messages

If for some reason you need to listen for arbitrary messages that aren't parsed
as commands you can add a function to pattern match for plain messages. Below
is the pre-packaged "message_count" command. It counts all messages then sends the
count when you use the `message_count` command.

```elixir
defmodule Slacker.Commands.MessageCount do
  use Slacker.Command

  @usage "message_count"
  @short_description "responds with the number of messages it has seen"

  def init(args) do
    {:ok, 0}
  end

  def handle_event({{:command, "message_count", _message}, meta}, count) do
    respond("I have seen #{count} messages.", meta)
    {:ok, count}
  end

  def handle_event({{:message, _message}, meta}, count) do
    {:ok, count + 1}
  end
end
```

NOTE: If something is parsed as a command it will end up being dispatched twice. Once as :command and once as :message. That's why in the above example I'm sure not increment the count in the :command callback.

## Config
The config setup for this project is as follows:

```elixir
config :slacker,
  command_prefix: "slacker",
  slack_api_token: System.get_env("SLACK_API_TOKEN"),
  parsers: [Slacker.Parsers.Prefix],
  allow_direct_messages: true,
  commands: [Slacker.Commands.Echo, Slacker.Commands.Ping]
```

You must set all of these when you include this dependency in your project,
however you can easily run this project as is and the above credentials will
log you into slack so long as you set the SLACK_API_TOKEN env var.

## Direct Messages
If it makes sense for your bot to receive direct messages, then set the `allow_direct_messages` to true, otherwise - don't. It may not make sense for your bot to receive direct messages if for example it relies on the channel to provide state. Note that direct messages do not require a command prefix, e.g. a direct message of `echo hello` will be parsed correctly.

## Custom Parsers
You can write your own command parsers if you need special parsing that doesn't fit in with the prefix parsing. For example if your command parser needs infix parsing you could do the following:

```elixir
defmodule MyInfixParser do
  # Handles messages like "@slacker dylan beat mik" to give back {:command, "beat", "dylan", "mik"}
  def try_parse(message) do
    match = Regex.named_captures(~r/(?<lhs>[\w]+)\s+(?<command>[\w]+)\s+(?<rhs>[\w]+)/i, message)
    if match && match["command"] do
      {:command, match["command"], match["lhs"], match["rhs"]}
    else
      nil
    end
  end
end
```

Update the `config/config.exs` with your new parser like so:

```elixir
...
parsers: [MyInfixParser, Slacker.Parsers.Prefix], # Optionally keep the default parser
...
```

NOTE: That your module must implement the `try_parse` function.


## Custom Command Prefixes
You can add multiple command prefixes in `config/config.exs` like so:
```elixir
...
command_prefix: ["slacker", "sl"]
...
```

This will mean your bot responds to either of those names.

## Testing Commands

Testing your commands is simple. Here is an example of testing the echo command:

```elixir
defmodule Slacker.Commands.EchoTest do
  use ExUnit.Case

  test "it echoes the message" do
    {:ok, manager} = GenEvent.start_link
    GenEvent.add_handler(manager, Slacker.Commands.Echo, self)

    message = %{}
    GenEvent.notify(manager, {{:command, "echo", "funky fried chicken"}, %{bot_pid: self, message: message}})
    assert_receive {:reply, message, "funky fried chicken"}
  end
end
```

Since responding to messages is just done via sending a message back to the
calling process you can just pass in `self` (as above) when dispatching and the
responses will end up in your mailbox.

## Installation

The package can be installed as:

  1. Add slacker to your list of dependencies in `mix.exs`:

```elixir
def application do
  [applications: [:logger, :slacker, :slack]]
end

def deps do
  [
    {:slacker, git: "https://github.com/mikfreedman/slacker.git"}
    {:slack, "~> 0.3"},
    {:websocket_client, git: "https://github.com/jeremyong/websocket_client"},
  ]
end
```

  2. Ensure slacker is started before your application:

```elixir
def application do
  [applications: [:slacker]]
end
```

## Development

### Setup
```bash
$ mix deps.get
```

### Run The Tests
```bash
$ mix test --no-start
```
