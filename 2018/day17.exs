# --- Day 17: Reservoir Research ---

defmodule Reservoir do
  def read_and_parse_clay(file) do
    read(file)
    |> parse_clay()
    |> normalize()
  end

  def print_reservoir(sand, water) do
    {n, m} = bounds(sand)
    IO.puts(List.duplicate(".", n) |> List.insert_at(elem(water, 0), "+") |> Enum.join())
    for y <- 1..m do
      Enum.map(0..n, fn x -> sand[{x, y}] || "." end) |> Enum.join() |> IO.puts()
    end
    IO.puts("\n")
    :ok
  end

  def fill_and_count_water({water, sand}) do
    {min_y, max_x, max_y} = Reservoir.bounds(sand)
    filled = fill_with_water(water, sand, {max_x, max_y})
    |> Enum.reject(fn {{_, y}, _} -> y < min_y end)
    |> Enum.map(&(elem(&1, 1)))

    flowing = Enum.count(filled, fn v -> v == "|" end)
    at_rest = Enum.count(filled, fn v -> v == "~" end)
    {flowing, at_rest, flowing + at_rest}
  end

  defp fill_with_water(water, sand, bounds), do: expand_vertically(sand, water, bounds)

  defp expand_vertically(sand, {x, y}, {n, m}) when x < 0 or y < 0 or x > n or y > m-1, do: sand
  defp expand_vertically(sand, from = {x, y}, bounds) do
    case sand[{x, y+1}] do
      nil -> Map.put(sand, {x, y+1}, "|") |> expand_vertically({x, y+1}, bounds)
      "#" -> expand_horizontally(sand, {x, y}, bounds)
      "~" -> expand_horizontally(sand, {x, y}, bounds)
      "|" -> sand
    end
  end

  defp expand_horizontally(sand, from = {x, y}, bounds) do
    left_limit = limit(sand, -1, from, bounds)
    right_limit = limit(sand, 1, from, bounds)
    cond do
      left_limit && right_limit -> rest(sand, left_limit, right_limit) |> expand_horizontally({x, y - 1}, bounds)
      left_limit -> fall(sand, 1, left_limit, bounds)
      right_limit -> fall(sand, -1, right_limit, bounds)
      true -> fall(sand, -1, from, bounds) |> fall(1, from, bounds)
    end
  end

  defp rest(sand, {x1, y}, {x2, y}) when x2 < x1, do: sand
  defp rest(sand, {x1, y}, {x2, y}) do
    Map.put(sand, {x1, y}, "~")
    |> rest({x1 + 1, y}, {x2, y})
  end

  defp fall(sand, dir, from = {x, y}, bounds) do
    cond do
      sand[from] == "~" -> sand
      free_fall?(sand, from, bounds) -> Map.put(sand, from, "|") |> expand_vertically(from, bounds)
      true -> Map.put(sand, from, "|") |> fall(dir, {x + dir, y}, bounds)
    end
  end

  defp limit(sand, dir, from = {x, y}, bounds) do
    cond do
      sand[from] == "#" -> {x - dir, y}
      cornered?(sand, dir, from, bounds) -> from
      free_fall?(sand, from, bounds) -> nil
      true -> limit(sand, dir, {x + dir, y}, bounds)
    end
  end

  #  #.      .#     #.  .#
  #  ##  or  ##  or #~  ~#
  defp cornered?(sand, dir, {x, y}, {n, m}) do
    x >= 0 && y >= 1 && x <= n && y <= m && (sand[{x, y+1}] in ["#", "~"]) && (sand[{x+dir, y}] == "#") && (sand[{x+dir, y+1}] == "#")
  end

  defp free_fall?(sand, {x, y}, {n, m}) do
    x < 0 || x > n || y > m || is_nil(sand[{x, y+1}]) || sand[{x, y+1}] == "|"
  end

  defp parse_clay(lines) when is_list(lines), do: parse_clay(lines, [])
  # x=547, y=508..535
  # y=868, x=516..535
  defp parse_clay(line) do
    parsed = Regex.named_captures(~r/(?<single_coord>x|y)=(?<single>\d+),\s+(y|x)=(?<range>\d+..\d+)/, line)
    case parsed["single_coord"] do
      "x" -> {String.to_integer(parsed["single"]), parse_range(parsed["range"])}
      "y" -> {parse_range(parsed["range"]), String.to_integer(parsed["single"])}
    end
  end
  defp parse_clay([], parsed), do: parsed
  defp parse_clay([line | lines], parsed), do: parse_clay(lines, [parse_clay(line) | parsed])

  defp normalize(sand) do
    min_x = Enum.min(sand, fn {x, _} -> if is_integer(x), do: x, else: Enum.min(x) end) |> elem(0)
    normalized = Enum.map(sand, &expand_range/1)
    |> List.flatten()
    |> Enum.map(fn {x, y} -> {x - min_x + 1, y} end)
    |> Enum.reduce(%{}, fn k, acc -> Map.put(acc, k, "#") end)

    {{500 - min_x + 1, 0}, normalized}
  end

  defp parse_range(range) do
    [a1, a2] = String.split(range, "..") |> Enum.map(&String.to_integer/1)
    a1..a2
  end

  defp expand_range({x, y1..y2}), do: Enum.reduce(y1..y2, [], fn y, acc -> [{x, y} | acc] end)
  defp expand_range({x1..x2, y}), do: Enum.reduce(x1..x2, [], fn x, acc -> [{x, y} | acc] end)

  def bounds(sand) do
    {min_coord(Map.keys(sand), 1), max_coord(Map.keys(sand), 0), max_coord(Map.keys(sand), 1)}
  end

  defp max_coord(coords, coord), do: Enum.map(coords, &(elem(&1, coord))) |> Enum.max()
  defp min_coord(coords, coord), do: Enum.map(coords, &(elem(&1, coord))) |> Enum.min()

  defp read(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
  end
end

Reservoir.read_and_parse_clay("./inputs/input17.txt")
|> Reservoir.fill_and_count_water()
|> IO.inspect()

# --- Part Two ---
# How many water tiles are left after the water spring stops producing water and all remaining water not at rest has drained?
# Done with part One

