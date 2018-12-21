# --- Day 20: A Regular Map ---

defmodule RegularMap do
  def read_and_parse_map(file) do
    read(file)
    |> process_regex()
  end

  def furthest_room_distance(map) do
    print_map(map)

    bfs(map)
    |> Map.values()
    |> Enum.max()
  end

  def further_than_1000_count(map) do
    bfs(map)
    |> Map.values()
    |> Enum.count(fn distance -> distance >= 1000 end)
  end

  defp print_map(map) do
    {sx, ex, sy, ey} = dimensions(map)
    for y <- ey..sy do
      Enum.map(sx..ex, fn x -> room_representation(map, {x, y}, {x+1, y}) end)
      |> Enum.join()
      |> IO.puts()
      Enum.map(sx..ex, fn x -> horizontal_separation(map, {x, y}, {x, y-1}) end)
      |> Enum.join()
      |> IO.puts()
    end
  end

  defp room_representation(map, from = {0, 0}, to) do
    if to in map[from], do: "X|", else: "X#"
  end

  defp room_representation(map, from, to) do
    if map[from] do
      if to in map[from], do: ".|", else: ".#"
    else
      "##"
    end
  end

  defp horizontal_separation(map, from, to) do
    if map[from] do
      if to in map[from], do: "-#", else: "##"
    else
      "##"
    end
  end

  defp dimensions(map) do
    keys = Map.keys(map)
    {min_coord(keys, 0), max_coord(keys, 0), min_coord(keys, 1), max_coord(keys, 1)}
  end

  defp max_coord(coords, coord), do: Enum.map(coords, &(elem(&1, coord))) |> Enum.max()
  defp min_coord(coords, coord), do: Enum.map(coords, &(elem(&1, coord))) |> Enum.min()

  def read(file) do
    File.read!(file)
    |> String.trim()
    |> String.graphemes()
  end

  defp process_regex(regex), do: process_regex(%{}, regex, {0, 0}, [])
  defp process_regex(map, [], _current, _stack), do: map
  defp process_regex(map, ["$"], _current, _stack), do: map
  defp process_regex(map, ["^" | regex], current, stack), do: process_regex(map, regex, current, stack)
  defp process_regex(map, [direction | regex], current, stack) when direction in ~w(E W N S) do
    room = move(current, direction)
    add_room(map, current, room)
    |> process_regex(regex, room, stack)
  end
  defp process_regex(map, ["(" | regex], current, stack), do: process_regex(map, regex, current, [current | stack])
  defp process_regex(map, [")" | regex], _current, [current | stack]), do: process_regex(map, regex, current, stack)
  defp process_regex(map, ["|" | regex], _current, [current | stack]), do: process_regex(map, regex, current, [current | stack])

  defp move({x, y}, direction) do
    case direction do
      "E" -> {x+1, y}
      "W" -> {x-1, y}
      "N" -> {x, y+1}
      "S" -> {x, y-1}
    end
  end

  defp add_room(map, from, to) do
    Map.update(map, from, MapSet.new([to]), &(MapSet.put(&1, to)))
    |> Map.update(to, MapSet.new([from]), &(MapSet.put(&1, from)))
  end


  defp bfs(map), do: bfs(map, [{0, 0}], MapSet.new(), %{{0, 0} => 0})
  defp bfs(_map, [], _visited, distances), do: distances
  defp bfs(map, [root | queue], visited, distances) do
    neighbours = neighbours(root, map)
    |> Enum.reject(fn n -> n in visited end)
    |> Enum.reject(fn n -> n in queue end)

    bfs(map, queue ++ neighbours, MapSet.put(visited, root), update_distances(root, neighbours, distances))
  end

  defp neighbours(u, map), do: MapSet.to_list(map[u])

  defp update_distances(_u, [], distances), do: distances
  defp update_distances(u, [v | neighbours], distances) do
    alt = distances[u] + 1
    if is_nil(distances[v]) || alt < distances[v] do
      update_distances(u, neighbours, Map.put(distances, v, alt))
    else
      update_distances(u, neighbours, distances)
    end
  end
end

RegularMap.read_and_parse_map("./inputs/input20.txt")
|> RegularMap.furthest_room_distance()
|> IO.puts()

# --- Part Two ---
RegularMap.read_and_parse_map("./inputs/input20.txt")
|> RegularMap.further_than_1000_count()
|> IO.puts()
