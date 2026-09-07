defmodule MetricChart.Render do

  use GenServer

  @data_from SystemMetrics.MarkovCpu

  def start_link(graph \\ "") do
    GenServer.start_link(__MODULE__, graph, name: __MODULE__)
  end

  def init(graph \\ "") do
    Process.send_after(self(), :render_chart, conf(:interval_ms))
    {:ok, graph}
  end




  def handle_call(:get, _from, graph) do
    {:reply, graph, graph}
  end

  def handle_info(:render_chart, _graph) do
    Process.send_after(self(), :render_chart, conf(:interval_ms))

    new_graph = render(@data_from, conf(:data_points))
    {:noreply, new_graph}
  end

  defp render(from, points) do
    data_range_max = conf(:total_line) * conf(:num_tick)
    data = GenServer.call(from, {:get, points})
    |> Enum.map(fn f -> quantize_to_n_step(f, data_range_max) end)

    bars = data
    |> Enum.map(fn s ->[
          div(s, conf(:num_tick)),
          rem(s, conf(:num_tick))
        ] end
      )
    |> Enum.map(fn c -> BarSegment.generate_bar_string(c, conf(:total_line)) end)

    bars
    |>Rotator.rotate_left_90_degrees
    |> Enum.join("\n")
  end

  defp quantize_to_n_step(value, n) when is_float(value) and value >= 0.0 and value <= 1.0 do
    value
    |> Kernel.*(n)
    |> Kernel.trunc
  end

  defp conf(key) do
    Application.get_env(:hwmon_bot, :render)[key]
  end

end
