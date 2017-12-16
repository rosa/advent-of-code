# --- Day 15: Dueling Generators ---

# A judge waits for each of them to generate its next value, compares the lowest 16 bits of both values,
# and keeps track of the number of times those parts of the values match.

# The generators both work on the same principle.
# To create its next value, a generator will take the previous value it produced, multiply it by a factor
# (generator A uses 16807; generator B uses 48271), and then keep the remainder of dividing that resulting
# product by 2147483647. That final remainder is the value it produces next.

# The judge would like to consider 40 million pairs

use Bitwise, only_operators: true

defmodule Generators do

  def judge(seeds, count, next), do: judge(seeds, count, 0, next)

  def judge(_, 0, matches, _), do: matches

  def judge(values, count, matches, next) do
    if match?(values) do
      judge(next.(values), count - 1, matches + 1, next)
    else
      judge(next.(values), count - 1, matches, next)
    end
  end

  # generator A uses 16807; generator B uses 48271
  # keep the remainder of dividing that resulting product by 2147483647
  defp next({a, b}), do: {value(a, 16807), value(b, 48271)}

  # Generator A looks for values that are multiples of 4.
  # Generator B looks for values that are multiples of 8.
  defp next_picky({a, b}), do: {next_mul(a, 16807, 4), next_mul(b, 48271, 8)}

  defp next_mul(n, multiplier, modulo), do: next_mul(n, multiplier, modulo, value(n, multiplier))
  defp next_mul(n, multiplier, modulo, result) do
    if rem(result, modulo) == 0 do
      result
    else
      next_mul(n, multiplier, modulo, value(result, multiplier))
    end
  end

  defp value(n, multiplier), do: rem(n * multiplier, 2147483647)

  defp match?({a, b}), do: lowest_16(a) == lowest_16(b)

  defp lowest_16(n), do: n &&& 0xFFFF
end

# Generator A starts with 116
# Generator B starts with 299
Generators.judge({116, 299}, 40_000_000, &Generators.next/1) |> IO.puts

# --- Part Two ---
Generators.judge({116, 299}, 5_000_000, &Generators.next_picky/1) |> IO.puts

