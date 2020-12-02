# --- Day 2: Password Philosophy ---

defmodule Toboggan do
  def number_of_valid_passwords_with_first_interpretation(file) do
    file
    |> lines()
    |> Enum.map(&to_password_and_policy/1)
    |> Enum.count(&valid_with_first_interpretation?/1)
  end

  def number_of_valid_passwords_with_second_interpretation(file) do
    file
    |> lines()
    |> Enum.map(&to_password_and_policy/1)
    |> Enum.count(&valid_with_second_interpretation?/1)
  end


  defp valid_with_first_interpretation?({from, to, letter, password}) do
    occurrences = Enum.count(String.graphemes(password), fn x -> x == letter end)
    occurrences >= from && occurrences <= to
  end

  defp valid_with_second_interpretation?({first, second, letter, password}) do
    String.at(password, first - 1) == letter && String.at(password, second - 1) != letter ||
      String.at(password, first - 1) != letter && String.at(password, second - 1) == letter
  end

  defp to_password_and_policy(line) do
    [_, from, to, letter, password] = Regex.run(~r{(\d+)-(\d+) ([a-z]): ([a-z]+)}, line)
    {String.to_integer(from), String.to_integer(to), letter, password}
  end

  defp lines(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
  end
end

Toboggan.number_of_valid_passwords_with_first_interpretation("./inputs/input02.txt") |> IO.puts

# --- Part Two ---

Toboggan.number_of_valid_passwords_with_second_interpretation("./inputs/input02.txt") |> IO.puts
