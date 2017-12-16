# --- Day 10: Knot Hash ---

#   4--5   pinch   4  5           4   1
#  /    \  5,0,1  / \/ \  twist  / \ / \
# 3      0  -->  3      0  -->  3   X   0
#  \    /         \ /\ /         \ / \ /
#   2--1           2  1           2   5

use Bitwise

defmodule KnotHash do

  def knot_hash(input) do
    (to_charlist(input) ++ [17, 31, 73, 47, 23])
    |> sparse_hash()
    |> dense_hash()
    |> Enum.map(&int_to_hex/1)
    |> Enum.join
    |> String.downcase
  end

  def one_round_hash(lengths, count \\ 256) do
    Enum.to_list(0..count-1)
    |> transform(lengths)
    |> Enum.take(2)
    |> Enum.reduce(&*/2)
  end

  def sparse_hash(lengths, count \\ 256) do
    Enum.to_list(0..count-1)
    |> do_round(lengths, 64, 0, 0)
  end

  def dense_hash(list) do
    Enum.chunk_every(list, 16)
    |> Enum.map(fn(chunk) -> Enum.reduce(chunk, &bxor/2) end)
  end

  def do_round(list, _, 0, _, _), do: list
  def do_round(list, lengths, nround, current, skip) do
    {list, current, skip} = transform_in_round(list, lengths, current, skip)
    do_round(list, lengths, nround - 1, current, skip)
  end

  def transform_in_round(list, [], current, skip), do: {list, current, skip}
  def transform_in_round(list, [len|lengths], current, skip) do
    select_and_reverse(list, current, len)
    |> transform_in_round(lengths, rem(current + len + skip, length(list)), skip + 1)
  end    

  defp transform(list, lengths), do: transform(list, lengths, 0, 0)
  defp transform(list, [], _, _), do: list
  defp transform(list, [len|lengths], current, skip) do
    select_and_reverse(list, current, len)
    |> transform(lengths, rem(current + len + skip, length(list)), skip + 1)
  end

  defp select_and_reverse(list, 0, size) do
    Enum.reverse(Enum.slice(list, 0, size), Enum.slice(list, size, length(list)))
  end

  # Wraps
  defp select_and_reverse(list, start, size) when start + size > length(list) do
    reversed = Enum.slice(list, start, size) ++ Enum.slice(list, 0, start + size - length(list)) |> Enum.reverse
    {tail, head} = Enum.split(reversed, length(list) - start)
    head ++ Enum.slice(list, start + size - length(list), length(list) - size) ++ tail
  end

  defp select_and_reverse(list, start, size) do
    Enum.slice(list, 0, start) ++ Enum.reverse(Enum.slice(list, start, size), Enum.slice(list, start + size, length(list)))
  end

  def int_to_hex(integer) when integer > 15, do: Integer.to_charlist(integer, 16)
  def int_to_hex(integer), do: ['0'] ++ Integer.to_charlist(integer, 16)
end

lengths = [102,255,99,252,200,24,219,57,103,2,226,254,1,0,69,216]
KnotHash.one_round_hash(lengths) |> IO.puts

# --- Part Two ---

# Character list instead of binary
input = "102,255,99,252,200,24,219,57,103,2,226,254,1,0,69,216"
KnotHash.knot_hash(input) |> IO.puts
