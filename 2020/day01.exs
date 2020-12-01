# --- Day 1: Report Repair ---

defmodule ExpenseReport do
  def two_entries_summing_2020(file) do
    file
    |> lines()
    |> find_two_entries(2020)
  end

  def three_entries_summing_2020(file) do
    file
    |> lines()
    |> find_three_entries(2020)
  end

  defp find_two_entries([entry | rest], sum) do
    if sum - entry in rest do
      [entry, sum - entry]
    else
      find_two_entries(rest, sum)
    end
  end
  defp find_two_entries([], _), do: nil

  defp find_three_entries([entry | rest], sum) do
    two_entries = find_two_entries(rest, sum - entry)
    if two_entries do
      [entry | two_entries]
    else
      find_three_entries(rest, sum)
    end
  end

  defp lines(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end

ExpenseReport.two_entries_summing_2020("./inputs/input01.txt") |> Enum.reduce(&*/2) |> IO.puts

# --- Part Two ---

ExpenseReport.three_entries_summing_2020("./inputs/input01.txt") |> Enum.reduce(&*/2) |> IO.puts