defmodule HwmonBot.Application do
  use Application

  def start(_start_type, _start_args) do
    opts = [strategy: :one_for_one, name: HwmonBot.Supervisor]
    children = [
      # SystemMetrics.Cpu,
      SystemMetrics.MarkovCpu,
      MetricChart.Render,
      DiscordWebhook.Sender
    ]

    Supervisor.start_link(children, opts)
  end
end
