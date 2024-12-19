# --- Day 18: RAM Run ---

defmodule Ram do
  def first_blocking_byte([byte|bytes], grid, m, n) do
    updated_grid = Map.put(grid, byte, "#")

    if shortest_path(updated_grid, m, n) == :no_path do
      byte |> Tuple.to_list() |> Enum.join(",")
    else
      first_blocking_byte(bytes, updated_grid, m, n)
    end
  end

  def shortest_path(grid, m, n), do: shortest_path(grid, [{0, 0}], {m, n}, %{{0,0} => 0}, %{})
  def shortest_path(_, [v|_], v, distances, _), do: Map.get(distances, v)
  def shortest_path(_, [], _, _, _), do: :no_path
  def shortest_path(grid, [v|coords], target, distances, path) do
    neighbours = neighbours(grid, v, distances, target)
    updated_distances = update_map(neighbours, Map.get(distances, v) + 1, distances)
    updated_path = update_map(neighbours, v, path)

    shortest_path(grid, coords ++ neighbours, target, updated_distances, updated_path)
  end

  defp neighbours(grid, {x, y}, distances, dims) do
    [{x-1, y}, {x, y+1}, {x+1, y}, {x, y-1}]
    |> Enum.filter(fn u -> !Map.has_key?(distances, u) and !corrupted?(grid, u) and within_bounds?(u, dims) end)
  end

  defp corrupted?(grid, u), do: Map.get(grid, u) == "#"
  defp within_bounds?({x, y}, {m, n}), do: x >= 0 and y >= 0 and x <= m and y <= n

  defp update_map(keys, value, map) do
    Enum.map(keys, fn key -> {key, value} end)
    |> Enum.into(%{})
    |> Map.merge(map)
  end

  def print(grid, m, n) do
    (for x <- 0..m, y <- 0..n, do: Map.get(grid, {y, x}, "."))
    |> Enum.chunk_every(m+1)
    |> Enum.map(&Enum.join/1)
    |> Enum.join("\n")
    |> IO.puts()
  end

  def read(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
    |> parse_positions([])
  end

  def build_grid(positions), do: update_map(positions, "#", %{})

  defp parse_positions([], parsed), do: parsed
  defp parse_positions([line|lines], parsed) do
    pos = String.split(line, ",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()

    parse_positions(lines, parsed ++ [pos])
  end
end

bytes = Ram.read("inputs/input18.txt")
memory = Ram.build_grid(Enum.take(bytes, 1024))
Ram.shortest_path(memory, 70, 70) |> IO.puts()

# --- Part Two ---

Ram.first_blocking_byte(Enum.drop(bytes, 1024), memory, 70, 70) |> IO.puts()
