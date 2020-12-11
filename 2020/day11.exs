# --- Day 11: Seating System ---

defmodule SeatingSystem do
  def occupied_seats_after_simulation(layout, criteria) do
    simulate(layout, criteria)
    |> turn_into_list()
    |> Enum.count(&(&1 == "#"))
  end

  def simulate(layout, criteria) do
    next_state = next_state(layout, criteria)
    if layout == next_state, do: next_state, else: simulate(next_state, criteria)
  end

  def next_state(layout, criteria) do
    Enum.map(0..Enum.count(layout) - 1, fn i -> {i, next_state(layout, criteria, i)} end)
    |> Enum.into(Map.new)
  end

  def next_state(layout, criteria, i) do
    Enum.map(0..Enum.count(layout[i]) - 1, fn j -> {j, next_state(layout, criteria, i, j)} end)
    |> Enum.into(Map.new)
  end

  def next_state(layout, criteria, i, j) do
    neighbours = apply(SeatingSystem, criteria, [layout, i, j])
    case layout[i][j] do
      "L" -> if Enum.all?(neighbours, &(&1 != "#")), do: "#", else: "L"
      "#" -> if Enum.count(neighbours, &(&1 == "#")) >= threshold(criteria), do: "L", else: "#"
      "." -> "."
    end
  end

  defp threshold(:adjacents), do: 4
  defp threshold(:visible), do: 5

  def adjacents(layout, i, j) do
    (for x <- -1..1, y <- -1..1, do: {x, y})
    |> Enum.reject(&(&1 == {0, 0}))
    |> Enum.map(fn {x, y} -> layout[i+x][j+y] end)
    |> Enum.reject(&is_nil/1)
  end

  def visible(layout, i, j) do
    (for x <- -1..1, y <- -1..1, do: {x, y})
    |> Enum.reject(&(&1 == {0, 0}))
    |> Enum.map(fn {x, y} -> visible(layout, i, j, x, y) end)
    |> Enum.reject(&is_nil/1)
  end

  def visible(layout, i, j, x, y) do
    if layout[i+x][j+y] != ".", do: layout[i+x][j+y], else: visible(layout, i+x, j+y, x, y)
  end

  def read_layout(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
    |> Enum.map(&String.graphemes/1)
    |> turn_into_map()
  end

  defp turn_into_map(layout) do
    if is_list(List.first(layout)) do
      Enum.map(layout, fn row -> turn_into_map(row) end)
      |> turn_into_map()
    else
      Enum.zip(0..Enum.count(layout) - 1, layout)
      |> Enum.into(Map.new)
    end
  end

  defp turn_into_list(layout), do: Map.values(layout) |> Enum.flat_map(&Map.values/1)
end

SeatingSystem.read_layout("inputs/input11.txt") |> SeatingSystem.occupied_seats_after_simulation(:adjacents) |> IO.inspect

# --- Part Two ---

SeatingSystem.read_layout("inputs/input11.txt") |> SeatingSystem.occupied_seats_after_simulation(:visible) |> IO.inspect

