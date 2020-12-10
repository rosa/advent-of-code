# --- Day 10: Adapter Array ---

defmodule JoltageAdapters do
  def arrangements(ratings) do
    compute_differences(ratings)
    |> count_one_sequences()
    |> compute_arrangements()
  end

  def difference_product(ratings) do
    differences = compute_differences(ratings)
    Enum.count(differences, &(&1 == 1)) * Enum.count(differences, &(&1 == 3))
  end

  defp compute_differences(ratings), do: compute_differences([0] ++ Enum.sort(ratings) ++ [device_rating(ratings)], [])
  defp compute_differences([_], differences), do: differences
  defp compute_differences([r1, r2|ratings], differences), do: compute_differences([r2|ratings], differences ++ [r2 - r1])

  defp count_one_sequences(differences), do: count_one_sequences(differences, [], 0)
  defp count_one_sequences([], sequences, current), do: sequences ++ [current] |> Enum.filter(&(&1 > 0))
  defp count_one_sequences([1|differences], sequences, current), do: count_one_sequences(differences, sequences, current + 1)
  defp count_one_sequences([3|differences], sequences, current), do: count_one_sequences(differences, sequences ++ [current], 0)

  defp compute_arrangements(one_sequences), do: compute_arrangements(one_sequences, 1)
  defp compute_arrangements([], arrangements), do: arrangements
  defp compute_arrangements([ones|one_sequences], arrangements) do
    case ones do
      1 -> compute_arrangements(one_sequences, arrangements)
      2 -> compute_arrangements(one_sequences, arrangements * 2)
      3 -> compute_arrangements(one_sequences, arrangements * 4)
      4 -> compute_arrangements(one_sequences, arrangements * 7)
    end
  end

  defp device_rating(adapter_ratings), do: Enum.max(adapter_ratings) + 3

  def read_ratings(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end

JoltageAdapters.read_ratings("inputs/input10.txt") |> JoltageAdapters.difference_product() |> IO.puts

# --- Part Two ---

JoltageAdapters.read_ratings("inputs/input10.txt") |> JoltageAdapters.arrangements() |> IO.inspect
