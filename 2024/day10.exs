# --- Day 10: Hoof It ---

defmodule HikingGuide do
  def trailheads_score(map) do
    trailheads(map)
    |> Enum.map(fn trailhead -> find_all_nines(map, trailhead) end)
    |> Enum.map(&Enum.uniq/1)
    |> Enum.map(&length/1)
    |> Enum.sum
  end

  def trailheads_rating(map) do
    trailheads(map)
    |> Enum.map(fn trailhead -> find_all_nines(map, trailhead) end)
    |> Enum.map(&length/1)
    |> Enum.sum
  end

  def find_all_nines(map, trailhead), do: find_all_nines(map, [trailhead], [])
  def find_all_nines(_, [], nines), do: nines
  def find_all_nines(map, [x|steps], nines) do
    v = Map.get(map, x)
    next = find_next_steps(map, x, v)

    if v == 8 do
      find_all_nines(map, steps, nines ++ next)
    else
      find_all_nines(map, next ++ steps, nines)
    end
  end

  def find_next_steps(map, {i, j}, v) do
    # Up, right, down, left
    [{i-1, j}, {i, j+1}, {i+1, j}, {i, j-1}]
    |> Enum.filter(fn x -> Map.get(map, x) == v + 1 end)
  end

  def trailheads(map), do: Map.keys(map) |> Enum.filter(fn x -> Map.get(map, x) == 0 end)

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
  defp parse_map(["." | row], map, i, j), do: parse_map(row, map, i, j+1)
  defp parse_map([cell | row], map, i, j) do
    parse_map(row, Map.put(map, {i, j}, String.to_integer(cell)), i, j + 1)
  end
end

HikingGuide.read_map("inputs/input10.txt") |> HikingGuide.trailheads_score() |> IO.puts

# --- Part Two ---

HikingGuide.read_map("inputs/input10.txt") |> HikingGuide.trailheads_rating() |> IO.puts
