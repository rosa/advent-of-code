# --- Day 8: Resonant Collinearity ---

defmodule Antennas do
  def antinodes(map = {_, _, antennas}, harmonics \\ false) do
    Map.keys(antennas)
    |> Enum.map(fn antenna -> antinodes(antenna, map, harmonics) end)
    |> List.flatten
    |> Enum.into(MapSet.new())
  end

  def antinodes(antenna, {m, n, antennas}, harmonics), do: antinodes(m, n, Map.get(antennas, antenna), harmonics)
  def antinodes(m, n, positions, harmonics) do
    for x <- positions, y <- positions, x != y, do: antinodes(m, n, x, y, harmonics)
  end

  def antinodes(m, n, x, y, false), do: antinodes(m, n, x, y, 1)
  def antinodes(m, n, x, y, true), do: antinodes(m, n, x, y, 0, [])

  def antinodes(m, n, {xi, xj}, {yi, yj}, h) do
    nx = within_bounds(m, n, {xi + h*(xi - yi), xj + h*(xj - yj)})
    ny = within_bounds(m, n, {yi + h*(yi - xi), yj + h*(yj - xj)})

    [nx, ny] |> Enum.reject(&is_nil/1)
  end

  def antinodes(m, n, x, y, h, antinodes) do
    new_set = antinodes(m, n, x, y, h)
    if Enum.empty?(new_set), do: antinodes, else: antinodes(m, n, x, y, h + 1, antinodes ++ new_set)
  end

  def within_bounds(m, n, {i, j}) do
    if i >= 0 and j >= 0 and i < m and j < n, do: {i, j}, else: nil
  end

  def read_map(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
    |> Enum.map(&String.graphemes/1)
    |> parse_map()
  end

  defp parse_map(lines), do: parse_map(lines, {length(lines), length(hd(lines)), %{}}, 0)
  defp parse_map([], map, _), do: map
  defp parse_map([row | rows], map, i) do
    parse_map(rows, parse_map(row, map, i, 0), i + 1)
  end

  defp parse_map([], map, _, _), do: map
  defp parse_map(["." | row], map, i, j), do: parse_map(row, map, i, j + 1)
  defp parse_map([antenna | row], {m, n, antennas}, i, j) do
    parse_map(row, {m, n, update_antennas(antennas, antenna, i, j)}, i, j + 1)
  end
  defp update_antennas(antennas, antenna, i, j) do
    if Map.has_key?(antennas, antenna) do
      Map.put(antennas, antenna, Map.get(antennas, antenna) ++ [{i, j}])
    else
      Map.put(antennas, antenna, [{i, j}])
    end
  end
end

Antennas.read_map("inputs/input08.txt") |> Antennas.antinodes() |> MapSet.size() |> IO.puts

# --- Part Two ---

Antennas.read_map("inputs/input08.txt") |> Antennas.antinodes(true) |> MapSet.size() |> IO.puts
