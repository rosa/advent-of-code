# --- Day 9: Encoding Error ---

defmodule XMAS do
  def find_first_error({_, []}), do: nil
  def find_first_error({[p|preamble], [n|numbers]}) do
    if valid?([p|preamble], n) do
      find_first_error({preamble ++ [n], numbers})
    else
      n
    end
  end

  def encryption_weakness(_, 0), do: 0
  def encryption_weakness({preamble, numbers}, first_error), do: encryption_weakness(preamble ++ numbers, first_error, [], 0)
  def encryption_weakness(_, first_error, range, first_error), do: Enum.min(range) + Enum.max(range)
  def encryption_weakness([n|numbers], first_error, range, sum) do
    if sum + n <= first_error do
      encryption_weakness(numbers, first_error, range ++ [n], sum + n)
    else
      [drop|rest] = range
      encryption_weakness([n|numbers], first_error, rest, sum - drop)
    end
  end

  def read_numbers(file, preamble_size) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.split(preamble_size)
  end

  defp valid?([], _), do: false
  defp valid?([p|preamble], number), do: (number - p in preamble) || valid?(preamble, number)
end

numbers = XMAS.read_numbers("inputs/input09.txt", 25)
first_error = XMAS.find_first_error(numbers) |> IO.inspect

# --- Part Two ---

XMAS.encryption_weakness(numbers, first_error) |> IO.inspect
