# --- Day 6: Guard Gallivant ---

defmodule GuardRoute do
  def simulate({current={i, j, _}, m, n, grid}), do: simulate(current, m, n, grid, %{{i, j} => true}, %{current => true})

  def simulate(current, m, n, grid, visited, loop) do
    next = {i, j, _} = advance(current, grid)
    cond do
      Map.has_key?(loop, next) -> :infinite_loop
      i < 0 or j < 0 or i >= m or j >= n -> map_size(visited)
      true -> simulate(next, m, n, grid, Map.put(visited, {i, j}, true), Map.put(loop, next, true))
    end
  end

  def find_all_infinite_loops({current, m, n, grid}) do
    is = Enum.to_list(0..m - 1)
    js = Enum.to_list(0..n - 1)

    Enum.map(is, fn i -> Enum.map(js, fn j -> infinite_loop_score({i, j}, current, m, n, grid) end) |> Enum.sum end) |> Enum.sum
  end

  def infinite_loop_score(obstacle, current={ci, cj, _}, m, n, grid) do
    cond do
      obstacle == {ci, cj} -> 0
      Map.has_key?(grid, obstacle) -> 0
      simulate({current, m, n, Map.put(grid, obstacle, "#")}) == :infinite_loop -> 1
      true -> 0
    end
  end

  defp advance({i, j, direction}, grid) do
    {ni, nj} = move(i, j, direction)
    case Map.get(grid, {ni, nj}) do
      "#" -> {i, j, turn(direction)}
      nil -> {ni, nj, direction}
    end
  end

  defp move(i, j, "^"), do: { i - 1, j }
  defp move(i, j, ">"), do: { i, j + 1 }
  defp move(i, j, "v"), do: { i + 1, j }
  defp move(i, j, "<"), do: { i, j - 1}

  defp turn("^"), do: ">"
  defp turn(">"), do: "v"
  defp turn("v"), do: "<"
  defp turn("<"), do: "^"

  def read_map(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
    |> Enum.map(&String.graphemes/1)
    |> parse_map()
  end

  defp parse_map(lines), do: parse_map(lines, {nil, length(lines), length(hd(lines)), %{}}, 0)
  defp parse_map([], map, _), do: map
  defp parse_map([row | rows], map, i) do
    updated_map = parse_map(row, map, i, 0)
    parse_map(rows, updated_map, i + 1)
  end

  defp parse_map([], map, _, _), do: map
  defp parse_map(["." | row], map, i, j), do: parse_map(row, map, i, j + 1)
  defp parse_map(["#" | row], {start, m, n, grid}, i, j) do
    parse_map(row, {start, m, n, Map.put(grid, {i, j}, "#")}, i, j + 1)
  end
  defp parse_map(["^" | row], {nil, m, n, grid}, i, j) do
    parse_map(row, {{i, j, "^"}, m, n, grid}, i, j + 1)
  end
end

GuardRoute.read_map("inputs/input06.txt") |> GuardRoute.simulate |> IO.puts

# --- Part Two ---

GuardRoute.read_map("inputs/input06.txt") |> GuardRoute.find_all_infinite_loops |> IO.puts
