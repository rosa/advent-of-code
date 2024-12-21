# --- Day 19: Linen Layout ---

defmodule Towels do
  def count_possibles(patterns, designs), do: Enum.count(designs, &(possible?(&1, patterns)))

  def count_possibles_v2({patterns, designs}), do: count_possibles_v2(patterns, Enum.map(designs, &String.graphemes/1), 0)
  def count_possibles_v2(_, [], total), do: total
  def count_possibles_v2(patterns, [d|designs], total) do
    {updated_patterns, possible} = possible_v2?(d, patterns)

    updated_total = if possible, do: total + 1, else: total
    count_possibles_v2(updated_patterns, designs, updated_total)
  end

  def sum_all_combinations(patterns, designs), do: Enum.map(designs, &(count_combinations(&1, patterns))) |> Enum.sum()

  def all_combinations({patterns, []}), do: patterns
  def all_combinations({patterns, [design|designs]}) do
    {updated_patterns, _} = all_combinations(design, patterns)
    all_combinations({updated_patterns, designs})
  end

  defp possible?(design, patterns), do: count_combinations(design, patterns) > 0
  defp count_combinations(design, patterns), do: Map.get(patterns, design) |> MapSet.size()

  def possible_v2?([], patterns), do: {patterns, true}
  def possible_v2?([d], patterns), do: {patterns, Map.get(patterns, d, false)}
  def possible_v2?(design, patterns) do
    if Map.has_key?(patterns, Enum.join(design)) do
      {patterns, Map.get(patterns, Enum.join(design))}
    else
      {updated_patterns, possible} = possible_v2?(design, patterns, 1)
      {Map.put(updated_patterns, Enum.join(design), possible), possible}
    end
  end

  def possible_v2?(design, patterns, split) when split >= length(design), do: {patterns, false}
  def possible_v2?(design, patterns, split) do
    {updated_patterns, possible} = possible_v2?(Enum.take(design, split), patterns)

    if possible do
      {updated_patterns, possible} = possible_v2?(Enum.drop(design, split), updated_patterns)
      if possible do
        {updated_patterns, possible}
      else
        possible_v2?(design, updated_patterns, split + 1)
      end
    else
      possible_v2?(design, updated_patterns, split + 1)
    end
  end

  def read(file) do
    [patterns, designs] = File.read!(file)
    |> String.split(~r{\n\n}, trim: true)

    {parse_patterns(patterns), parse_designs(designs)}
  end

  def read_v2(file) do
    [patterns, designs] = File.read!(file)
    |> String.split(~r{\n\n}, trim: true)

    {parse_patterns_v2(patterns), parse_designs(designs)}
  end

  def parse_patterns_v2(patterns) do
    String.split(patterns, ", ", trim: true)
    |> Enum.map(fn d -> {d, true} end)
    |> Enum.into(%{})
  end


  defp parse_patterns(patterns) do
    designs = String.split(patterns, ", ", trim: true)
    |> Enum.sort(&(String.length(&1) <= String.length(&2)))

    Enum.filter(designs, fn d -> String.length(d) <= 1 end)
    |> Enum.map(fn d -> {d, 1} end)
    |> Enum.into(%{})
    |> preprocess_patterns(designs)
  end

  defp preprocess_patterns(patterns, []), do: patterns
  defp preprocess_patterns(patterns, [d|designs]) do
    if Map.has_key?(patterns, d) do
      preprocess_patterns(patterns, designs)
    else
      {updated_patterns, v} = all_combinations(d, patterns)
      preprocess_patterns(Map.put(updated_patterns, d, MapSet.put(v, d)), designs)
    end
  end

  defp all_combinations(design, patterns) do
    if Map.has_key?(patterns, design) do
      {patterns, Map.get(patterns, design)}
    else
      {updated_patterns, v} = all_combinations(design, patterns, 1, MapSet.new())
      {Map.put(updated_patterns, design, v), v}
    end
  end
  defp all_combinations(design, patterns, split, all) do
    if split >= String.length(design) do
      {patterns, all}
    else
      {updated_patterns, v} = all_split_combinations(String.split_at(design, split), patterns)
      all_combinations(design, updated_patterns, split + 1, MapSet.union(all, v))
    end
  end
  defp all_split_combinations({s1, s2}, patterns) do
    {updated_patterns, v1} = all_combinations(s1, patterns)
    IO.inspect(map_size(updated_patterns))
    if MapSet.size(v1) > 0 do
      {updated_patterns, v2} = all_combinations(s2, updated_patterns)
      if MapSet.size(v2) > 0 do
        {updated_patterns, MapSet.new(for x <- v1, y <- v2, do: Enum.join([x, y], "-"))}
      else
        {updated_patterns, v2}
      end
    else
      {updated_patterns, v1}
    end
  end

  defp parse_designs(designs) do
    String.split(designs, ~r{\n}, trim: true)
  end
end

{patterns, designs} = Towels.read("inputs/input19.txt")
IO.puts("all all_combinations!!! \n\n\n")
all_combinations = Towels.all_combinations({patterns, designs})

Towels.count_possibles(all_combinations, designs) |> IO.puts()

# all_combinations = Towels.all_combinations({patterns, designs}) |> IO.inspect
# Towels.count_possibles(all_combinations, designs) |> IO.puts()

# --- Part Two ---

# Towels.sum_all_combinations(all_combinations, designs) |> IO.puts()
