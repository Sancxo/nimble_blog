defmodule NimbleBlog.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      NimbleBlogWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: NimbleBlog.PubSub},
      # Start Finch
      {Finch, name: NimbleBlog.Finch},
      # Start the Endpoint (http/https)
      NimbleBlogWeb.Endpoint
      # Start a worker by calling: NimbleBlog.Worker.start_link(arg)
      # {NimbleBlog.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NimbleBlog.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    NimbleBlogWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
