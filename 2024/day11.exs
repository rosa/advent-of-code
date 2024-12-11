# --- Day 11: Plutonian Pebbles ---

require Integer

defmodule Stones do
  def size(stones), do: Map.values(stones) |> Enum.sum

  def simulate(stones, 0), do: stones
  def simulate(stones, blinks), do: blink(stones) |> simulate(blinks - 1)

  def blink(stones), do: present(stones) |> blink(stones, %{})

  def blink([], _, transformed), do: transformed
  def blink([0|stones], previous, transformed), do: blink(stones, previous, replace(previous, transformed, 0, 1))
  def blink([n|stones], previous, transformed) do
    if even_digits?(n) do
      blink(stones, previous, replace(previous, transformed, n, split_digits(n)))
    else
      blink(stones, previous, replace(previous, transformed, n, n * 2024))
    end
  end

  def present(stones) do
    Map.filter(stones, fn {_, v} -> v > 0 end) |> Map.keys()
  end

  def replace(from, into, n, [r1, r2]), do: replace(from, replace(from, into, n, r1), n, r2)

  def replace(from, into, n, r) do
    %{^n => v} = from
    increment(into, r, v)
  end

  def increment(stones, key, value) do
    if Map.has_key?(stones, key) do
      %{^key => v} = stones
      %{stones | key => v + value}
    else
      Map.put(stones, key, value)
    end
  end

  def even_digits?(n), do: Integer.to_string(n) |> String.length() |> Integer.is_even()
  def split_digits(n) do
    s = Integer.to_string(n)
    String.split_at(s, trunc(String.length(s)/2))
    |> Tuple.to_list()
    |> Enum.map(&String.to_integer/1)
  end

  def read(file) do
    File.read!(file)
    |> String.trim()
    |> String.split(~r{\s}, trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.frequencies()
  end
end

Stones.read("inputs/input11.txt") |> Stones.simulate(25) |> Stones.size() |> IO.puts

# --- Part Two ---

Stones.read("inputs/input11.txt") |> Stones.simulate(75) |> Stones.size() |> IO.puts
