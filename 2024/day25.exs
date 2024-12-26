# --- Day 25: Code Chronicle ---

defmodule Locks do
  def fitting_pairs(schematics) do
    %{lock: locks, key: keys} = Enum.group_by(schematics, &type/1)

    (for l <- locks, k <- keys, do: {l, k})
    |> Enum.count(fn {l, k} -> fit?(l, k) end)
  end

  defp fit?(lock, key), do: Enum.zip(heights(lock), heights(key)) |> Enum.all?(fn {h1, h2} -> h1 + h2 <= 7 end)

  defp heights(schematic), do: Enum.map(0..4, fn j -> height(schematic, j) end)

  defp height(schematic, j), do: Enum.count(0..6, fn i -> Map.get(schematic, {i, j}) == "#" end)

  defp type(schematic) do
    cond do
      lock?(schematic) -> :lock
      key?(schematic) -> :key
    end
  end

  defp lock?(schematic), do: first_row_all?(schematic, "#") and bottom_row_all?(schematic, ".")
  defp key?(schematic), do: first_row_all?(schematic, ".") and bottom_row_all?(schematic, "#")

  defp first_row_all?(schematic, c), do: Enum.all?(0..4, fn j -> Map.get(schematic, {0, j}) == c end)
  defp bottom_row_all?(schematic, c), do: Enum.all?(0..4, fn j -> Map.get(schematic, {6, j}) == c end)

  def read_schematics(file) do
    File.read!(file)
    |> String.split(~r{\n\n}, trim: true)
    |> Enum.map(&parse_schematic/1)
    |> Enum.uniq()
  end

  defp parse_schematic(line), do: String.split(line, ~r{\n}, trim: true) |> parse_schematic(%{}, 0)
  defp parse_schematic([], schematic, _), do: schematic
  defp parse_schematic([line | lines], schematic, i) do
    updated_schematic = parse_schematic(String.graphemes(line), schematic, i, 0)
    parse_schematic(lines, updated_schematic, i + 1)
  end

  defp parse_schematic([], schematic, _, _), do: schematic
  defp parse_schematic([c | row], schematic, i, j), do: parse_schematic(row, Map.put(schematic, {i, j}, c), i, j + 1)
end

Locks.read_schematics("inputs/input25.txt") |> Locks.fitting_pairs() |> IO.inspect

# --- Part Two ---

# There's no part two!
