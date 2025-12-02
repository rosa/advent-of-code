# --- Day 1: Secret Entrance ---

defmodule Rotations do
  def zero_dials_count(path), do: lines(path) |> zero_dials_count(50, 0, 0)

  def zero_dials_count([], 0, count, passes), do: {count + 1, passes + 1}
  def zero_dials_count([], _, count, passes), do: {count, passes}
  def zero_dials_count([rot|rotations], 0, count, passes), do: zero_dials_count(rotations, rotate(rot, 0), count + 1, passes + pass(rot, 0) + 1)
  def zero_dials_count([rot|rotations], current, count, passes), do: zero_dials_count(rotations, rotate(rot, current), count, passes + pass(rot, current))

  defp rotate({"L", n}, current), do: Integer.mod(current - n, 100)
  defp rotate({"R", n}, current), do: Integer.mod(current + n, 100)

  defp pass({"L", n}, current), do: Integer.floor_div(n, 100) + pass(current, current - Integer.mod(n, 100))
  defp pass({"R", n}, current), do: Integer.floor_div(n, 100) + pass(current, current + Integer.mod(n, 100))
  defp pass(current, n) when current > 0 and n < 0, do: 1
  defp pass(_, n) when n > 100, do: 1
  defp pass(_, _), do: 0

  defp lines(path) do
    File.read!(path)
    |> String.split(~r{\n}, trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    [_, dir, count] = Regex.run(~r/(L|R)(\d+)/, line)
    {dir, String.to_integer(count)}
  end
end

rotations = Rotations.zero_dials_count("inputs/input01.txt")
rotations |> elem(0) |> IO.puts

# --- Part Two ---
rotations |> elem(1) |> IO.puts
