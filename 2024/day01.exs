# --- Day 1: Historian Hysteria ---

defmodule Locations do
  def total_distance({locations1, locations2}) do
    Enum.zip_reduce(Enum.sort(locations1), Enum.sort(locations2), 0, fn x, y, acc -> abs(x - y) + acc end)
  end
  def total_distance(path), do: lines(path) |> total_distance()

  def similarity_score({locations1, locations2}) do
    Enum.map(locations1, fn x -> x * Map.get(Enum.frequencies(locations2), x, 0) end)
    |> Enum.sum
  end
  def similarity_score(path), do: lines(path) |> similarity_score()

  defp lines(path) do
    File.read!(path)
    |> String.split(~r{\n}, trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.unzip
  end

  defp parse_line(line) do
    String.split(line, ~r{\s}, trim: true)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end
end

Locations.total_distance("./inputs/input01.txt") |> IO.puts

# --- Part Two ---
Locations.similarity_score("./inputs/input01.txt") |> IO.inspect
