# --- Day 13: Shuttle Search ---

defmodule Shuttle do
  def closest_bus({timestamp, buses}) do
    Enum.reject(buses, &(&1 == "x"))
    |> Enum.map(fn bus -> waiting_time(timestamp, bus) end)
    |> Enum.min_by(&(elem(&1, 1)))
    |> multiply()
  end

  # We need to find t such that each bus bi in position i
  # t ≡ bi - i (mod bi). This means that:
  # t ≡ b0 (mod b0)
  # t ≡ b1 - 1 (mod b1)
  # ...
  # t ≡ bn - n (mod bn)
  # This has a solution if b1..bn are coprime, and the solution is unique modulo b0*b1*...*bn,
  # by the Chinese Remainder Theorem
  def winning_time(buses) do
    Enum.zip(buses, 0..Enum.count(buses))
    |> Enum.reject(fn {bus, _} -> bus == "x" end)
    |> Enum.map(fn {bus, i} -> {bus, bus - i} end)
    |> apply_chinese_remainder_theorem()
  end

  def apply_chinese_remainder_theorem(congruences), do: apply_chinese_remainder_theorem(congruences, modulo(congruences), [])
  def apply_chinese_remainder_theorem([], n, results), do: results |> Enum.reduce(&(&1 + &2)) |> rem(n)
  def apply_chinese_remainder_theorem([{b, i}|congruences], n, results) do
    y = div(n, b)
    z = modular_inverse(y, b)
    apply_chinese_remainder_theorem(congruences, n, results ++ [i * y * z])
  end

  def modulo(congruences), do: Enum.map(congruences, &(elem(&1, 0))) |> Enum.reduce(&(&1 * &2))

  def modular_inverse(y, n), do: extended_euclid(y, n) |> elem(1) |> rem(n) |> normalize(n)

  def extended_euclid(0, b), do: {b, 0, 1}
  def extended_euclid(a, b) do
    {gcd, x1, y1} = extended_euclid(rem(b, a), a)
    {gcd, y1 - div(b, a) * x1, x1}
  end

  def normalize(m, n), do: rem(m + n, n)

  def read_notes(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
    |> parse_notes()
  end

  defp multiply({x, y}), do: x * y

  defp waiting_time(timestamp, bus), do: {bus, bus - (timestamp - div(timestamp, bus) * bus)}

  defp parse_notes([timestamp, buses]) do
    { String.to_integer(timestamp), parse_buses(buses) }
  end

  defp parse_buses(buses) do
    String.split(buses, ~r{,}, trim: true)
    |> Enum.map(fn x -> if x == "x", do: x, else: String.to_integer(x) end)
  end
end

Shuttle.read_notes("inputs/input13.txt") |> Shuttle.closest_bus() |> IO.inspect

# --- Part Two ---

Shuttle.read_notes("inputs/input13.txt") |> elem(1) |> Shuttle.winning_time() |> IO.inspect
