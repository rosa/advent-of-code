# --- Day 9: Disk Fragmenter ---

defmodule DiskFragmenter do
  def compact(disk) do
    ranges = build_ranges(disk)
    files = Enum.take_every(disk, 2)

    compact(ranges, Enum.reverse(Enum.with_index(files)), Enum.sum(files))
    |> checksum()
  end

  def defragment(disk) when is_list(disk) do
    ranges = build_ranges(disk)
    defragment({ranges, length(ranges) - 2, trunc(length(ranges) / 2)})
    |> checksum()
  end

  def defragment({ranges, 0, _}), do: ranges
  def defragment({ranges, _, 0}), do: ranges
  def defragment({ranges, index, id}), do: move_file(Enum.at(ranges, index), ranges, index, id) |> defragment()

  def move_file({nil, _, _}, ranges, index, id), do: {ranges, index - 1, id}
  def move_file({id, _, _}, ranges, index, previous) when id >= previous, do: {ranges, index - 1, previous}
  def move_file({id, i, j}, ranges, index, _) do
    pos = Enum.slice(ranges, 0..index-1) |> Enum.find_index(fn {f, r, s} -> is_nil(f) and j - i <= s - r end)

    if is_nil(pos) do
      {ranges, index - 1, id}
    else
      {nil, r, s} = Enum.at(ranges, pos)

      updated_ranges = Enum.slice(ranges, 0..pos-1) ++ [{id, r, r + j - i}] ++ [{nil, r + j - i, s}] ++ Enum.slice(ranges, pos+1..index-1//1) ++ Enum.slice(ranges, index+1..length(ranges))
      {updated_ranges, index - 1, id}
    end
  end

  defp compact(ranges, files, size), do: compact(ranges, files, size, [])
  defp compact(_, _, 0, compacted), do: Enum.reverse(compacted)
  defp compact([{nil, i, j}|ranges], [{f, id}|files], size, compacted) do
    cond do
      f == j - i -> compact(ranges, files, size - f, [{id, i, j}|compacted])
      f < j - i -> compact([{nil, i+f, j}|ranges], files, size - f, [{id, i, i+f}|compacted])
      true -> compact(ranges, [{f-(j-i), id}|files], size - (j-i), [{id, i, j}|compacted])
    end
  end
  defp compact([{id, i, j}|ranges], files, size, compacted) when size >= j - i, do: compact(ranges, files, size - (j-i), [{id, i, j}|compacted])
  defp compact([{id, i, _}|ranges], files, size, compacted), do: compact(ranges, files, 0, [{id, i, i + size}|compacted])

  defp checksum(compacted) do
    Enum.filter(compacted, fn {id, _, _} -> !is_nil(id) end)
    |> Enum.flat_map(fn {id, i, j} -> Enum.map(i..j-1, &(&1 * id)) end)
    |> Enum.sum
  end

  defp build_ranges(disk), do: build_ranges(disk, [], 0, 0)
  defp build_ranges([], ranges, _, _), do: Enum.reverse(ranges)
  defp build_ranges([n], ranges, current, id), do: build_ranges([n, 0], ranges, current, id)
  defp build_ranges([n, s|disk], ranges, current, id) do
    updated_ranges = [{nil, current + n, current + n + s}, {id, current, current + n}|ranges]
    build_ranges(disk, updated_ranges, current + n + s, id + 1)
  end

  def read_disk(file) do
    File.read!(file)
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end
end

DiskFragmenter.read_disk("inputs/input09.txt") |> DiskFragmenter.compact() |> IO.puts

# --- Part Two ---

DiskFragmenter.read_disk("inputs/input09.txt") |> DiskFragmenter.defragment() |> IO.puts


