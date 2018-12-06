# --- Day 6: Chronal Coordinates ---

# Your goal is to find the size of the largest area that isn't infinite.
defmodule Coordinates do
  def largest_finite_area(coordinates) do
    boundaries = boundaries(coordinates)
    coordinates
    |> finite_candidates(boundaries)
    |> all_area_sizes(coordinates, boundaries)
    |> Map.values()
    |> Enum.max()
  end

  def largest_close_area(coordinates) do
    boundaries = boundaries(coordinates)
    coordinates
    |> close_points(boundaries)
  end

  def read(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
  end

  def coordinates(lines) do
    Enum.map(lines, fn line -> Enum.map(String.split(line, ~r/\s*,\s*/, trim: true), &String.to_integer/1) end)
    |> Enum.map(fn [x, y] -> {x, y} end)
  end

  defp finite_candidates(coordinates, boundaries) do
    Enum.filter(coordinates, fn coord -> finite_area?(coord, coordinates, boundaries) end)
  end

  defp boundaries(coordinates) do
    { max_x(coordinates), max_y(coordinates) }
  end

  defp max_x(coordinates), do: Enum.map(coordinates, fn {x, _} -> x end) |> Enum.max()
  defp max_y(coordinates), do: Enum.map(coordinates, fn {_, y} -> y end) |> Enum.max()

  defp all_area_sizes(candidates, coordinates, boundaries = {m, n}), do: all_area_sizes(%{}, candidates, coordinates, boundaries, m, n)
  defp all_area_sizes(area_sizes, _candidates, _coordinates, _boundaries, 0, -1), do: area_sizes
  defp all_area_sizes(area_sizes, candidates, coordinates, boundaries = {_, n}, i, -1), do: all_area_sizes(area_sizes, candidates, coordinates, boundaries, i-1, n)
  defp all_area_sizes(area_sizes, candidates, coordinates, boundaries, i, j) do
    find_closest({i, j}, coordinates)
    |> update_area_sizes(candidates, area_sizes)
    |> all_area_sizes(candidates, coordinates, boundaries, i, j-1)
  end

  defp close_points(coordinates, boundaries = {m, n}), do: close_points(0, coordinates, boundaries, m, n)
  defp close_points(close_points, _coordinates, _boundaries, 0, -1), do: close_points
  defp close_points(close_points, coordinates, boundaries = {_, n}, i, -1), do: close_points(close_points, coordinates, boundaries, i-1, n)
  defp close_points(close_points, coordinates, boundaries, i, j) do
    if sum_of_distances({i, j}, coordinates) < 10000 do
      close_points(close_points + 1, coordinates, boundaries, i, j-1)
    else
      close_points(close_points, coordinates, boundaries, i, j-1)
    end
  end

  defp sum_of_distances(coord, coordinates) do
    Enum.map(coordinates, fn other -> {other, distance(coord, other)} end)
    |> Enum.map(fn {_, distance} -> distance end)
    |> Enum.sum()
  end

  defp find_closest(coord, coordinates) do
    distances = Enum.map(coordinates, fn other -> {other, distance(coord, other)} end)
    {_, closest_distance} = Enum.min_by(distances, fn {_, distance} -> distance end)

    Enum.filter(distances, fn {_, distance} -> distance == closest_distance end)
  end

  defp update_area_sizes([{closest, _}], candidates, area_sizes) do
    if closest in candidates do
      Map.update(area_sizes, closest, 1, &(&1 + 1))
    else
      area_sizes
    end
  end
  defp update_area_sizes(_closest_distances, _candidates, area_sizes), do: area_sizes


  defp distance({x, y}, {u, v}), do: abs(x - u) + abs(y - v)

  defp finite_area?(coord, coordinates, boundaries) do
    bounds = List.delete(coordinates, coord)
    |> bounds(coord)

    Enum.count(bounds) == 4 && !can_escape?(coord, coordinates, boundaries)
  end

  defp bounds(coordinates, {x, y}) do
    [Enum.find(coordinates, fn {u, _} -> u < x end),
     Enum.find(coordinates, fn {u, _} -> u > x end),
     Enum.find(coordinates, fn {_, v} -> v < y end),
     Enum.find(coordinates, fn {_, v} -> v > y end)]
    |> Enum.filter(fn b -> !is_nil(b) end)
  end

  defp can_escape?({x, y}, coordinates, {m, n}) do
    first = fn collection -> Enum.map(collection, fn {a, _} -> a end) end

    Enum.any?([{0, y}, {m, y}, {x, 0}, {x, n}], fn coord -> {x, y} in first.(find_closest(coord, coordinates)) end)
  end
end

Coordinates.read("./inputs/input06.txt") |> Coordinates.coordinates() |> Coordinates.largest_finite_area() |> IO.puts()

# --- Part Two ---
Coordinates.read("./inputs/input06.txt") |> Coordinates.coordinates() |> Coordinates.largest_close_area() |> IO.puts()

