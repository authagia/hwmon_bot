defmodule BarSegment do
  @full_block "█"
  @empty_char " "

  # 8段階のブロック要素 (0/8から7/8まで)
  # 0: 空白 (または @empty_char)
  # 1/8: ▁ (U+2581 Lower One Eighth Block)
  # 2/8: ▂ (U+2582 Lower Quarter Block)
  # 3/8: ▃ (U+2583 Lower Three Eighths Block)
  # 4/8: ▄ (U+2584 Lower Half Block)
  # 5/8: ▅ (U+2585 Lower Five Eighths Block)
  # 6/8: ▆ (U+2586 Lower Three Quarters Block)
  # 7/8: ▇ (U+2587 Lower Seven Eighths Block)
  @eighth_blocks [
    @empty_char, "▁", "▂", "▃", "▄", "▅", "▆", "▇"
  ]

  defp get_eighth_block(m) when is_integer(m) and m >= 0 and m <= 7 do
    Enum.at(@eighth_blocks, m)
  end

  @doc """
  [n, m]のリストから棒グラフのセグメント文字列を生成します。

  - n: Full Block (█) の数
  - m: 8分のブロック (0-7) に対応する値
  - total_length: 生成する文字列の全体の長さ (デフォルトは12)
  """
  def generate_bar_string([n, m], total_length)
      when is_integer(n) and n >= 0 and
           is_integer(m) and m >= 0 and m <= 7 and
           is_integer(total_length) and total_length >= 1 do
    # フルブロックの部分
    full_blocks_str = String.duplicate(@full_block, n)

    # 8分のブロックの部分
    eighth_block_str = get_eighth_block(m)

    # 残りの空白部分
    # n個のフルブロックと1個の8分のブロックを考慮
    remaining_length = total_length - n - 1

    # remaining_length が負になる場合は、少なくとも0にする
    empty_spaces_count = max(0, remaining_length)
    empty_spaces_str = String.duplicate(@empty_char, empty_spaces_count)

    # 全てを結合
    full_blocks_str <> eighth_block_str <> empty_spaces_str
  end
end
