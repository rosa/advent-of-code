# --- Day 4: Ceres Search ---

defmodule XmasSearch do
  @target [ "X", "M", "A", "S" ]

  def find_xmas(puzzle) do
    rows = Enum.to_list(1..length(puzzle) - 2)
    columns = Enum.to_list(1..length(hd(puzzle)) - 2)

    Enum.map(rows, fn i -> Enum.map(columns, fn j -> check_xmas(puzzle, i, j) end) |> Enum.sum end)
    |> Enum.sum
  end

  defp check_xmas(puzzle, i, j) do
    case get(puzzle, i, j) do
      "A" -> check_ms(puzzle, i, j)
      _ -> 0
    end
  end

  defp check_ms(puzzle, i, j) do
    v1 = get(puzzle, i - 1, j - 1)
    v2 = get(puzzle, i + 1, j + 1)
    v3 = get(puzzle, i - 1, j + 1)
    v4 = get(puzzle, i + 1, j - 1)

    if Enum.sort([v1, v2]) == ["M", "S"] and Enum.sort([v3, v4]) == ["M", "S"] do
      1
    else
      0
    end
  end

  def solve(puzzle) do
    rows = Enum.to_list(0..length(puzzle) - 1)
    columns = Enum.to_list(0..length(hd(puzzle)) - 1)

    Enum.map(rows, fn row ->
      compute(puzzle, {1, 0}, {row, 0}, @target) +
      compute(puzzle, {1, 1}, {row, 0}, @target) +
      compute(puzzle, {-1, 1}, {row, length(hd(puzzle)) - 1}, @target)
    end) ++
    Enum.map(columns, fn col ->
      compute(puzzle, {0, 1}, {0, col}, @target) end) ++
    Enum.map(tl(columns), fn col ->
      compute(puzzle, {1, 1}, {0, col}, @target)
    end) ++
    Enum.map(tl(Enum.reverse(columns)), fn col ->
      compute(puzzle, {-1, 1}, {0, col}, @target)
    end)
    |> Enum.sum
  end

  def compute(puzzle, increments, start, target) do
    check(puzzle, increments, start, target, target, 0) +
    check(puzzle, increments, start, Enum.reverse(target), Enum.reverse(target), 0)
  end

  def check(puzzle, {x, y}, {i, j}, [], target, total) do
    check(puzzle, {x, y}, {i, j}, target, target, total + 1)
  end

  def check(puzzle, _, {i, j}, _, _, total) when j >= length(hd(puzzle)) or i >= length(puzzle) or i < 0 or j < 0, do: total

  def check(puzzle, {x, y}, {i, j}, [n|found], [m|target], total) do
    case get(puzzle, i, j) do
      ^n -> check(puzzle, {x, y}, {i + y, j + x}, found, [m|target], total)
      ^m -> check(puzzle, {x, y}, {i + y, j + x}, target, [m|target], total)
      _ -> check(puzzle, {x, y}, {i + y, j + x}, [m|target], [m|target], total)
    end
  end

  defp get(puzzle, i, j), do: Enum.at(puzzle, i) |> Enum.at(j)

  def read(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
    |> Enum.map(&String.graphemes/1)
  end
end

XmasSearch.read("inputs/input04.txt") |> XmasSearch.solve |> IO.puts

# --- Part Two ---

XmasSearch.read("inputs/input04.txt") |> XmasSearch.find_xmas |> IO.puts
