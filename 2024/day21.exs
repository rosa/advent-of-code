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

  def total_complexity(codes, robots), do: Enum.map(codes, &(complexity(&1, robots))) |> Enum.sum()

  defp complexity(code, robots), do: button_presses(code, robots) * numeric_part(code)

  defp numeric_part(code), do: Enum.join(code) |> Integer.parse() |> elem(0)

  defp button_presses(code, robots) do
    sequences(code, :numeric)
    |> init_counts()
    |> direct(robots, %{})
    |> desglose_counts()
  end

  defp init_counts(sequences), do: Enum.frequencies(sequences)
  defp desglose_counts(counts), do: Enum.map(counts, fn {k, v} -> length(k) * v end) |> Enum.sum()

  defp direct(counts, 0, _), do: counts
  defp direct(counts, robots, cache), do: current_sequences(counts) |> direct(counts, robots, cache, %{})
  defp direct([], _, robots, cache, counts), do: direct(counts, robots - 1, cache)
  defp direct([seq|sequences], counts, robots, cache, updates) do
    {updated_updates, updated_cache} = sequences(seq, :directional, counts, cache, updates)
    direct(sequences, counts, robots, updated_cache, updated_updates)
  end

  defp current_sequences(counts), do: Map.filter(counts, fn {_, v} -> v > 0 end) |> Map.keys()

  defp sequences(code, keypad, counts, cache, updates) do
    updated_cache = if Map.has_key?(cache, code), do: cache, else: Map.put(cache, code, sequences(code, keypad))
    {increment_map(updates, Map.get(updated_cache, code), Map.get(counts, code)), updated_cache}
  end

  defp sequences(code, keypad), do: sequences(["A"|code], [], keypad)
  defp sequences([_], seqs, _), do: seqs
  defp sequences([c1, c2|code], seqs, keypad) do
    sequences([c2|code], seqs ++ [movements(c1, c2, keypad)], keypad)
  end

  def pick_cheapest([seq]), do: seq
  def pick_cheapest(seqs) do
    by_changes = Enum.map(seqs, fn seq -> {changes(seq), seq} end)
    min_changes = Enum.map(by_changes, &(elem(&1, 0))) |> Enum.min()
    Enum.filter(by_changes, fn {changes, _} -> changes == min_changes end)
    |> Enum.map(&(elem(&1, 1)))
    |> pick_left_first()
  end

  def pick_left_first([seq]), do: seq
  def pick_left_first([seq1, seq2|seqs]), do: [pick_left_first(seq1, seq2)|seqs] |> pick_left_first()
  def pick_left_first([c|seq1], [c|seq2]), do: [c] ++ pick_left_first(seq1, seq2)
  def pick_left_first(seq1 = ["<"|_], _), do: seq1
  def pick_left_first(_, seq2 = ["<"|_]), do: seq2
  def pick_left_first(seq1 = ["^"|_], _), do: seq1
  def pick_left_first(_, seq2 = ["^"|_]), do: seq2
  def pick_left_first(seq1 = ["v"|_], _), do: seq1
  def pick_left_first(_, seq2 = ["v"|_]), do: seq2
  def pick_left_first(seq1, _), do: seq1

  def changes([_]), do: 0
  def changes([c, c|seq]), do: changes([c|seq])
  def changes([_, c|seq]), do: 1 + changes([c|seq])

  defp movements({y1, x1}, {y2, x2}, keypad) do
    vertical(y1, y2) ++ horizontal(x1, x2)
    |> permutations()
    |> Enum.filter(fn movs -> valid?({y1, x1}, movs, keypad) end)
    |> Enum.map(fn movs -> movs ++ ["A"] end)
    |> pick_cheapest()
  end

  defp movements(from, to, :numeric), do: movements(Map.get(@numeric, from), Map.get(@numeric, to), :numeric)
  defp movements(from, to, :directional), do: movements(Map.get(@directional, from), Map.get(@directional, to), :directional)

  defp valid?(_, [], _), do: true
  defp valid?(from, [m|movs], keypad) do
    next = move(from, m)
    next != forbidden(keypad) and valid?(next, movs, keypad)
  end

  defp forbidden(:numeric), do: {0, 0}
  defp forbidden(:directional), do: {1, 0}

  defp move({y, x}, "v"), do: {y-1, x}
  defp move({y, x}, ">"), do: {y, x+1}
  defp move({y, x}, "^"), do: {y+1, x}
  defp move({y, x}, "<"), do: {y, x-1}

  defp vertical(y, y), do: []
  defp vertical(y1, y2) when y1 < y2, do: list("^", y2 - y1)
  defp vertical(y1, y2), do: list("v", y1 - y2)

  defp horizontal(x, x), do: []
  defp horizontal(x1, x2) when x1 < x2, do: list(">", x2 - x1)
  defp horizontal(x1, x2), do: list("<", x1 - x2)

  defp list(c, t), do: (for _i <- 1..t, do: c)

  defp permutations([]), do: [[]]
  defp permutations(list) do
    (for h <- list, t <- permutations(list -- [h]), do: [h | t])
    |> Enum.uniq()
  end

  defp increment_map(map, [], _), do: map
  defp increment_map(map, [key|keys], inc) do
    Map.update(map, key, inc, fn v -> v + inc end)
    |> increment_map(keys, inc)
  end

  def read_codes(path) do
    File.read!(path)
    |> String.split(~r{\n}, trim: true)
    |> Enum.map(&String.graphemes/1)
  end
end

Keypad.read_codes("inputs/input21.txt") |> Keypad.total_complexity(2) |> IO.puts

# --- Part Two ---

Keypad.read_codes("inputs/input21.txt") |> Keypad.total_complexity(25) |> IO.puts
