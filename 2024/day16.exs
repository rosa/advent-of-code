# --- Day 16: Reindeer Maze ---

defmodule Maze do
  def shortest_path(maze), do: shortest_path(maze, %{starting_position(maze) => 0}, %{}, %{}, ending_position(maze))
  def shortest_path(maze, distances, previous, visited, target) do
    u = {v, _} = pick_candidate(distances, visited)
    if v == target do
      # IO.inspect(Map.get(previous, {{10, 3}, ""}))
      {Map.get(distances, u), all_tiles(previous, maze)}
    else
      updated_visited = Map.put(visited, u, true)
      {updated_distances, updated_previous} = neighbours(maze, u, updated_visited) |> update_paths(maze, u, distances, previous)

      shortest_path(maze, updated_distances, updated_previous, updated_visited, target)
    end
  end

  def all_tiles(paths, maze), do: all_tiles(paths, starting_position(maze), {{1,13}, "^"}, []) |> Enum.map(&(elem(&1, 0))) |> Enum.uniq()
  def all_tiles(_, u, u, tiles), do: tiles
  def all_tiles(paths, u, v, tiles) do
    Map.get(paths, v)
    |> Enum.map(fn n -> [n] ++ all_tiles(paths, u, n, tiles) end)
    |> Enum.reduce(&(&1 ++ &2))
  end


  defp pick_candidate(distances, visited) do
    min_dist = Enum.filter(distances, fn {k, _} -> !Map.has_key?(visited, k) end) |> Enum.map(&(elem(&1, 1))) |> Enum.min()
    Enum.find(distances, fn {k, v} -> !Map.has_key?(visited, k) and v == min_dist end) |> elem(0)
  end

  defp update_paths([], _, _, distances, previous), do: {distances, previous}
  defp update_paths([n|neighbours], maze, u, distances, previous) do
    alt = Map.get(distances, u) + distance(n, u)
    cond do
      !Map.has_key?(distances, n) -> update_paths(neighbours, maze, u, Map.put(distances, n, alt), Map.put(previous, n, [u]))
      alt < Map.get(distances, u) -> update_paths(neighbours, maze, u, Map.put(distances, n, alt), Map.put(previous, n, [u]))
      alt == Map.get(distances, u) -> update_paths(neighbours, maze, u, distances, Map.update(previous, n, [u], fn ns -> ns ++ [u] end))
      true -> update_paths(neighbours, maze, u, distances, previous)
    end
  end

  defp neighbours(maze, {v, d}, visited) do
    u = next(v, d)
    if Map.get(maze, u) != "#" do
      [{u, d}] ++ filtered_turns(maze, v, d, visited)
    else
      filtered_turns(maze, v, d, visited)
    end |> Enum.filter(fn n -> !Map.has_key?(visited, n) end)
  end

  defp filtered_turns(maze, v, d, visited) do
    turns(d)
    |> Enum.filter(fn nd -> Map.get(maze, next(v, nd)) != "#" and !Map.has_key?(visited, {next(v, nd), nd}) end)
    |> Enum.map(fn nd -> {v, nd} end)
  end

  defp next({i, j}, "^"), do: {i-1, j}
  defp next({i, j}, ">"), do: {i, j+1}
  defp next({i, j}, "v"), do: {i+1, j}
  defp next({i, j}, "<"), do: {i, j-1}

  defp turns(d) when d in ["v", "^"], do: [">", "<"]
  defp turns(d) when d in [">", "<"], do: ["v", "^"]

  def distance(u, u), do: 0
  def distance({u, du}, {v, dv}) when u != v and du == dv, do: 1
  def distance({u, du}, {v, dv}) when u == v and du != dv, do: 1000

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


  def update([], maze), do: maze
  def update([t|tiles], maze), do: update(tiles, Map.put(maze, t, "O"))
end

maze = Maze.read("inputs/input16.txt")
{distance, tiles} = Maze.shortest_path(maze)
IO.puts(distance)

IO.inspect(tiles)
Maze.update(tiles, maze) |> Maze.print(15, 15)


# shortest_distance = 109496

# --- Part Two ---

# tiles = Maze.all_shortest_paths(maze, shortest_distance) |> IO.inspect()
# IO.puts(MapSet.size(tiles))
# Maze.update(MapSet.to_list(tiles), maze) |> Maze.print(141, 141)
