# --- Day 12: Garden Groups ---

defmodule Garden do
  alias Garden.Plot

  def price_by_sides(map), do: plots(map) |> price_by_sides(map)
  def price_by_sides(plots, map) do
    Enum.map(plots, &(Plot.price_by_sides(&1, map)))
    |> Enum.sum()
  end

  def price_by_perimeter(map), do: plots(map) |> price_by_perimeter(map)
  def price_by_perimeter(plots, map) do
    Enum.map(plots, &(Plot.price_by_perimeter(&1, map)))
    |> Enum.sum()
  end

  def plots(map), do: plots(map, %{}, Map.keys(map), [])
  def plots(_, _, [], plots), do: plots
  def plots(map, visited, [pos|positions], plots) do
    if Map.has_key?(visited, pos) do
      plots(map, visited, positions, plots)
    else
      {plot, updated_visited} = plot(map, visited, Map.get(map, pos), [pos])
      plots(map, updated_visited, positions, [plot|plots])
    end
  end

  def plot(map, visited, type, positions) when is_list(positions), do: plot(map, visited, positions, Plot.new(type, []))
  def plot(_, visited, [], plot), do: {plot, visited}
  def plot(map, visited, [pos|positions], plot) do
    if Map.has_key?(visited, pos) do
      plot(map, visited, positions, plot)
    else
      updated_visited = Map.put(visited, pos, true)
      updated_plot = Plot.add(plot, pos)
      plot(map, updated_visited, neighbours(pos, plot.type, updated_visited, map) ++ positions, updated_plot)
    end
  end

  def neighbours({i, j}, v, visited, map) do
    # Up, right, down, left
    [{i-1, j}, {i, j+1}, {i+1, j}, {i, j-1}]
    |> Enum.filter(fn x -> !Map.has_key?(visited, x) and Map.get(map, x) == v end)
  end

  def read_map(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
    |> Enum.map(&String.graphemes/1)
    |> parse_map()
  end

  defp parse_map(lines), do: parse_map(lines, %{}, 0)
  defp parse_map([], map, _), do: map
  defp parse_map([row | rows], map, i) do
    updated_map = parse_map(row, map, i, 0)
    parse_map(rows, updated_map, i + 1)
  end

  defp parse_map([], map, _, _), do: map
  defp parse_map([cell | row], map, i, j) do
    parse_map(row, Map.put(map, {i, j}, cell), i, j + 1)
  end
end

defmodule Garden.Plot do
  defstruct(
    type: "",
    positions: []
  )

  def new(type, positions) do
    %Garden.Plot{
      type: type,
      positions: positions
    }
  end

  def add(plot, position), do: %{plot | positions: [position|plot.positions]}

  def price_by_perimeter(plot, map), do: area(plot) * perimeter_length(plot, map)

  def price_by_sides(plot, map), do: area(plot) * sides(plot, map)

  def area(plot), do: Enum.count(plot.positions)

  defp perimeter_length(plot, map) do
    Enum.map(plot.positions, fn pos -> fences(pos, plot.type, map) end)
    |> Enum.sum()
  end

  defp sides(plot, map) do
    # Up, down, left, right
    [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]
    |> Enum.map(fn {is, js} -> sides(perimeter(plot, map, {is, js}), abs(js), abs(is)) end)
    |> Enum.sum
  end

  defp sides(perimeter, x, y) do
    rows_or_cols = Enum.map(perimeter, &(elem(&1, x))) |> Enum.uniq()

    for i <- rows_or_cols do
      Enum.filter(perimeter, &(elem(&1, x) == i))
      |> Enum.sort()
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [p1, p2] -> elem(p2, y) - elem(p1, y) end)
      |> Enum.count(&(&1 > 1))
    end |> Enum.map(&(&1 + 1)) |> Enum.sum
  end

  defp perimeter(plot, map, {is, js}) do
    Enum.filter(plot.positions, fn {i, j} -> fence({i + is, j + js}, plot.type, map) > 0 end)
  end

  defp fences({i, j}, v, map) do
    [{i-1, j}, {i, j+1}, {i+1, j}, {i, j-1}]
    |> Enum.map(fn x -> fence(x, v, map) end)
    |> Enum.sum()
  end

  defp fence(x, v, map), do: (if Map.get(map, x) == v, do: 0, else: 1)
end


Garden.read_map("inputs/input12.txt") |> Garden.price_by_perimeter() |> IO.puts

# --- Part Two ---

Garden.read_map("inputs/input12.txt") |> Garden.price_by_sides() |> IO.puts
