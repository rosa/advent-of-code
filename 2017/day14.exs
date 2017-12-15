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
    # |> count_regions()
  end

  def disk(input) do
    for n <- 0..127, do: row("#{input}-#{n}")
  end

  def row(string) do
    knot_hash(string)
    |> String.graphemes
    |> Enum.map(&hex_to_bin/1)
    |> Enum.join()
    |> String.graphemes
    |> Enum.map(&String.to_integer/1)
  end

  def hex_to_bin(digit) do
    String.to_integer(digit, 16)
    |> Integer.to_string(2)
    |> pad
  end

  def pad(digits) do
    String.duplicate("0", (4 - String.length(digits))) <> digits
  end
end

input = "hxtvlmkl"
DiskDefragmenter.usage(input) |> IO.puts

# --- Part Two ---


