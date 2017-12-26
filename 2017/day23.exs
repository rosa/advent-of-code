# --- Day 23: Coprocessor Conflagration ---

# set X Y sets register X to the value of Y.
# sub X Y decreases register X by the value of Y.
# mul X Y sets register X to the result of multiplying the value contained in register X by the value of Y.
# jnz X Y jumps with an offset of the value of Y, but only if the value of X is not zero.
# (An offset of 2 skips the next instruction, an offset of -1 jumps to the previous instruction, and so on.)

defmodule Coprocessor do

  def run(file, input) do
    instructions = lines(file)
    |> Enum.map(&parse_instruction/1)

    run_and_count_mul(Map.merge(init(), input), instructions)
    |> value("h")
  end

  def count_mul(file) do
    lines(file)
    |> Enum.map(&parse_instruction/1)
    |> run_and_count_mul()
  end

  def run_and_count_mul(instructions) do
    run_and_count_mul(init(), instructions)
    |> value(:mul_count)
  end

  def run_and_count_mul(registers, instructions) do
    cond do 
      registers[:ip] >= length(instructions) -> registers
      true -> execute(registers, Enum.at(instructions, registers[:ip])) |> run_and_count_mul(instructions)
    end
  end

  defp init() do
    %{ip: 0, mul_count: 0}
  end

  # set X Y sets register X to the value of Y.
  defp execute(registers, ["set", x, y]) do
    Map.put(registers, x, value(registers, y))
    |> Map.put(:ip, registers[:ip] + 1)
  end
  # sub X Y decreases register X by the value of Y.
  defp execute(registers, ["sub", x, y]) do
    Map.put(registers, x, value(registers, x) - value(registers, y))
    |> Map.put(:ip, registers[:ip] + 1)
  end
  # mul X Y sets register X to the result of multiplying the value contained in register X by the value of Y.
  defp execute(registers, ["mul", x, y]) do
    Map.put(registers, x, value(registers, x) * value(registers, y))
    |> Map.put(:ip, registers[:ip] + 1)
    |> Map.put(:mul_count, registers[:mul_count] + 1)
  end
  # jnz X Y jumps with an offset of the value of Y, but only if the value of X is not zero
  # An offset of 2 skips the next instruction, an offset of -1 jumps to the previous instruction, and so on.
  defp execute(registers, ["jnz", x, y]) do
    if value(registers, x) != 0 do
      Map.put(registers, :ip, registers[:ip] + value(registers, y))
    else
      Map.put(registers, :ip, registers[:ip] + 1)
    end
  end
  # jp X Y jumps with an offset of the value of Y, but only if the value of X is prime
  defp execute(registers, ["jp", x, y]) do
    if prime?(value(registers, x)) do
      Map.put(registers, :ip, registers[:ip] + value(registers, y))
    else
      Map.put(registers, :ip, registers[:ip] + 1)
    end
  end

  defp prime?(2), do: true
  defp prime?(n) when n<2 or rem(n, 2) == 0, do: false
  defp prime?(n), do: prime?(n, 3)
 
  defp prime?(n, k) when n < k*k, do: true
  defp prime?(n, k) when rem(n, k) == 0, do: false
  defp prime?(n, k), do: prime?(n, k+2)

  defp value(registers, x) do
    if is_atom(x) || String.match?(x, ~r/[a-z]/) do
      registers[x] || 0
    else
      String.to_integer(x)
    end
  end

  defp parse_instruction(line), do: String.split(line, ~r{\s}, trim: true)

  defp lines(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
  end
end

Coprocessor.count_mul("./inputs/input23.txt") |> IO.puts

# --- Part Two ---

# Optimise assembly
# b = 109300
# c = 126300

# do {
#   f = 1
#   d = 2

#   do {
#     e = 2

#     do {
#       f = 0 if (d * e == b)  # Only when a d divides b
#       e += 1
#     } while (e != b)

#     d++
#   } while (d != b)

#   h += 1 if (f == 0) # Only when d divides b
#   g = b

#   b += 17 if (b != c)
# } while (g != c)

# We do h += 1 when we can find a d between 2 and b that divides b => when b is not prime
# New instruction: jp X Y jump if prime

Coprocessor.run("./inputs/input23_optimised.txt", %{"a" => 1}) |> IO.inspect
