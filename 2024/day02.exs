# --- Day 2: Red-Nosed Reports ---

defmodule Reports do
  def count_safes(file), do: lines(file) |> Enum.count(&safe?/1)
  def count_safes_with_dampener(file), do: lines(file) |> Enum.count(&safe_with_dampener?/1)

  defp safe_with_dampener?([a|l]), do: safe?([a|l]) or safe?(l) or safe_with_dampener?([a], l)
  defp safe_with_dampener?(l, [a|r]), do: safe?(l ++ r) or safe_with_dampener?(l ++ [a], r)
  defp safe_with_dampener?(l, []), do: safe?(l)

  defp safe?([a, b|l]), do: safe?([b|l], a - b)
  defp safe?(_, n) when n == 0 or abs(n) > 3, do: false
  defp safe?([_], _), do: true
  defp safe?([a, b|_], n) when (a - b < 0 and n > 0) or (a - b > 0 and n < 0), do: false
  defp safe?([a, b|l], _), do: safe?([b|l], a - b)

  defp lines(path) do
    File.read!(path)
    |> String.split(~r{\n}, trim: true)
    |> Enum.map(&parse_report/1)
  end

  defp parse_report(line) do
    String.split(line, ~r{\s}, trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end

Reports.count_safes("./inputs/input02.txt") |> IO.puts

# --- Part Two ---
Reports.count_safes_with_dampener("./inputs/input02.txt") |> IO.puts

