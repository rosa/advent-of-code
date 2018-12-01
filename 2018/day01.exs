# --- Day 1: Chronal Calibration ---

# +1, +1, +1 results in  3
# +1, +1, -2 results in  0
# -1, -2, -3 results in -6
defmodule Calibrator do
  def final_frequency(file) do
    file
    |> lines()
    |> changes()
    |> Enum.reduce(&+/2)
  end

  def frequency_reached_twice(file) do
    file
    |> lines()
    |> changes()
    |> frequency_reached_twice(0, [0])
  end

  def frequency_reached_twice(changes, index, seen) when index >= length(changes), do: frequency_reached_twice(changes, 0, seen)

  def frequency_reached_twice(changes, index, seen = [last | rest]) do
    if last in rest do
      last
    else
      frequency_reached_twice(changes, index + 1, [last + Enum.at(changes, index) | seen])
    end
  end

  defp changes(lines) do
    lines |>
    Enum.map(&String.to_integer/1)
  end

  defp lines(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
  end
end

Calibrator.final_frequency("./inputs/input01.txt") |> IO.puts

# --- Part Two ---

Calibrator.frequency_reached_twice("./inputs/input01.txt") |> IO.puts