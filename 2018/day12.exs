# --- Day 12: Subterranean Sustainability ---

defmodule Pots do
  def read_and_parse_rules(file) do
    read(file)
    |> parse()
  end

  def spread_generations(_rules, state, 0), do: state
  def spread_generations(rules, state, generations) do
    spread_generations(rules, run_generation(rules, state), generations - 1)
  end

  def sum_pots_containing_plants(state, generations, total) do
    # We add ..... to the left in each generation, which adds three new values to the left of the result, 
    # so we need to adjust the indexes by that.
    adjust = total - generations

    Enum.zip(String.graphemes(state), -(generations * 3)..String.length(state))
    |> Enum.filter(fn {pot, _} -> pot == "#" end)
    |> Enum.map(&(elem(&1, 1) + adjust))
    |> Enum.sum()
  end

  def find_recurrence(rules, initial_state, total), do: find_recurrence(rules, initial_state, 1, %{initial_state => 0}, total)
  def find_recurrence(rules, state, generation, history, total) do
    next_state = run_generation(rules, state) |> IO.inspect()
    key = String.trim(next_state, ".")
    if Map.has_key?(history, key) do
      # Number of generations to get to the first state that repeats plus the 
      # extra generations to get to the total
      remaining = total - history[key]
      period = generation - history[key]
      {rules, history[key] + rem(remaining, period)}
    else
      find_recurrence(rules, next_state, generation + 1, Map.put(history, key, generation), total)
    end
  end

  defp run_generation(rules, state), do: run_generation(rules, ".....#{state}.....", 2, [])
  defp run_generation(rules, state, n, result) do
    if n == String.length(state) - 2 do
      Enum.join(result)
    else
      to_match = String.slice(state, n-2, 5)
      run_generation(rules, state, n + 1, result ++ [rules[to_match] || "."])
    end
  end

  defp read(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
  end

  defp parse(lines) when is_list(lines) do
    Enum.map(lines, &parse/1)
    |> Enum.reduce(%{}, fn line, acc -> Map.put(acc, line["pattern"], line["result"]) end)
  end
  # .#.#. => .
  defp parse(line) do
    Regex.named_captures(~r/(?<pattern>[\.#]{5}) => (?<result>[\.#])/, line)
  end
end

initial_state = "#.##.###.#.##...##..#..##....#.#.#.#.##....##..#..####..###.####.##.#..#...#..######.#.....#..##...#"
Pots.read_and_parse_rules("./inputs/input12.txt")
|> Pots.spread_generations(initial_state, 20)
|> Pots.sum_pots_containing_plants(20, 20)
|> IO.puts()

# --- Part Two ---
# After fifty billion (50000000000) generations, what is the sum of the numbers of all pots which contain a plant?
{rules, generations} = Pots.read_and_parse_rules("./inputs/input12.txt")
|> Pots.find_recurrence(initial_state, 50000000000)

Pots.spread_generations(rules, initial_state, generations)
|> Pots.sum_pots_containing_plants(generations, 50000000000)
|> IO.puts()
