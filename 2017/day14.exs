# --- Day 14: Disk Defragmentation ---

# Knot hash: 32 hexadecimal digits; each of these digits correspond to 4 bits, for a total of 4 * 32 = 128 bits
# To convert to bits, turn each hexadecimal digit to its equivalent binary value, high-bit first: 
# 0 becomes 0000, 1 becomes 0001, e becomes 1110, f becomes 1111, and so on;

defmodule DiskDefragmenter do
  import KnotHash

  def usage(input) do
    disk(input)
    |> Enum.map(fn(row) -> Enum.count(row, fn(x) -> x == 1 end) end)
    |> Enum.sum
  end

  def regions(input) do
    disk(input)
    |> mark_regions()
    |> count_regions()
  end

  defp count_regions(rows) do
    List.flatten(rows)
    |> Enum.uniq
    |> Enum.count
    |> Kernel.-(1)
  end

  defp mark_regions(rows), do: mark_regions(rows, 0, 0, 2)
  defp mark_regions(marked, 128, _, _), do: marked
  defp mark_regions(marked, i, 128, mark), do: mark_regions(marked, i+1, 0, mark)
  defp mark_regions(marked, i, j, mark) do
    if get(marked, i, j) == 1 do
      put(marked, i, j, mark)
      |> mark_neighbours(i, j, mark, [{i, j}])
    else
      mark_regions(marked, i, j+1, mark)
    end
  end

  defp mark_neighbours(marked, r, s, mark, []), do: mark_regions(marked, r, s+1, mark+1)
  defp mark_neighbours(marked, r, s, mark, [{i, j}|queue]) do
    neighbours = neighbours(i, j) |> Enum.filter(fn({x, y}) -> get(marked, x, y) == 1 end)

    multiput(marked, neighbours, mark)
    |> mark_neighbours(r, s, mark, neighbours ++ queue)
  end

  defp disk(input) do
    for n <- 0..127, do: row("#{input}-#{n}")
  end

  defp row(string) do
    knot_hash(string)
    |> String.graphemes
    |> Enum.map(&hex_to_bin/1)
    |> Enum.join()
    |> String.graphemes
    |> Enum.map(&String.to_integer/1)
  end

  defp hex_to_bin(digit) do
    String.to_integer(digit, 16)
    |> Integer.to_string(2)
    |> pad
  end

  defp pad(digits) do
    String.duplicate("0", (4 - String.length(digits))) <> digits
  end

  defp neighbours(i, j) do
    [{i, j-1}, {i, j+1}, {i-1, j}, {i+1, j}]
    |> Enum.filter(fn({x, y}) -> x >= 0 && y >= 0 && x < 128 && y < 128 end)
  end

  defp get(array, i, j), do: Enum.at(array, i) |> Enum.at(j)
  defp put(array, i, j, value) do
    row = Enum.at(array, i)
    List.replace_at(array, i, List.replace_at(row, j, value))
  end
  defp multiput(array, [], _), do: array
  defp multiput(array, [{i, j}|positions], value) do
    put(array, i, j, value)
    |> multiput(positions, value)
  end
end

input = "hxtvlmkl"
DiskDefragmenter.usage(input) |> IO.puts

# --- Part Two ---

DiskDefragmenter.regions(input) |> IO.puts
