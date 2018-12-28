# --- Day 25: Four-Dimensional Adventure ---

defmodule Constellations do
  def read_and_parse_points(file) do
    read(file)
    |> Enum.map(&parse/1)
  end

  def find_constellations(points), do: find_constellations(points, [])
  def find_constellations([], constellations), do: merge(constellations)
  def find_constellations([point | points], constellations) do
    index = Enum.find_index(constellations, fn c -> in_constellation?(point, c) end)
    if index do
      constellation = Enum.at(constellations, index)
      find_constellations(points, List.replace_at(constellations, index, [point | constellation]))
    else
      find_constellations(points, [[point] | constellations])
    end
  end

  def merge(constellations), do: merge(constellations, constellations, [])
  def merge(initial, [], merged) when length(initial) == length(merged), do: merged
  def merge(_initial, [], merged), do: merge(merged)
  def merge(initial, [constellation | constellations], merged) do
    mergeable = Enum.filter(constellations, fn c -> mergeable?(constellation, c) end)
    merge(initial, constellations -- mergeable, [Enum.reduce([constellation | mergeable], [], fn c, acc -> acc ++ c end) | merged])
  end

  def mergeable?(c1, c2), do: Enum.any?(c1, fn point -> in_constellation?(point, c2) end)

  defp in_constellation?(point, constellation), do: Enum.any?(constellation, fn q -> distance(point, q) <= 3 end)

  defp parse(line), do: String.split(line, ",", trim: true) |> Enum.map(&String.to_integer/1)

  defp distance(p1, p2), do: Enum.zip(p1, p2) |> Enum.map(fn {x, y} -> abs(x - y) end) |> Enum.sum()

  defp read(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
  end
end

Constellations.read_and_parse_points("./inputs/input25.txt")
|> Constellations.find_constellations()
|> Enum.count()
|> IO.puts()

# --- Part Two ---

