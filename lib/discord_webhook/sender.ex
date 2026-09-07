defmodule DiscordWebhook.Sender do
  use GenServer

  @graph_from MetricChart.Render

  def start_link(state \\ 0) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    Process.send_after(self(), :send, conf(:interval_ms))
    {:ok, state}
  end

  def handle_info(:send, state) do
    Process.send_after(self(), :send, conf(:interval_ms))

    graph_cpu = GenServer.call(@graph_from, :get)
    c = "```ansi\n"
    <> "----| CPU load rate |------------------\n"
    <> "\u001b[0;47;32m" <> graph_cpu <> "\n"
    <> "```"
    Req.patch(conf(:url) <> "/messages/" <> conf(:message_id),
      json: %{content: c})
    # |> IO.inspect
    {:noreply, state}
  end

  defp conf(key) do
    Application.get_env(:hwmon_bot, :sender)[key]
  end

end
