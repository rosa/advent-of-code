# --- Day 4: High-Entropy Passphrases ---

# To ensure security, a valid passphrase must contain no duplicate words.
# aa bb cc dd ee is valid.
# aa bb cc dd aa is not valid - the word aa appears more than once.
# aa bb cc dd aaa is valid - aa and aaa count as different words.

defmodule Passphrase do
  def how_many?(file, function) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
    |> Enum.count(function)
  end

  def valid_simple?(passphrase) do
    list = words(passphrase)
    total_words(list) == total_unique_words(list)
  end

  def valid_anagrams?(passphrase) do
    list = words(passphrase) |> Enum.map(&sort_string/1)
    total_words(list) == total_unique_words(list)
  end

  defp words(passphrase), do: String.split(passphrase, ~r{\s}, trim: true)
  defp total_words(passphrase), do: Enum.count(passphrase)
  defp total_unique_words(passphrase), do: Enum.uniq(passphrase) |> Enum.count
  defp sort_string(string), do: String.graphemes(string) |> Enum.sort |> Enum.join
end

Passphrase.how_many?("./inputs/input04.txt", &Passphrase.valid_simple?/1) |> IO.puts

# --- Part Two ---

Passphrase.how_many?("./inputs/input04.txt", &Passphrase.valid_anagrams?/1) |> IO.puts
