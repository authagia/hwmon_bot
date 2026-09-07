defmodule Rotator do
  @doc """
  固定長文字列のリストを左に90度回転させます。
  (転置後、リスト全体の順序を逆転させるバージョン)
  """
  def rotate_left_90_degrees(list_of_strings) when is_list(list_of_strings) and list_of_strings != [] do
    # 1. 各文字列を文字のリストに変換
    list_of_char_lists = Enum.map(list_of_strings, &String.graphemes/1)

    # 2. 文字のリストのリストを転置
    #    例: [["A","B","C"], ["D","E","F"], ["G","H","I"]]
    #    => [["A","D","G"], ["B","E","H"], ["C","F","I"]]
    transposed_char_lists = apply(Enum, :zip_with, [list_of_char_lists, fn char_list -> char_list end])

    # 3. 転置された文字のリストのリストを逆順にする
    #    例: [["A","D","G"], ["B","E","H"], ["C","F","I"]]
    #    => [["C","F","I"], ["B","E","H"], ["A","D","G"]]
    reversed_transposed_char_lists = Enum.reverse(transposed_char_lists)

    # 4. 各文字のリストを再び文字列に結合
    #    例: [["C","F","I"], ["B","E","H"], ["A","D","G"]]
    #    => ["CFI", "BEH", "ADG"]
    Enum.map(reversed_transposed_char_lists, &Enum.join/1)
  end

  # 空のリストの場合
  def rotate_left_90_degrees([]), do: []
end
