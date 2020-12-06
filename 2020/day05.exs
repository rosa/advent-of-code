# --- Day 5: Binary Boarding ---

defmodule BoardingPass do
  def missing(ids) do
    Enum.find(ids, fn x -> (x + 2 in ids) && !(x + 1 in ids) end) + 1
  end

  def all_ids() do
    Enum.map((0..127), &(8 * &1))
    |> Enum.flat_map(fn x -> Enum.map((0..7), &(&1 + x)) end)
  end

  def ids(file), do: read_boarding_passes(file) |> Enum.map(&id/1)

  defp id(pass) do
    String.replace(pass, "F", "0")
    |> String.replace("B", "1")
    |> String.replace("L", "0")
    |> String.replace("R", "1")
    |> String.to_integer(2)
  end

  defp read_boarding_passes(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
  end
end

BoardingPass.ids("inputs/input05.txt") |> Enum.max |> IO.puts

# --- Part Two ---
BoardingPass.ids("inputs/input05.txt") |> BoardingPass.missing |> IO.inspect
