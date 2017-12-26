# --- Day 16: Permutation Promenade ---

# Spin, written sX, makes X programs move from the end to the front, but maintain their order otherwise.
# (For example, s3 on abcde produces cdeab).
# Exchange, written xA/B, makes the programs at positions A and B swap places.
# Partner, written pA/B, makes the programs named A and B swap places.

defmodule Dance do
  import String

  def final(file) do
    moves(file)
    |> dance()
  end

  def whole_dance(file) do
    {start, count} = first_repetition(moves(file))
    whole_dance(moves(file), start + rem(1_000_000_000, count), dancers())
  end
  def whole_dance(_, 0, dancers), do: dancers
  def whole_dance(moves, count, dancers) do
    whole_dance(moves, count - 1, dance(moves, dancers))
  end

  defp first_repetition(moves), do: first_repetition(moves, dancers(), 0, %{})
  defp first_repetition(moves, dancers, count, positions) do
    if Map.has_key?(positions, dancers) do
      {positions[dancers], count - positions[dancers]}
    else
      first_repetition(moves, dance(moves, dancers), count + 1, Map.put(positions, dancers, count))
    end
  end

  defp dance(moves), do: dance(moves, dancers())

  defp dance([], dancers), do: dancers
  defp dance([move|moves], dancers) do
    dance(moves, perform(move, dancers))
  end

  defp perform(move, dancers) do
    cond do
      String.match?(move, ~r/s\d+/) -> spin(clear(move), dancers)
      String.match?(move, ~r/x\d+\/\d+/) -> exchange(clear(move), dancers)
      String.match?(move, ~r/p\w+\/\w+/) -> partner(clear(move), dancers)
      true -> dancers
    end
  end

  defp spin(move, dancers) do
    Enum.take(dancers, -to_integer(move)) ++ Enum.take(dancers, Kernel.length(dancers) - to_integer(move))
  end

  defp exchange(move, dancers) do
    [i, j] = split(move, "/", trim: true) |> Enum.map(&to_integer/1)
    [a, b] = [Enum.at(dancers, i), Enum.at(dancers, j)]
    List.replace_at(dancers, i, b)
    |> List.replace_at(j, a)
  end

  defp partner(move, dancers) do
    [a, b] = split(move, "/", trim: true)
    [i, j] = [Enum.find_index(dancers, fn(x) -> x == a end), Enum.find_index(dancers, fn(x) -> x == b end)]
    exchange("#{i}/#{j}", dancers)
  end

  defp clear(move), do: String.slice(move, 1, String.length(move))

  defp moves(file) do
    File.read!(file)
    |> split(",", trim: true)
    |> Enum.map(&String.trim/1)
  end

  # There are sixteen programs in total, named a through p
  defp dancers(), do: ?a..?p |> Enum.map(fn(x) -> List.to_string([x]) end)
end


Dance.final("./inputs/input16.txt") |> IO.puts

# --- Part Two ---
Dance.whole_dance("./inputs/input16.txt") |> IO.puts

