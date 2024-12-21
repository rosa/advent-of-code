# --- Day 19: Linen Layout ---

defmodule Towels do
  def count_possibles({patterns, designs}), do: Enum.count(designs, &(possible?(&1, patterns)))

  def sum_all_combinations({patterns, designs}), do: Enum.map(designs, &(count_combinations(&1, patterns))) |> Enum.sum()

  defp possible?(design, patterns), do: count_combinations(design, patterns) > 0
  defp count_combinations(design, patterns), do: count_combinations(design, patterns, %{}) |> elem(1)

  def read(file) do
    [patterns, designs] = File.read!(file)
    |> String.split(~r{\n\n}, trim: true)

    {parse_patterns(patterns), parse_designs(designs)}
  end

  def parse_patterns(patterns) do
    String.split(patterns, ", ", trim: true)
    |> Enum.map(fn d -> {d, 1} end)
    |> Enum.into(%{})
  end

  defp count_combinations(design, patterns, counted) do
    count_combinations(design, patterns, counted, 1, Map.get(patterns, design, 0))
  end

  def count_combinations(design, patterns, counted, split, total) do
    if split >= String.length(design) do
      {counted, total}
    else
      {s1, s2} = String.split_at(design, split)
      if Map.has_key?(patterns, s1) do
        if Map.has_key?(counted, s2) do
          count_combinations(design, patterns, counted, split + 1, Map.get(counted, s2) + total)
        else
          {updated_counted, v2} = count_combinations(s2, patterns, counted)
          count_combinations(design, patterns, Map.put(updated_counted, s2, v2), split + 1, total + v2)
        end
      else
        count_combinations(design, patterns, counted, split + 1, total)
      end
    end
  end

  defp parse_designs(designs) do
    String.split(designs, ~r{\n}, trim: true)
  end
end

Towels.read("inputs/input19.txt") |> Towels.count_possibles() |> IO.puts()

# --- Part Two ---

Towels.read("inputs/input19.txt") |> Towels.sum_all_combinations() |> IO.puts()
