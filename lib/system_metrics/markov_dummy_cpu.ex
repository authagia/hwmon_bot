defmodule SystemMetrics.MarkovCpu do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    Process.send_after(self(), :fetch_system_metrics, conf(:interval_ms))
    # 状態として履歴、現在の状態、現在の値を保持[cite: 2]
    initial_state = %{history: [], current_state: :normal, current_value: 50.0}
    {:ok, initial_state}
  end

  def handle_call({:get, demand}, _from, %{history: history} = state) do
    # 差分計算を省き、直接履歴から指定件数を取得[cite: 1]
    repl = Enum.take(history, demand)
    |> Enum.map(fn v -> v/100.0 end) # 0.0-1.0の範囲に正規化
    {:reply, repl, state}
  end

  def handle_info(:fetch_system_metrics, state) do
    Process.send_after(self(), :fetch_system_metrics, conf(:interval_ms))

    next_state = transition(state.current_state)
    next_value = calculate_value(state.current_state, next_state, state.current_value)

    new_history = [next_value | state.history] |> Enum.take(conf(:store_history))
    new_state = %{state | history: new_history, current_state: next_state, current_value: next_value}

    {:noreply, new_state}
  end

  # --- 以降、マルコフ連鎖および乱数生成用のプライベート関数 ---

  # 状態遷移の確率定義[cite: 2]
  defp transition(:low), do: weighted_choice([{:low, 0.80}, {:normal, 0.18}, {:high, 0.02}])
  defp transition(:normal), do: weighted_choice([{:low, 0.10}, {:normal, 0.75}, {:high, 0.15}])
  defp transition(:high), do: weighted_choice([{:low, 0.03}, {:normal, 0.22}, {:high, 0.75}])

  defp weighted_choice(choices) do
    rand = :rand.uniform()
    Enum.reduce_while(choices, 0.0, fn {state, weight}, acc ->
      if rand <= acc + weight, do: {:halt, state}, else: {:cont, acc + weight}
    end)
  end

  # 状態が変化した場合はinit()、維持された場合はstep()を実行[cite: 2]
  defp calculate_value(old_state, new_state, _old_value) when old_state != new_state do
    case new_state do
      :low -> normal(25, 4)
      :normal -> normal(50, 8)
      :high -> normal(82, 6)
    end |> clamp(new_state)
  end

  defp calculate_value(state, state, old_value) do
    val = case state do
      :low -> reversion(old_value, 25, 0.05, normal(0, 2))
      :normal -> reversion(old_value, 50, 0.10, normal(0, 5))
      :high ->
        base = reversion(old_value, 82, 0.15, normal(0, 6))
        # high状態のみ5%の確率でスパイクをトリガー[cite: 2]
        if :rand.uniform() <= 0.05, do: base + (5.0 + :rand.uniform() * 10.0), else: base
    end
    clamp(val, state)
  end

  # 平均回帰モデル[cite: 2]
  defp reversion(value, target, strength, noise) do
    value + strength * (target - value) + noise
  end

  # 各状態ごとの範囲制限[cite: 2]
  defp clamp(val, :low), do: min(max(val, 10.0), 40.0)
  defp clamp(val, :normal), do: min(max(val, 30.0), 75.0)
  defp clamp(val, :high), do: min(max(val, 65.0), 100.0)

  # Box-Muller変換を用いた正規分布の乱数生成器
  defp normal(mean, std_dev) do
    u1 = :rand.uniform()
    u2 = :rand.uniform()
    z0 = :math.sqrt(-2.0 * :math.log(u1)) * :math.cos(2.0 * :math.pi() * u2)
    mean + std_dev * z0
  end

  defp conf(key) do
    Application.get_env(:hwmon_bot, :cpu)[key] || default_conf(key)
  end

  defp default_conf(:interval_ms), do: 1000
  defp default_conf(:store_history), do: 100
end
