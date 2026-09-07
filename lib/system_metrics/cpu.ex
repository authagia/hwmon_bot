defmodule SystemMetrics.Cpu do
  use GenServer

  @num_cols 10

  def start_link(history \\ []) do
    GenServer.start_link(__MODULE__, history, name: __MODULE__)
  end

  def init(history \\ []) do
    Process.send_after(self(), :fetch_system_metrics, conf(:interval_ms))
    {:ok, history}
  end

  def handle_call({:get, demand}, _from,  history) do
    repl = process_raw_for_plot(history, demand)
    {:reply, repl, history}
  end

  def handle_info(:fetch_system_metrics, history) do
    Process.send_after(self(), :fetch_system_metrics, conf(:interval_ms))

    cpu_stats = File.read!("/proc/stat")
    |> String.split("\n") |> Enum.at(conf(:stat_line)) #take "cpu nnn ... " line
    |> String.split(" ", trim: true)
    |> tl() # drop "cpu" element
    |> Enum.map(&String.to_integer/1)
    # 0:user 1:nice 2:system 3:idle 4:iowait 5:irq 6:softirq 7:steal 8:guest 9:guest_nice

    new_history = [cpu_stats | history] |> Enum.take( conf(:store_history) )

    {:noreply, new_history}
  end

  defp process_raw_for_plot(raw, num) do
    # Generates a list of deltas (differences) from the input list.
    delta = Enum.take(raw, num+1)
    |> Enum.chunk_every(2,1, [List.duplicate(0, @num_cols)])
    |> Enum.map(fn [k, l] -> Enum.zip(k,l) end)
    |> Enum.map(
        fn z -> Enum.map(
          z,
          fn {a, b} -> a - b end
        ) end
      )
    |> Enum.take(num)
    |> Enum.reverse

    load_rate = delta
    |> Enum.map(fn s -> 1 - Enum.at(s, 3) / Enum.sum(s) end)
    # |> Enum.map(fn s -> 100 * s end)

    load_rate
  end

  defp conf(key) do
    Application.get_env(:hwmon_bot, :cpu)[key]
  end
end

# state:{previous raw, merics}
