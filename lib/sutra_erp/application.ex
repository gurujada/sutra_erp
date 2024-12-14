defmodule SutraErp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SutraErpWeb.Telemetry,
      SutraErp.Repo,
      {DNSCluster, query: Application.get_env(:sutra_erp, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: SutraErp.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: SutraErp.Finch},
      # Start a worker by calling: SutraErp.Worker.start_link(arg)
      # {SutraErp.Worker, arg},
      # Start to serve requests, typically the last entry
      SutraErpWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SutraErp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SutraErpWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
