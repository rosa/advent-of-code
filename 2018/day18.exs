# --- Day 18: Settlers of The North Pole ---

defmodule LumberCollection do
  def read_and_parse_area(file) do
    read(file)
    |> parse_area()
  end

  def resources(area) do
    Map.values(area)
    |> Enum.reduce(%{}, fn v, acc -> Map.update(acc, v, 1, &(&1 + 1)) end)
  end

  def summary(%{"#" => lumberyards, "|" => trees}), do: lumberyards * trees

  # An open acre will become filled with trees if three or more adjacent acres
  # contained trees. Otherwise, nothing happens.
  def transform(acre = ".", adjacents) do
    if Enum.count(adjacents, fn a -> a == "|" end) >= 3, do: "|", else: acre
  end
  # An acre filled with trees will become a lumberyard if three or more adjacent acres
  # were lumberyards. Otherwise, nothing happens.
  def transform(acre = "|", adjacents) do
    if Enum.count(adjacents, fn a -> a == "#" end) >= 3, do: "#", else: acre
  end
  # An acre containing a lumberyard will remain a lumberyard if it was adjacent to at
  # least one other lumberyard and at least one acre containing trees.
  # Otherwise, it becomes open.  
  def transform(acre = "#", adjacents) do
    if "#" in adjacents && "|" in adjacents, do: acre, else: "."
  end

  def mutate(area, 0), do: area
  def mutate(area, minutes) do
    Enum.reduce(area, %{}, fn {coords, acre}, acc -> Map.put(acc, coords, transform(acre, adjacents(coords, area))) end)
    |> mutate(minutes - 1)
  end

  def find_repetition(area), do: find_repetition(area, [])
  def find_repetition(area, mutations) do
    previously = Enum.find_index(mutations, fn mutation -> mutation == area end)
    if previously do
      {previously, length(mutations)}
    else
      find_repetition(mutate(area, 1), mutations ++ [area])
    end
  end

  def adjacents({i, j}, area) do
    (for x <- -1..1, y <- -1..1, do: {x, y})
    |> List.delete({0, 0})
    |> Enum.map(fn {x, y} -> area[{i+x, j+y}] end)
    |> Enum.reject(&is_nil/1)
  end

  def print_area(area, n) do
    for i <- 0..n-1 do
      Enum.map(0..n-1, fn j -> area[{i, j}] end)
      |> Enum.join()
      |> IO.puts()
    end
    :ok
  end

  defp parse_area(lines), do: parse_area(%{}, lines, 0)
  defp parse_area(area, [], _i), do: area
  defp parse_area(area, [row | rows], i) do
    parse_area(area, row, i, 0)
    |> parse_area(rows, i + 1)
  end

  defp parse_area(area, [], _i, _j), do: area
  defp parse_area(area, [acre | row], i, j) do
    Map.put(area, {i, j}, acre)
    |> parse_area(row, i, j + 1)
  end

  defp read(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
    |> Enum.map(&String.graphemes/1)
  end
end

LumberCollection.read_and_parse_area("./inputs/input18.txt")
|> LumberCollection.mutate(10)
|> LumberCollection.resources()
|> LumberCollection.summary()
|> IO.puts()

# --- Part Two ---
# What will the total resource value of the lumber collection area be after 1000000000 minutes?
area = LumberCollection.read_and_parse_area("./inputs/input18.txt")

LumberCollection.find_repetition(area)
|> IO.inspect()
# {448, 476}
# This means we need to do 476 mutations, then the same 28 will repeat the same pattern, so we can simplify that
# by (1000000000 - 476) % 28 = 20
# In total we'd need 476 + 20 = 496
LumberCollection.mutate(area, 496)
|> LumberCollection.resources()
|> LumberCollection.summary()
|> IO.puts()
