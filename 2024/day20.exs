# --- Day 20: Race Condition ---

defmodule Track do
  def count_good_cheats(track, cheat_mode) do
    cheats(track, cheat_mode)
    |> Map.values()
    |> Enum.frequencies()
    |> Enum.filter(fn {saving, _} -> saving >= 100 end)
    |> Enum.map(&(elem(&1, 1)))
    |> Enum.sum()
  end

  defp cheats(track, cheat_mode) do
    s = starting_position(track)
    e = ending_position(track)

    single_path = single_path(track, s, e)
    distances = distances(single_path, s, e)

    cheats(track, s, e, single_path, distances, cheat_mode)
    |> Enum.flat_map(fn {origin, cheats} -> savings(origin, cheats, distances) end)
    |> Enum.into(%{})
  end

  defp cheats(track, u, e, path, distances, cheat_mode), do: cheats(track, u, e, path, distances, %{}, cheat_mode)
  defp cheats(_, e, e, _, _, from, _), do: from
  defp cheats(track, u, e, path, distances, from, cheat_mode) do
    candidates = end_positions(track, u, distances, cheat_mode)
    updated_from = if Enum.any?(candidates), do: Map.put(from, u, candidates), else: from
    cheats(track, Map.get(path, u), e, path, distances, updated_from, cheat_mode)
  end

  defp savings(origin, cheats, distances) do
    Enum.map(cheats, fn {x, y, d} -> {{origin, {x, y}}, Map.get(distances, origin) - Map.get(distances, {x, y}) - d} end)
  end

  defp end_positions(track, origin = {i, j}, distances, cheat_mode) do
    (for l <- 2..cheat_mode, x <- 0..l, y <- 0..l, x+y == l, do: [{i-x, j-y, l}, {i-x, j+y, l}, {i+x, j-y, l}, {i+x, j+y, l}])
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.filter(fn {x, y, _} -> track?(track, {x, y}) and {x, y} != origin and Map.has_key?(distances, {x, y}) end)
  end

  defp single_path(track, s, e), do: single_path(track, s, e, %{s => true}, %{})
  defp single_path(_, u, u, _, path), do: path
  defp single_path(track, u, v, visited, path) do
    n = next(track, u, visited)
    single_path(track, n, v, Map.put(visited, n, true), Map.put(path, u, n))
  end

  defp distances(path, s, e), do: distances(path, s, e, %{s => map_size(path), e => 0})
  defp distances(_, e, e, dists), do: dists
  defp distances(path, u, e, dists) do
    n = Map.get(path, u)
    distances(path, n, e, Map.put(dists, n, Map.get(dists, u) - 1))
  end

  defp next(track, {i, j}, visited) do
    [{i-1, j}, {i, j+1}, {i+1, j}, {i, j-1}]
    |> Enum.find(fn u -> !Map.has_key?(visited, u) and track?(track, u) end)
  end

  defp track?(track, u), do: Map.get(track, u) in [".", "E"]

  defp starting_position(track), do: find_in_track(track, "S")
  defp ending_position(track), do: find_in_track(track, "E")
  defp find_in_track(track, char), do: Enum.find(track, fn {_, v} -> v == char end) |> elem(0)

  def print(track, m, n) do
    (for i <- 0..m-1, j <- 0..n-1, do: Map.get(track, {i, j}))
    |> Enum.chunk_every(n)
    |> Enum.map(&Enum.join/1)
    |> Enum.join("\n")
    |> IO.puts()
  end

  def read(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
    |> parse_track()
  end

  defp parse_track(lines), do: parse_track(lines, %{}, 0)
  defp parse_track([], track, _), do: track
  defp parse_track([line | lines], track, i) do
    updated_track = parse_track(String.graphemes(line), track, i, 0)
    parse_track(lines, updated_track, i + 1)
  end

  defp parse_track([], track, _, _), do: track
  defp parse_track([c | row], track, i, j), do: parse_track(row, Map.put(track, {i, j}, c), i, j + 1)
end

Track.read("inputs/input20.txt") |> Track.count_good_cheats(2) |> IO.puts()

# --- Part Two ---

Track.read("inputs/input20.txt") |> Track.count_good_cheats(20) |> IO.puts()
