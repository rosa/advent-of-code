# --- Day 11: Chronal Charge ---

defmodule PowerGrid do
  def build(serial_number), do: build(%{}, grid_keys(300), serial_number)
  def build(grid, [], _serial_number), do: grid
  def build(grid, [cell | keys], serial_number) do
    Map.put(grid, cell, power_level(cell, serial_number))
    |> build(keys, serial_number)
  end

  def largest_3x3_power_square(grid), do: largest_3x3_power_square(grid_keys(298), grid, nil, nil)
  def largest_3x3_power_square([cell | cells], grid, nil, nil), do: largest_3x3_power_square(cells, grid, cell, power_square(cell, grid, 3))
  def largest_3x3_power_square([], _grid, chosen_cell, _largest_power), do: chosen_cell
  def largest_3x3_power_square([cell | cells], grid, chosen_cell, largest_power) do
    power_square = power_square(cell, grid, 3)
    if power_square > largest_power do
      largest_3x3_power_square(cells, grid, cell, power_square)
    else
      largest_3x3_power_square(cells, grid, chosen_cell, largest_power)
    end
  end

  def largest_power_square(grid), do: largest_power_square(Enum.sort(Map.keys(grid)), grid, nil)
  def largest_power_square([cell | cells], grid, nil), do: largest_power_square(cells, grid, largest_power_square(cell, grid))
  def largest_power_square([], grid, result), do: result
  def largest_power_square([cell | cells], grid, result = {_, _, largest_power}) do
    { _, size, power } = largest_power_square(cell, grid)
    IO.inspect(cell)
    if power > largest_power do
      largest_power_square(cells, grid, {cell, size, power})
    else
      largest_power_square(cells, grid, result)
    end
  end
  def largest_power_square(cell = {x, y}, grid) do
    all_power_squares = 1..(300 - max(x, y) + 1)
    |> Enum.reduce(%{ 0 => 0 }, fn size, acc -> Map.put(acc, size, acc[size - 1] + power_square_line(cell, grid, size)) end)

    max_power_square = Enum.max(Map.values(all_power_squares))
    Enum.find(all_power_squares, fn {_, power} -> power == max_power_square end)
    |> Tuple.insert_at(0, cell)
  end

  defp power_square(cell, grid, 1), do: grid[cell]
  defp power_square(cell, grid, size) do
    Enum.reduce(1..size, 0, fn size, acc -> acc + power_square_line(cell, grid, size) end)
  end

  defp power_square_line(cell, grid, 1), do: grid[cell]
  defp power_square_line(cell = {x, y}, grid, size) do
    offsets = 0..size-1
    Enum.reduce(offsets, 0, fn i, acc -> acc + grid[{x+i, y+size-1}] + grid[{x+size-1, y+i}] end) - grid[{x+size-1, y+size-1}]
  end

  # The power level in a given fuel cell can be found through the following process:
  # Find the fuel cell's rack ID, which is its X coordinate plus 10.
  # Begin with a power level of the rack ID times the Y coordinate.
  # Increase the power level by the value of the grid serial number (your puzzle input).
  # Set the power level to itself multiplied by the rack ID.
  # Keep only the hundreds digit of the power level (so 12345 becomes 3; numbers with no hundreds digit become 0).
  # Subtract 5 from the power level.
  defp power_level({x, y}, serial_number) do
    rack_id = x + 10
    power_level = (rack_id * y + serial_number) * rack_id
    if power_level < 100, do: -5, else: rem(div(power_level, 100), 10) - 5
  end

  defp grid_keys(size) do
    for x <- (1..size), y <- (1..size), do: {x, y}
  end
end


# Your puzzle input is 9435
PowerGrid.build(9435) |> PowerGrid.largest_3x3_power_square() |> inspect() |> IO.puts()

# --- Part Two ---
PowerGrid.build(9435) |> PowerGrid.largest_power_square() |> inspect() |> IO.puts()
