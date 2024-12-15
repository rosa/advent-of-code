# --- Day 15: Warehouse Woes ---

defmodule Warehouse do
  def gps_coordinates(map) do
    Enum.filter(map, fn {_, v} -> v in ["O", "["] end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.map(fn {i, j} -> 100*i + j end)
    |> Enum.sum()
  end

  def simulate({map, moves}), do: simulate({map, starting_position(map)}, moves)
  def simulate({map, _}, []), do: map
  def simulate(position, [m|moves]), do: move(position, m, "@") |> simulate(moves)

  defp move(position = {map, {i, j}}, m, item) do
    next = {ni, nj} = next(i, j, m)

    case Map.get(map, next) do
      "#" -> position
      "." -> {Map.put(map, next, item) |> Map.put({i, j}, "."), next}
      "[" -> push_half_box(position, m, next, {ni, nj+1}, "[", "]", item)
      "]" -> push_half_box(position, m, next, {ni, nj-1}, "]", "[", item)
      "O" -> push_box(position, m, next, item)
    end
  end

  defp push_half_box(position, m, box1, _, item1, _, item) when m in ["<", ">"], do: push_box(position, m, box1, item, item1)
  defp push_half_box(position = {map, current}, m, box1, box2, item1, item2, item) do
    {updated_map, next} = move({map, box1}, m, item1)
    # Can move half of the box?
    if next != box1 do
      # Try to move the other half
      {updated_map, next} = move({updated_map, box2}, m, item2)
      if next != box2 do
        move({updated_map, current}, m, item)
      else
        position
      end
    else
      position
    end
  end

  defp push_box(position = {map, current}, m, box, item, box_item \\ "O") do
    {updated_map, next} = move({map, box}, m, box_item)
    # Moved the box?
    if next != box do
      move({updated_map, current}, m, item)
    else
      position
    end
  end

  defp next(i, j, "^"), do: {i-1, j}
  defp next(i, j, ">"), do: {i, j+1}
  defp next(i, j, "v"), do: {i+1, j}
  defp next(i, j, "<"), do: {i, j-1}

  def starting_position(map), do: Enum.find(map, fn {_, v} -> v == "@" end) |> elem(0)

  def print(map, m, n) do
    (for x <- 0..m-1, y <- 0..n-1, do: Map.get(map, {x, y}))
    |> Enum.chunk_every(n)
    |> Enum.map(&Enum.join/1)
    |> Enum.join("\n")
    |> IO.puts()
  end

  def widen({map, moves}), do: {widen(map), moves}
  def widen(map = %{}) do
    Enum.flat_map(map, fn {p, v} -> widen(p, v) end) |> Enum.into(%{})
  end
  def widen({i, j}, "#"), do: [{{i, 2*j}, "#"}, {{i, 2*j+1}, "#"}]
  def widen({i, j}, "."), do: [{{i, 2*j}, "."}, {{i, 2*j+1}, "."}]
  def widen({i, j}, "O"), do: [{{i, 2*j}, "["}, {{i, 2*j+1}, "]"}]
  def widen({i, j}, "@"), do: [{{i, 2*j}, "@"}, {{i, 2*j+1}, "."}]

  def read(file) do
    [map, moves] = File.read!(file)
    |> String.split(~r{\n\n}, trim: true)
    |> Enum.map(&(String.split(&1, ~r{\n}, trim: true)))

    {parse_map(map), parse_moves(moves)}
  end

  defp parse_moves(moves), do: Enum.flat_map(moves, &String.graphemes/1)

  defp parse_map(lines), do: parse_map(lines, %{}, 0)
  defp parse_map([], map, _), do: map
  defp parse_map([line | lines], map, i) do
    updated_map = parse_map(String.graphemes(line), map, i, 0)
    parse_map(lines, updated_map, i + 1)
  end

  defp parse_map([], map, _, _), do: map
  defp parse_map([c | row], map, i, j), do: parse_map(row, Map.put(map, {i, j}, c), i, j + 1)
end

Warehouse.read("inputs/input15.txt") |> Warehouse.simulate() |> Warehouse.gps_coordinates() |> IO.puts()

# --- Part Two ---

Warehouse.read("inputs/input15.txt") |> Warehouse.widen() |> Warehouse.simulate() |> Warehouse.gps_coordinates() |> IO.puts()
