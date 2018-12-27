# --- Day 23: Experimental Emergency Teleportation ---

defmodule Nanobots do
  def read_and_parse_bots(file) do
    read(file)
    |> parse()
  end

  def largest_number_of_nanobots_coordinate(bots), do: largest_number_of_nanobots_coordinate(bots, [initial_box(bots)])
  def largest_number_of_nanobots_coordinate(bots, boxes) do
    box = %{size: size, distance: distance} = best_box(boxes)
    IO.inspect(size)
    if size == 1 do
      box
    else
      largest_number_of_nanobots_coordinate(bots, List.delete(boxes, box) ++ divide_box(box, bots))
    end
  end

  def in_range(bots), do: in_range(strongest(bots), Enum.map(bots, fn %{pos: pos} -> pos end))
  def in_range(from, coords), do: Enum.filter(coords, &in_range?(from, &1))


  defp best_box(boxes) do
    Enum.sort(boxes, fn(box1, box2) -> gt(box1, box2) end) |> hd()
  end

  defp gt(%{size: size1, range_count: count1, distance: dist1}, %{size: size2, range_count: count2, distance: dist2}) do
    count1 > count2 || (count1 == count2 && size1 > size2) || (size1 == size2 && dist1 < dist2)
  end

  # Find a box (octahedron?) in the Manhattan distance space that contains all bots with their ranges: all
  # coordinates are the closest power of 2 larger than the largest coordinate in abs + radius
  defp initial_box(bots) do
    limit = bots
    |> Enum.map(&max_range/1)
    |> Enum.max()
    |> closest_2_pow()
    coords = [-limit, -limit, -limit, limit, limit, limit]
    %{coords: coords,
      size: 2*limit,
      range_count: count_in_range_of_bots(coords, bots),
      distance: distance([0, 0, 0], [-limit, -limit, -limit])}
  end

  # Divide each octahedron in 8
  defp divide_box(box = %{size: size}, bots) do
    new_size = div(size, 2)
    [{0, 0, 0}, {0, 0, 1}, {0, 1, 0}, {0, 1, 1},
     {1, 0, 0}, {1, 0, 1}, {1, 1, 0}, {1, 1, 1}]
    |> Enum.map(fn mul -> new_box(box, new_size, mul, bots) end)
  end

  defp new_box(%{coords: [x, y, z | _]}, size, {mx, my, mz}, bots) do
    coords = [x + size*mx, y + size*my, z + size*mz, x + size*mx + size, y + size*my + size, z + size*mz + size]
    %{coords: coords,
      size: size,
      range_count: count_in_range_of_bots(coords, bots),
      distance: distance([0, 0, 0], [x + size*mx, y + size*my, z + size*mz])}
  end

  defp count_in_range_of_bots(coords, bots) do
    Enum.count(bots, fn bot -> in_range?(bot, coords) end)
  end

  defp max_range(%{pos: pos, r: radius}), do: (Enum.map(pos, &abs/1) |> Enum.max()) + radius

  defp strongest(bots), do: Enum.max_by(bots, fn %{r: radius} -> radius end)

  # in_range?(bot, coordinate)
  defp in_range?(%{pos: pos, r: radius}, [x, y, z]), do: distance(pos, [x, y, z]) <= radius
  # in_range?(bot, box)
  defp in_range?(%{pos: pos, r: radius}, [x1, y1, z1, x2, y2, z2]) do
    d = distance(pos, [x1, y1, z1]) + distance(pos, [x2-1, y2-1, z2-1]) - distance([x1, y1, z1], [x2-1, y2-1, z2-1])
    div(d, 2) <= radius
  end

  defp distance([x, y, z], [r, t, s]), do: abs(r-x) + abs(y-t) + abs(s-z)

  defp parse(lines) when is_list(lines), do: Enum.map(lines, &parse/1)
  # pos=<89663068,44368890,80128768>, r=95149488
  defp parse(line) do
    %{"pos" => pos, "r" => r} = Regex.named_captures(~r/pos=<(?<pos>[-\d,]+)>, r=(?<r>\d+)/, line)
    %{pos: Enum.map(String.split(pos, ","), &String.to_integer/1), r: String.to_integer(r)}
  end

  defp read(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
  end

  defp closest_2_pow(m), do: closest_2_pow(m, 2)
  defp closest_2_pow(m, n) when n > m, do: n
  defp closest_2_pow(m, n), do: closest_2_pow(m, n * 2)
end

Nanobots.read_and_parse_bots("./inputs/input23.txt")
|> Nanobots.in_range()
|> Enum.count()
|> IO.puts()

# --- Part Two ---
Nanobots.read_and_parse_bots("./inputs/input23.txt")
|> Nanobots.largest_number_of_nanobots_coordinate()
|> IO.inspect()

