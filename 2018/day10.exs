# --- Day 10: The Stars Align ---

defmodule Stars do
  def read_and_parse(file) do
    read(file)
    |> parse()
  end

  def align_and_print(stars) do
    align(stars)
    |> elem(0)
    |> normalize()
    |> print()
  end

  def seconds_until_aligned(stars) do
    align(stars)
    |> elem(1)
  end

  defp align(stars), do: align(stars, 0)
  defp align(stars, seconds) do
    aligned_x = count_aligned(stars)
    if aligned_x >= 8 && line?(stars, aligned_x) do
      {stars, seconds}
    else
      move(stars) |> align(seconds + 1)
    end
  end

  defp move(%{"position" => [x, y], "velocity" => [vx, vy]}), do: %{"position" => [x + vx, y + vy], "velocity" => [vx, vy]}
  defp move(stars), do: Enum.map(stars, &move/1)

  defp count_aligned(stars) do
    counts = coords(stars, 0)
    |> Enum.reduce(%{}, fn k, acc -> Map.update(acc, k, 1, &(&1 + 1)) end)
    |> Map.values()

    Enum.max(counts)
  end

  defp line?(stars, aligned) do
    counts = coords(stars, 0)
    |> Enum.reduce(%{}, fn k, acc -> Map.update(acc, k, 1, &(&1 + 1)) end)

    {candidate, _} = Enum.find(counts, fn {_, v} -> v == aligned end)
    Enum.filter(stars, fn star -> Enum.at(star["position"], 0) == candidate end)
    |> coords(1)
    |> Enum.sort()
    |> line?()
  end

  defp line?([]), do: true
  defp line?([_]), do: true
  defp line?([u, v | line]), do: v - u <= 1 && line?(line)

  defp read(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
  end

  defp parse(lines) when is_list(lines), do: Enum.map(lines, &parse/1)
  # position=< 10775, -31651> velocity=<-1,  3>
  defp parse(line) do
    parsed = Regex.named_captures(~r/position=<(?<position>[, \-0-9]+)> velocity=<(?<velocity>[, \-0-9]+)>/, line)
    to_integer_pair = fn s -> String.split(s, ",") |> Enum.map(&String.trim/1) |> Enum.map(&String.to_integer/1) end

    Enum.map(parsed, fn {k, v} -> {k, to_integer_pair.(v)} end)
    |> Enum.reduce(%{}, fn {k, v}, acc -> Map.put(acc, k, v) end)
  end

  def normalize(stars) do
    { min_x, min_y } = { Enum.min(coords(stars, 0)), Enum.min(coords(stars, 1)) }
    normalize(stars, min_x, min_y)
  end
  def normalize(stars, min_x, min_y) do
    Enum.map(stars, fn star -> { Enum.at(star["position"], 0) - min_x, Enum.at(star["position"], 1) - min_y } end)
  end

  def print(coordinates) do
    [n, m] = bounds(coordinates)
    List.duplicate(List.duplicate(".", n), m)
    |> place(coordinates)
    |> Enum.each(fn row -> IO.puts(Enum.join(row, "")) end)
  end

  def bounds(coordinates) do
    [Enum.map(coordinates, fn {x, _} -> x end), Enum.map(coordinates, fn {_, y} -> y end)]
    |> Enum.map(&(Enum.max(&1) + 1))
  end

  def place(table, []), do: table
  def place(table, [{x, y} | coordinates]) do
    row = Enum.at(table, y)
    List.replace_at(table, y, List.replace_at(row, x, "#"))
    |> place(coordinates)
  end

  def coords(stars, coord), do: Enum.map(stars, fn star -> Enum.at(star["position"], coord) end)
end


# What message will eventually appear in the sky?
Stars.read_and_parse("./inputs/input10.txt") |> Stars.align_and_print()
######.....###..#....#..#....#...####....####...#....#..#....#
#...........#...#....#..##...#..#....#..#....#..##...#..#....#
#...........#....#..#...##...#..#.......#.......##...#...#..#.
#...........#....#..#...#.#..#..#.......#.......#.#..#...#..#.
#####.......#.....##....#.#..#..#.......#.......#.#..#....##..
#...........#.....##....#..#.#..#.......#.......#..#.#....##..
#...........#....#..#...#..#.#..#.......#.......#..#.#...#..#.
#.......#...#....#..#...#...##..#.......#.......#...##...#..#.
#.......#...#...#....#..#...##..#....#..#....#..#...##..#....#
######...###....#....#..#....#...####....####...#....#..#....#

# --- Part Two ---
Stars.read_and_parse("./inputs/input10.txt") |> Stars.seconds_until_aligned() |> IO.puts()
