# --- Day 16: Reindeer Maze ---

defmodule Maze do
  def shortest_paths(maze), do: shortest_paths(maze, %{starting_position(maze) => 0}, %{}, %{}, ending_position(maze))
  def shortest_paths(maze, distances, paths, visited, target) do
    u = {v, _} = pick_candidate(distances, visited)
    if v == target do
      {Map.get(distances, u), all_tiles(maze, distances, paths, u)}
    else
      updated_visited = Map.put(visited, u, true)
      {updated_distances, updated_paths} = neighbours(maze, u, updated_visited) |> update_paths( u, distances, paths)

      shortest_paths(maze, updated_distances, updated_paths, updated_visited, target)
    end
  end

  defp all_tiles(maze, distances, paths, target) do
    all_tiles(distances, paths, starting_position(maze), target, [target])
    |> Enum.map(&(elem(&1, 0)))
    |> Enum.uniq()
  end
  defp all_tiles(_, _, u, u, tiles), do: tiles
  defp all_tiles(distances, paths, u, v, tiles) do
    Map.get(paths, v)
    |> Enum.filter(fn n -> part_of_best_path?(distances, n, v) end)
    |> Enum.map(fn n -> [n] ++ all_tiles(distances, paths, u, n, tiles) end)
    |> Enum.reduce(&(&1 ++ &2))
  end

  defp part_of_best_path?(distances, n, v) do
    Map.get(distances, n) + distance(n, v) <= Map.get(distances, v)
  end

  defp pick_candidate(distances, visited) do
    Enum.filter(distances, fn {k, _} -> !Map.get(visited, k) end)
    |> Enum.min_by(fn {_, d} -> d end)
    |> elem(0)
  end

  defp update_paths([], _, distances, previous), do: {distances, previous}
  defp update_paths([n|neighbours], u, distances, previous) do
    dist = Map.get(distances, u) + distance(n, u)
    update_paths(neighbours, u, Map.put(distances, n, dist), Map.update(previous, n, [u], fn ns -> ns ++ [u] end))
  end

  defp neighbours(maze, {v, d}, visited) do
    [{next(v, d), d}] ++ all_turns(v, d)
    |> Enum.filter(fn {u, d} -> valid?(maze, u) && !Map.get(visited, {u, d}) end)
  end

  defp all_turns(v, d) do
    turns(d) |> Enum.map(fn nd -> {v, nd} end)
  end

  defp valid?(maze, u), do: Map.get(maze, u) |> valid?()
  defp valid?(c), do: c in [".", "S", "E"]

  defp next({i, j}, "^"), do: {i-1, j}
  defp next({i, j}, ">"), do: {i, j+1}
  defp next({i, j}, "v"), do: {i+1, j}
  defp next({i, j}, "<"), do: {i, j-1}

  defp turns(d) when d in ["v", "^"], do: [">", "<"]
  defp turns(d) when d in [">", "<"], do: ["v", "^"]

  def distance(u, u), do: 0
  def distance({u, du}, {v, du}) when u != v, do: 1
  def distance({u, du}, {u, dv}) when du != dv, do: 1000

  defp starting_position(maze), do: {Enum.find(maze, fn {_, v} -> v == "S" end) |> elem(0), ">"}
  defp ending_position(maze), do: Enum.find(maze, fn {_, v} -> v == "E" end) |> elem(0)

  def print(maze, m, n) do
    (for x <- 0..m-1, y <- 0..n-1, do: Map.get(maze, {x, y}))
    |> Enum.chunk_every(n)
    |> Enum.map(&Enum.join/1)
    |> Enum.join("\n")
    |> IO.puts()
  end

  def read(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
    |> parse_maze()
  end

  defp parse_maze(lines), do: parse_maze(lines, %{}, 0)
  defp parse_maze([], maze, _), do: maze
  defp parse_maze([line | lines], maze, i) do
    updated_maze = parse_maze(String.graphemes(line), maze, i, 0)
    parse_maze(lines, updated_maze, i + 1)
  end

  defp parse_maze([], maze, _, _), do: maze
  defp parse_maze([c | row], maze, i, j), do: parse_maze(row, Map.put(maze, {i, j}, c), i, j + 1)
end

{distance, tiles} = Maze.read("inputs/input16.txt") |> Maze.shortest_paths()
IO.puts(distance)

# --- Part Two ---

Enum.count(tiles) |> IO.puts()
