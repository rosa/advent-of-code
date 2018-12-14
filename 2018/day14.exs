# --- Day 14: Chocolate Charts ---

defmodule Recipes do
  def build(scores, size), do: build(scores, Enum.to_list(0..map_size(scores) - 1), size)

  def build(scores, _positions, size) when map_size(scores) >= size, do: scores
  def build(scores, positions, size) do
    new_scores = combine(scores, positions)
    build(new_scores, move(new_scores, positions), size)
  end

  def slice(scores, start, amount) do
    Map.take(scores, start..start + amount - 1)
    |> Map.values()
    |> Enum.join()
  end

  def build_until_found(scores, target), do: build_until_found(scores, Enum.to_list(0..map_size(scores) - 1), Integer.digits(target))
  def build_until_found(scores, positions, target) do
    if found_target?(scores, target, length(positions)) do
      scores
    else
      new_scores = combine(scores, positions)
      build_until_found(new_scores, move(new_scores, positions), target)
    end
  end

  def remove_from(scores, target, offset) do
    start = map_size(scores) - length(Integer.digits(target)) - offset
    trailing = Map.take(scores, Enum.to_list(start..map_size(scores) - 1))
    |> Map.values()
    |> Enum.join()
    |> String.replace(~r/#{target}.*/, "")

    leading = Map.take(scores, Enum.to_list(0..start-1))
    |> Map.values()
    |> Enum.join()

    leading <> trailing
  end

  defp combine(scores, positions) do
    # To create new recipes, the two Elves combine their current recipes.
    # This creates new recipes from the digits of the sum of the current recipes' scores.
    Map.take(scores, positions)
    |> Map.values()
    |> Enum.sum()
    |> Integer.digits()
    |> to_scores(map_size(scores))
    |> Map.merge(scores)
  end

  def found_target?(scores, target, offset) when map_size(scores) + offset < length(target), do: false
  def found_target?(scores, target, offset) do
    # We only need to check the last additions
    Map.take(scores, Enum.to_list(map_size(scores) - length(target) - offset..map_size(scores) - 1))
    |> Map.values()
    |> Enum.join()
    |> String.contains?(Enum.join(target))
  end

  defp move(scores, positions) do
    # The Elf steps forward through the scoreboard a number of recipes equal to 1 plus
    # the score of their current recipe.
    Enum.map(positions, fn position -> rem(position + scores[position] + 1, map_size(scores)) end)
  end

  defp to_scores(digits, start) do
    start..start + length(digits) - 1
    |> Enum.reduce(%{}, fn index, acc -> Map.put(acc, index, Enum.at(digits, index - start)) end)
  end
end

# Your puzzle input is 409551.
target = 409551
Recipes.build(%{0 => 3, 1 => 7}, target + 10)
|> Recipes.slice(target, 10)
|> IO.puts()

# --- Part Two ---
Recipes.build_until_found(%{0 => 3, 1 => 7}, target)
|> Recipes.remove_from(target, 2)
|> String.length()
|> IO.puts()
