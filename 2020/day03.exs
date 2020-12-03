# --- Day 3: Toboggan Trajectory ---

defmodule Trajectory do
  def move_and_count_trees(map, slopes) when is_list(slopes) do
    Enum.map(slopes, fn slope -> move_and_count_trees(map, slope) end)
    |> Enum.reduce(&(&1 * &2))
  end

  def move_and_count_trees(map, slope), do: move_and_count_trees(map, slope, {0, 0}, 0)
  def move_and_count_trees({trees, _}, _, {i, _}, count) when map_size(trees) == i, do: count
  def move_and_count_trees({trees, width}, slope, position, count) do
    move_and_count_trees({trees, width}, slope, move(slope, position, width), (if trees[position] == "#", do: count + 1, else: count))
  end

  def read_and_parse_map(file) do
    lines = read(file)
    { parse_map(lines), width(lines) }
  end

  defp move({x, y}, {i, j}, width), do: {i + x, rem(j + y, width) }

  defp parse_map(lines), do: parse_map(lines, %{}, 0)
  defp parse_map([], trees, _i), do: trees
  defp parse_map([row | rows], trees, i) do
    updated_trees = parse_map(row, trees, i, 0)
    parse_map(rows, updated_trees, i + 1)
  end

  defp parse_map([], trees, _i, _j), do: trees
  defp parse_map(["." | row], trees, i, j), do: parse_map(row, trees, i, j + 1)
  defp parse_map(["#" | row], trees, i, j) do
    parse_map(row, Map.put(trees, {i, j}, "#"), i, j + 1)
  end

  defp width(lines) do
    lines
    |> List.first()
    |> Enum.count()
  end

  defp read(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
    |> Enum.map(&String.graphemes/1)
  end
end

Trajectory.read_and_parse_map("inputs/input03.txt") |> Trajectory.move_and_count_trees({1, 3}) |> IO.puts

# --- Part Two ---

# Right 1, down 1.
# Right 3, down 1. (This is the slope you already checked.)
# Right 5, down 1.
# Right 7, down 1.
# Right 1, down 2.

Trajectory.read_and_parse_map("inputs/input03.txt") |> Trajectory.move_and_count_trees([{1, 1}, {1, 3}, {1, 5}, {1, 7}, {2, 1}]) |> IO.puts
