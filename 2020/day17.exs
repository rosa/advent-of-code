# --- Day 17: Conway Cubes ---

defmodule CubesOfLife do
  def boot(pocket, dimensions), do: boot(pocket, limits(pocket, dimensions), 1, dimensions)
  def boot(pocket, _, 7, _), do: pocket
  def boot(pocket, limits, cycle, dimensions) do
    simulate_cycle(pocket, limits, dimensions)
    |> boot(extend_limits(limits), cycle + 1, dimensions)
  end

  def count_active_cubes(pocket), do: Map.values(pocket) |> Enum.count(&(&1 == "#"))

  def read_starting_state(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
    |> Enum.map(&String.graphemes/1)
    |> parse_dimension()
  end

  defp limits(pocket, dimensions) do
    {min, max} = Map.keys(pocket)
    |> Enum.flat_map(&Tuple.to_list/1)
    |> Enum.min_max

    if dimensions == 3 do
      {min - 1, max + 1, min - 1, max + 1, -1, 1, 0, 0}
    else
      {min - 1, max + 1, min - 1, max + 1, -1, 1, -1, 1}
    end
  end

  defp simulate_cycle(pocket, {x1, x2, y1, y2, z1, z2, w1, w2}, dimensions) do
    (for x <- x1..x2, y <- y1..y2, z <- z1..z2, w <- w1..w2, do: {x, y, z, w})
    |> Enum.reduce(%{}, fn ({x, y, z, w}, acc) -> Map.put(acc, {x, y, z, w}, next_cube_state(pocket, {x, y, z, w}, dimensions)) end)
  end

  defp extend_limits({x1, x2, y1, y2, z1, z2, w1, w2}) do
    {x1 - 1, x2 + 1, y1 - 1, y2 + 1, z1 - 1, z2 + 1, (if w1 == 0, do: 0, else: w1 - 1), (if w2 == 0, do: 0, else: w2 + 1)}
  end

  defp next_cube_state(pocket, cube, dimensions) do
    neighbours(cube, dimensions)
    |> Enum.map(fn n -> pocket[n] end)
    |> Enum.reject(&is_nil/1)
    |> calculate_state(pocket[cube])
  end

  # During a cycle, all cubes simultaneously change their state according to the following rules:
  # If a cube is active and exactly 2 or 3 of its neighbors are also active, the cube remains active. Otherwise, the cube becomes inactive.
  # If a cube is inactive but exactly 3 of its neighbors are active, the cube becomes active. Otherwise, the cube remains inactive.
  defp calculate_state(neighbour_states, "#") do
    if Enum.count(neighbour_states) in [2, 3], do: "#", else: nil
  end
  defp calculate_state(neighbour_states, nil) do
    if Enum.count(neighbour_states) == 3, do: "#", else: nil
  end

  defp neighbours({i, j, k, l}, dimensions) do
    (for x <- -1..1, y <- -1..1, z <- -1..1, w <- (if dimensions == 3, do: 0..0, else: -1..1), do: {x, y, z, w})
    |> Enum.reject(&(&1 == {0, 0, 0, 0}))
    |> Enum.map(fn {x, y, z, w} -> {i + x, j + y, k + z, l + w} end)
  end

  defp parse_dimension(lines), do: parse_dimension(lines, %{}, 0)
  defp parse_dimension([], dimension, _), do: dimension
  defp parse_dimension([row | rows], dimension, i) do
    updated_dimension = parse_dimension(row, dimension, i, 0)
    parse_dimension(rows, updated_dimension, i + 1)
  end

  defp parse_dimension([], dimension, _, _), do: dimension
  defp parse_dimension(["." | row], dimension, i, j), do: parse_dimension(row, dimension, i, j + 1)
  defp parse_dimension(["#" | row], dimension, i, j) do
    parse_dimension(row, Map.put(dimension, {i, j, 0, 0}, "#"), i, j + 1)
  end
end

CubesOfLife.read_starting_state("inputs/input17.txt") |> CubesOfLife.boot(3) |> CubesOfLife.count_active_cubes() |> IO.puts

# --- Part Two ---

CubesOfLife.read_starting_state("inputs/input17.txt") |> CubesOfLife.boot(4) |> CubesOfLife.count_active_cubes() |> IO.puts
