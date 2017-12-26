# --- Day 5: A Maze of Twisty Trampolines, All Alike ---

defmodule Jumps do
  def number_of_steps(filename, next_function) do
    steps({offsets(filename), 0}, 0, next_function)
  end

  def next_part_1(offsets, i) do 
    offset = Enum.at(offsets, i)
    {List.replace_at(offsets, i, offset + 1), i + offset}
  end

  def next_part_2(offsets, i) do
    offset = Enum.at(offsets, i)
    mod = if(offset >= 3, do: offset - 1, else: offset + 1)
    {List.replace_at(offsets, i, mod), i + offset}
  end

  defp steps({_, i}, n, _) when i < 0, do: n
  defp steps({offsets, i}, n, _) when i >= length(offsets), do: n
  defp steps({offsets, i}, n, next_function) do
    steps(next_function.(offsets, i), n+1, next_function)
  end

  defp offsets(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end

Jumps.number_of_steps("./inputs/input05.txt", &Jumps.next_part_1/2) |> IO.puts

# --- Part Two ---

Jumps.number_of_steps("./inputs/input05.txt", &Jumps.next_part_2/2) |> IO.puts
