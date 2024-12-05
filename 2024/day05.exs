# --- Day 5: Print Queue ---

defmodule SafetyUpdates do
  def fix_invalid_updates({rules, updates}) do
    Enum.filter(updates, fn update -> !valid_update?(update, rules) end)
    |> Enum.map(fn update -> fix(update, rules) end)
  end

  def valid_updates({rules, updates}), do: Enum.filter(updates, fn update -> valid_update?(update, rules) end)

  def middle_pages_sum(updates), do: Enum.map(updates, &middle_page/1) |> Enum.sum

  def parse_input(file) do
    [rules, updates] = read(file)
    {parse_rules(rules), parse_updates(updates)}
  end

  defp fix(update, rules) do
    applicable_rules(update, rules)
    |> sort(Map.keys(update))
  end

  defp applicable_rules(update, rules), do: Enum.filter(rules, fn {x, y} -> Map.has_key?(update, x) and Map.has_key?(update, y) end)

  defp sort(rules, update), do: Enum.sort(update, fn n1, n2 -> sorter(n1, n2, rules) end)

  defp sorter(n1, n2, rules) do
    rule = Enum.find(rules, fn rule -> rule == {n1, n2} or rule == {n2, n1} end)

    is_nil(rule) or rule == {n1, n2}
  end

  defp middle_page(update) when is_map(update) do
    middle = map_size(update) / 2 |> trunc
    Map.to_list(update) |> Enum.find(fn {_, v} -> v == middle end) |> elem(0) |> String.to_integer
  end

  defp middle_page(update) when is_list(update) do
    middle = length(update) / 2 |> trunc
    Enum.at(update, middle) |> String.to_integer
  end

  defp valid_update?(_, []), do: true
  defp valid_update?(update, [rule|rules]), do: satisfies_rule?(update, rule) and valid_update?(update, rules)

  defp satisfies_rule?(update, {x, y}) do
    v1 = Map.get(update, x)
    v2 = Map.get(update, y)

    is_nil(v1) or is_nil(v2) or v1 < v2
  end

  defp parse_rules(rules), do: Enum.map(rules, &parse_rule/1)
  defp parse_rule(rule), do: String.split(rule, "|") |> List.to_tuple()

  defp parse_updates(updates), do: Enum.map(updates, &parse_update/1)
  defp parse_update(update) do
    list = String.split(update, ",")
    Enum.zip(list, (0..length(list) - 1)) |> Enum.into(%{})
  end

  defp read(file) do
    File.read!(file)
    |> String.split(~r{\n\n}, trim: true)
    |> Enum.map(fn lines -> String.split(lines, ~r{\n}, trim: true) end)
  end
end

SafetyUpdates.parse_input("inputs/input05.txt") |> SafetyUpdates.valid_updates |> SafetyUpdates.middle_pages_sum |> IO.puts

# --- Part Two ---

SafetyUpdates.parse_input("inputs/input05.txt") |> SafetyUpdates.fix_invalid_updates |> SafetyUpdates.middle_pages_sum |> IO.puts

