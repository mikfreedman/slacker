defmodule Slacker do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    slack_api_token = Application.get_env(:slacker, :slack_api_token)

    IO.inspect(slack_api_token)
    children = [
      worker(Slacker.Bot, [slack_api_token, []]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Slacker.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
