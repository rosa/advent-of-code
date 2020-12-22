# --- Day 21: Allergen Assessment ---

defmodule Allergens do
  def safe_ingredients(food_list) do
    ingredients_with_allergens =
      food_list
      |> build_allergens_map()
      |> merge_ingredients_by_allergen()
      |> Map.values
      |> List.flatten
      |> Enum.uniq

    Enum.map(food_list, &(elem(&1, 0)))
    |> List.flatten
    |> Enum.filter(&(&1 not in ingredients_with_allergens))
  end

  def dangerous_ingredients(food_list) do
    build_allergens_map(food_list)
    |> merge_ingredients_by_allergen()
    |> deduce_allergens()
    |> sort_by_allergen()
  end

  def read_food_list(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
    |> Enum.map(&parse_food/1)
  end

  defp merge_ingredients_by_allergen(map), do: merge_ingredients_by_allergen(%{}, map)
  defp merge_ingredients_by_allergen(merged, map) when map_size(map) == 0, do: merged
  defp merge_ingredients_by_allergen(merged, map) do
    [allergen|_] = Map.keys(map)
    {lists, new_map} = Map.pop(map, allergen)
    Map.put(merged, allergen, intersection(lists))
    |> merge_ingredients_by_allergen(new_map)
  end

  defp intersection(lists) do
    Tuple.to_list(lists)
    |> Enum.map(&MapSet.new/1)
    |> Enum.reduce(&MapSet.intersection/2)
    |> MapSet.to_list
  end

  defp build_allergens_map(foods), do: build_allergens_map(foods, %{})
  defp build_allergens_map([], map), do: map
  defp build_allergens_map([food|foods], map), do: build_allergens_map(foods, update_allergens_map(map, food))

  defp update_allergens_map(map, {_, []}), do: map
  defp update_allergens_map(map, {ingredients, [allergen|allergens]}) do
    Map.update(map, allergen, {ingredients}, fn lists -> Tuple.append(lists, ingredients) end)
    |> update_allergens_map({ingredients, allergens})
  end

  defp deduce_allergens(map), do: deduce_allergens(map, %{})
  defp deduce_allergens(map, deductions) when map_size(map) == 0, do: deductions
  defp deduce_allergens(map, deductions) do
    deduced =
      map
      |> Enum.filter(fn {_, ingredients} -> Enum.count(ingredients) == 1 end)
      |> Enum.map(fn {allergen, [ingredient]} -> {allergen, ingredient} end)
      |> Enum.into(%{})

    Enum.filter(map, fn {allergen, _} -> !Map.has_key?(deduced, allergen) end)
    |> Enum.map(fn {allergen, ingredients} -> {allergen, ingredients -- Map.values(deduced)} end)
    |> Enum.into(%{})
    |> deduce_allergens(Map.merge(deductions, deduced))
  end

  defp sort_by_allergen(dangerous_ingredients) do
    Map.keys(dangerous_ingredients)
    |> Enum.sort
    |> Enum.map(&(dangerous_ingredients[&1]))
  end

  # mxmxvkd kfcds sqjhc nhms (contains dairy, fish)
  defp parse_food(line) do
    [_, ingredients, allergens] = Regex.run(~r{([[a-z ]+) \(contains ([a-z, ]+)\)}, line)
    {String.split(ingredients, " ", trim: true), String.split(allergens, ", ", trim: true)}
  end
end

Allergens.read_food_list("inputs/input21.txt") |> Allergens.safe_ingredients() |> Enum.count |> IO.puts

# --- Part Two ---

Allergens.read_food_list("inputs/input21.txt") |> Allergens.dangerous_ingredients() |> Enum.join(",") |> IO.puts
