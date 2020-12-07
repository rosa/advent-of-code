# --- Day 6: Custom Customs ---

defmodule Customs do
  def questions_anyone_answered_yes(file) do
    read_answers(file)
    |> Enum.map(&String.replace(&1, ~r{\s}, ""))
    |> strings_to_sets()
    |> combine_and_sum()
  end

  def questions_everyone_answered_yes(file) do
    read_answers(file)
    |> Enum.map(&intersections/1)
    |> combine_and_sum()
  end

  defp combine_and_sum(anwers) do
    Enum.map(anwers, &MapSet.size/1)
    |> Enum.reduce(&(&1 + &2))
  end

  defp intersections(answers) do
    String.split(answers, ~r{\n}, trim: true)
    |> strings_to_sets()
    |> Enum.reduce(&(MapSet.intersection(&1, &2)))
  end

  defp strings_to_sets(strings) do
    Enum.map(strings, &String.graphemes/1)
    |> Enum.map(&MapSet.new/1)
  end

  defp read_answers(file) do
    File.read!(file)
    |> String.split(~r{\n\n}, trim: true)
  end
end

Customs.questions_anyone_answered_yes("inputs/input06.txt") |> IO.puts

# --- Part Two ---

Customs.questions_everyone_answered_yes("inputs/input06.txt") |> IO.puts
