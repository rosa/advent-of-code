# --- Day 21: Keypad Conundrum ---

defmodule Keypad do
  # +---+---+---+
  # | 7 | 8 | 9 |
  # +---+---+---+
  # | 4 | 5 | 6 |
  # +---+---+---+
  # | 1 | 2 | 3 |
  # +---+---+---+
  #     | 0 | A |
  #     +---+---+
  @numeric %{
                   "0" => {0, 1}, "A" => {0, 2},
    "1" => {1, 0}, "2" => {1, 1}, "3" => {1, 2},
    "4" => {2, 0}, "5" => {2, 1}, "6" => {2, 2},
    "7" => {3, 0}, "8" => {3, 1}, "9" => {3, 2}
  }

  #     +---+---+
  #     | ^ | A |
  # +---+---+---+
  # | < | v | > |
  # +---+---+---+
  @directional %{
    "<" => {0, 0}, "v" => {0, 1}, ">" => {0, 2},
                   "^" => {1, 1}, "A" => {1, 2}
  }

  def total_complexity(codes), do: Enum.map(codes, &complexity/1) |> Enum.sum()

  def complexity(code), do: button_presses(code) * numeric_part(code)

  def numeric_part(code), do: Enum.join(code) |> Integer.parse() |> elem(0)

  def button_presses(code) do
    sequences(code, :numeric)
    # |> combine()
    |> IO.inspect()
    |> Enum.flat_map(fn seq -> combine(sequences(seq, :directional)) end)
    |> Enum.flat_map(fn seq -> combine(sequences(seq, :directional)) end)
    |> pick_shortest()
    |> Enum.count()
  end

  def pick_shortest(seqs) do
    by_length = Enum.map(seqs, fn seq -> {length(seq), seq} end)
    |> Enum.into(%{})

    Map.get(by_length, Enum.min(Map.keys(by_length)))
  end

  def pick_cheapest(seqs) do
    by_cost = Enum.map(seqs, fn seq -> {cost(seq), seq} end)
    |> Enum.into(%{})

    Map.get(by_cost, Enum.min(Map.keys(by_cost)))
  end

  def sequences(code, keypad), do: sequences(["A"|code], [], keypad)
  def sequences([_], seqs, _), do: seqs
  def sequences([c1, c2|code], seqs, keypad) do
    sequences([c2|code], seqs ++ [movements(c1, c2, keypad)], keypad)
  end

  def cost([_]), do: 1
  def cost([c1, c2|seq]), do: diff(c1, c2) + cost([c2|seq])

  defp diff({y1, x1}, {y2, x2}), do: abs(y1 - y2) + abs(x1 - x2)
  defp diff(c1, c2), do: diff(Map.get(@directional, c1), Map.get(@directional, c2))

  def combine([seq]), do: seq
  def combine([seqs1, seqs2|seqs]) do
    combined = (for s1 <- seqs1, s2 <- seqs2, do: s1 ++ s2)
    combine([combined|seqs])
  end

  def movements({y1, x1}, {y2, x2}, keypad) do
    vertical(y1, y2) ++ horizontal(x1, x2)
    |> permutations()
    |> Enum.filter(fn movs -> valid?({y1, x1}, movs, keypad) end)
    |> Enum.map(fn movs -> movs ++ ["A"] end)
  end
  def movements(from, to, :numeric), do: movements(Map.get(@numeric, from), Map.get(@numeric, to), :numeric)
  def movements(from, to, :directional), do: movements(Map.get(@directional, from), Map.get(@directional, to), :directional)

  def valid?(_, [], _), do: true
  def valid?(from, [m|movs], keypad) do
    next = move(from, m)
    next != forbidden(keypad) and valid?(next, movs, keypad)
  end

  def forbidden(:numeric), do: {0, 0}
  def forbidden(:directional), do: {1, 0}

  defp move({y, x}, "v"), do: {y-1, x}
  defp move({y, x}, ">"), do: {y, x+1}
  defp move({y, x}, "^"), do: {y+1, x}
  defp move({y, x}, "<"), do: {y, x-1}

  def vertical(y, y), do: []
  def vertical(y1, y2) when y1 < y2, do: list("^", y2 - y1)
  def vertical(y1, y2), do: list("v", y1 - y2)

  def horizontal(x, x), do: []
  def horizontal(x1, x2) when x1 < x2, do: list(">", x2 - x1)
  def horizontal(x1, x2), do: list("<", x1 - x2)

  defp list(c, t), do: (for _i <- 1..t, do: c)

  defp permutations([]), do: [[]]
  defp permutations(list) do
    (for h <- list, t <- permutations(list -- [h]), do: [h | t])
    |> Enum.uniq()
  end

  def read_codes(path) do
    File.read!(path)
    |> String.split(~r{\n}, trim: true)
    |> Enum.map(&String.graphemes/1)
  end
end

Keypad.read_codes("inputs/input21.txt") |> Keypad.total_complexity() |> IO.puts

# 029A: <vA<AA>>^AvAA<^A>A<v<A>>^AvA^A<vA>^A<v<A>^A>AAvA^A<v<A>A>^AAAvA<^A>A 68
# 980A: <v<A>>^AAAvA^A<vA<AA>>^AvAA<^A>A<v<A>A>^AAAvA<^A>A<vA>^A<A>A 60
# 179A: <v<A>>^A<vA<A>>^AAvAA<^A>A<v<A>>^AAvA^A<vA>^AA<A>A<v<A>A>^AAAvA<^A>A 68
# 456A: <v<A>>^AA<vA<A>>^AAvAA<^A>A<vA>^A<A>A<vA>^A<A>A<v<A>A>^AAvA<^A>A 64
# 379A: <v<A>>^AvA^A<vA<AA>>^AAvA<^A>AAvA^A<vA>^AA<A>A<v<A>A>^AAAvA<^A>A 64


