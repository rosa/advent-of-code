# --- Day 22: Monkey Market ---

defmodule Market do
  import Bitwise

  def max_bananas(sequences) do
    all_keys = Map.values(sequences) |> Enum.flat_map(&Map.keys/1)
    Enum.map(all_keys, fn seq -> bananas(sequences, seq) end) |> Enum.max()
  end

  def bananas(sequences, seq) do
    Enum.map(sequences, fn {_, bans} -> if is_nil(Map.get(bans, seq)), do: 0, else: Map.get(bans, seq) end) |> Enum.sum()
  end

  def sum_secret_numbers(generated), do: Enum.map(generated, fn {_, {n, _}} -> n end) |> Enum.sum()

  defp sequences([p|prices]), do: sequences(p, {}, prices, %{})
  defp sequences(p, {}, [p1, p2, p3, p4|prices], seqs) do
    diffs = {_, d2, d3, d4} = {p1 - p, p2 - p1, p3 - p2, p4 - p3}
    sequences({d2, d3, d4}, [p2, p3, p4|prices], Map.put_new(seqs, diffs, p4))
  end
  defp sequences(_, prices, seqs) when length(prices) < 4, do: seqs
  defp sequences({d1, d2, d3}, [_, p2, p3, p4|prices], seqs) do
    diffs = {d1, d2, d3, p4 - p3}
    sequences({d2, d3, p4 - p3}, [p2, p3, p4|prices], Map.put_new(seqs, diffs, p4))
  end

  def all_sequences(generated), do: Enum.map(generated, fn {n, {_, prices}} -> {n, sequences(prices)} end) |> Enum.into(%{})

  def generate(numbers, times) when is_list(numbers) do
    Enum.map(numbers, fn n -> {n, generate(n, times)} end)
    |> Enum.into(%{})
  end

  def generate(number, 0), do: {number, [Integer.mod(number, 10)]}
  def generate(number, times) do
    n = evolve(number)
    {m, list} = generate(n, times - 1)
    {m, [Integer.mod(number, 10)|list]}
  end

  defp evolve(number) do
    n1 = (number <<< 6) |> mix(number) |> prune()
    n2 = (n1 >>> 5) |> mix(n1) |> prune()
    (n2 <<< 11) |> mix(n2) |> prune()
  end

  defp mix(n1, n2), do: bxor(n1, n2)
  defp prune(n), do: Integer.mod(n, 16777216)

  def read_numbers(path) do
    File.read!(path)
    |> String.split(~r{\n}, trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end

generated = Market.read_numbers("inputs/input22.txt") |> Market.generate(2000)
Market.sum_secret_numbers(generated) |> IO.puts()

# --- Part Two ---

Market.all_sequences(generated) |> Market.max_bananas() |> IO.puts()

