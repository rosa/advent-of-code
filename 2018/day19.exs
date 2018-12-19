# --- Day 19: Go With The Flow ---

defmodule Device do
  use Bitwise, only_operators: true

  def read_and_parse_program(file) do
    read(file)
    |> Enum.map(&parse_instruction/1)
  end

  def run_program(instructions, ip, initial \\ [0, 0, 0, 0, 0, 0]), do: run_program(initial, instructions, ip, 0)
  def run_program(regs, instructions, _ip, ipv) when ipv < 0 or ipv >= length(instructions), do: regs
  def run_program(regs, instructions, ip, ipv) do
    [op, a, b, c] = Enum.at(instructions, ipv)
    IO.puts("#{inspect(ipv)}: #{inspect([op, a, b, c])}")
    updated_regs = execute(op, a, b, c, regs)
    new_ipv = Enum.at(updated_regs, ip) + 1
    IO.puts(" -> #{inspect(updated_regs)}, next ip: #{inspect(new_ipv)}")

    List.replace_at(updated_regs, ip, new_ipv)
    |> run_program(instructions, ip, new_ipv)
  end

  # addr (add register) stores into register C the result of adding register A and register B.
  def execute("addr", a, b, c, regs_before) do
    List.replace_at(regs_before, c, Enum.at(regs_before, a) + Enum.at(regs_before, b))
  end
  # addi (add immediate) stores into register C the result of adding register A and value B.
  def execute("addi", a, b, c, regs_before) do
    List.replace_at(regs_before, c, Enum.at(regs_before, a) + b)
  end
  # mulr (multiply register) stores into register C the result of multiplying register A and register B.
  def execute("mulr", a, b, c, regs_before) do
    List.replace_at(regs_before, c, Enum.at(regs_before, a) * Enum.at(regs_before, b))
  end
  # muli (multiply immediate) stores into register C the result of multiplying register A and value B.
  def execute("muli", a, b, c, regs_before) do
    List.replace_at(regs_before, c, Enum.at(regs_before, a) * b)
  end
  # banr (bitwise AND register) stores into register C the result of the bitwise AND of register A and register B.
  def execute("banr", a, b, c, regs_before) do
    List.replace_at(regs_before, c, Enum.at(regs_before, a) &&& Enum.at(regs_before, b))
  end
  # bani (bitwise AND immediate) stores into register C the result of the bitwise AND of register A and value B.
  def execute("bani", a, b, c, regs_before) do
    List.replace_at(regs_before, c, Enum.at(regs_before, a) &&& b)
  end
  # borr (bitwise OR register) stores into register C the result of the bitwise OR of register A and register B.
  def execute("borr", a, b, c, regs_before) do
    List.replace_at(regs_before, c, Enum.at(regs_before, a) ||| Enum.at(regs_before, b))
  end
  # bori (bitwise OR immediate) stores into register C the result of the bitwise OR of register A and value B.
  def execute("bori", a, b, c, regs_before) do
    List.replace_at(regs_before, c, Enum.at(regs_before, a) ||| b)
  end
  # setr (set register) copies the contents of register A into register C. (Input B is ignored.)
  def execute("setr", a, _b, c, regs_before) do
    List.replace_at(regs_before, c, Enum.at(regs_before, a))
  end
  # seti (set immediate) stores value A into register C. (Input B is ignored.)
  def execute("seti", a, _b, c, regs_before) do
    List.replace_at(regs_before, c, a)
  end
  # gtir (greater-than immediate/register) sets register C to 1 if value A is greater than register B. Otherwise, register C is set to 0.
  def execute("gtir", a, b, c, regs_before) do
    List.replace_at(regs_before, c, test_gt(a, Enum.at(regs_before, b)))
  end
  # gtri (greater-than register/immediate) sets register C to 1 if register A is greater than value B. Otherwise, register C is set to 0.
  def execute("gtri", a, b, c, regs_before) do
    List.replace_at(regs_before, c, test_gt(Enum.at(regs_before, a), b))
  end
  # gtrr (greater-than register/register) sets register C to 1 if register A is greater than register B. Otherwise, register C is set to 0.
  def execute("gtrr", a, b, c, regs_before) do
    List.replace_at(regs_before, c, test_gt(Enum.at(regs_before, a), Enum.at(regs_before, b)))
  end
  # eqir (equal immediate/register) sets register C to 1 if value A is equal to register B. Otherwise, register C is set to 0.
  def execute("eqir", a, b, c, regs_before) do
    List.replace_at(regs_before, c, test_eq(a, Enum.at(regs_before, b)))
  end
  # eqri (equal register/immediate) sets register C to 1 if register A is equal to value B. Otherwise, register C is set to 0.
  def execute("eqri", a, b, c, regs_before) do
    List.replace_at(regs_before, c, test_eq(Enum.at(regs_before, a), b))
  end
  # eqrr (equal register/register) sets register C to 1 if register A is equal to register B. Otherwise, register C is set to 0.
  def execute("eqrr", a, b, c, regs_before) do
    List.replace_at(regs_before, c, test_eq(Enum.at(regs_before, a), Enum.at(regs_before, b)))
  end

  def test_gt(v1, v2) when v1 > v2, do: 1
  def test_gt(_v1, _v2), do: 0
  def test_eq(v1, v2) when v1 == v2, do: 1
  def test_eq(_v1, _v2), do: 0

  # addi 1 16 1
  defp parse_instruction(instruction) do
    [opcode | regs] = String.split(instruction, ~r/\s/, trim: true)
    [opcode | Enum.map(regs, &String.to_integer/1)]
  end

  defp read(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
  end
end

#ip 1
# Device.read_and_parse_program("./inputs/input19.txt")
# |> Device.run_program(1)
# |> IO.inspect()

# --- Part Two ---

# Device.read_and_parse_program("./inputs/input19.txt")
# |> Device.run_program(1, [1, 0, 0, 0, 0, 0])
# |> IO.inspect()
# This just takes too long, we need to look at what the program does.
# 
# Removing the last line of the program, we only run the "initialization". 
# The last line of the program is `seti 0 4 1`, that sends the IP back to 0
# to do something with the value in reg[5].
# This is what we got before jumping to the beginning:
# [0, 35, 0, 0, 10550400, 10551296]
# In the next part we have two loops finding all pairs of numbers that multiplied together
# give that value in reg[5], 10551296. We go storing them in reg[2] and reg[3]
# and comparing them like this:
# mulr 2 3 4
# eqrr 4 5 4
# After these we do this:
# 5. addr 4 1 1 <-- if reg[2] * reg[3] == reg[5], we jump to 7. addr 2 0 0, otherwise we continue with 6. and skip 7. 
# 6. addi 1 1 1
# 7. addr 2 0 0 <-- add reg[2] to reg[0], that starts in 0. 
# Then, after incrementing reg[2], we do this:
# 12. addi 2 1 2
# 13. gtrr 2 5 4
# 14. addr 4 1 1
# 15. seti 1 1 1
# That is, if reg[2] > reg[5], we skip 14 and in 15 we set a big value in IP that takes us outside the program.
# If reg[2] <= reg[5], we continue looping, putting reg[3] back to 1
# This means we'll get the sum of all possible x, for every pair {x, y} of divisors of
# 10551296, with repetition. This is what the program does, basically:
1..10551296 |> Enum.filter(fn x -> rem(10551296, x) == 0 end) |> Enum.sum() |> IO.puts()

