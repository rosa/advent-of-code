# --- Day 3: No Matter How You Slice It ---

# Each claim's rectangle has an ID and is defined as follows:
# - The number of inches between the left edge of the fabric and the left edge of the rectangle.
# - The number of inches between the top edge of the fabric and the top edge of the rectangle.
# - The width of the rectangle in inches.
# - The height of the rectangle in inches.
# Example: #123 @ 3,2: 5x4 
defmodule Fabric do
  def number_of_inches_overlapping(file) do
    rectangles = file
    |> lines()
    |> rectangles()

    fabric()
    |> Enum.map(fn x -> async_overlapping(rectangles, x) end)

    fabric()
    |> Enum.count(fn x -> overlap?(x) end)
  end

  def intact_claim(file) do
    rectangles = file
    |> lines()
    |> rectangles()

    fabric()
    |> Enum.map(fn x -> async_overlapping(rectangles, x) end)

    fabric()
    |> Enum.map(&claims/1)
    |> Enum.filter(fn x -> Enum.count(x) == 1 end)
    |> List.flatten()
    |> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
    |> Enum.find(fn {id, count} -> intact?(id, count, rectangles) end)
  end

  def intact?(id, count, rectangles) do
    [^id, _x, _y, w, h] = Enum.find(rectangles, fn [x|_] -> x == id end)
    w*h == count
  end

  defp overlap?(coord) do
    receive do
      { ^coord, overlapping } -> Enum.count(overlapping) > 1
    end
  end

  defp claims(coord) do
    receive do
      { ^coord, overlapping } -> overlapping
    end
  end

  defp async_overlapping(rectangles, coord) do
    caller = self()
    spawn(fn -> send(caller, { coord, overlapping(rectangles, coord, [])}) end)
  end

  defp overlapping([], _coord, overlapping), do: overlapping
  defp overlapping([ [id | coords] | rectangles], coord, overlapping) do
    if included?(coord, coords) do
      overlapping(rectangles, coord, [id | overlapping])
    else
      overlapping(rectangles, coord, overlapping)
    end
  end

  defp included?(coord, [x, y, w, h]) do
    { xc, yc } = normalize(coord)
    Enum.member?(x..x+w-1, xc) && Enum.member?(y..y+h-1, yc)
  end

  defp normalize(coord), do: { rem(coord, 1000), div(coord, 1000) }

  defp fabric(), do: 0..1000*1000-1

  defp rectangles(lines), do: Enum.map(lines, &rectangle/1)

  # Example: #123 @ 3,2: 5x4
  defp rectangle(line) do
    [_ | rectangle] = Regex.run(~r{#(\d+) @ (\d+),(\d+): (\d+)x(\d+)}, line)
    Enum.map(rectangle, &String.to_integer/1)
  end

  defp lines(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
  end
end

Fabric.number_of_inches_overlapping("./inputs/input03.txt") |> IO.puts

# --- Part Two ---

Fabric.intact_claim("./inputs/input03.txt") |> IO.inspect()
