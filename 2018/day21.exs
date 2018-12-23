# --- Day 21: Chronal Conversion ---

defmodule Device do
  use Bitwise, only_operators: true

  def read_and_parse_program(file) do
    read(file)
    |> Enum.map(&parse_instruction/1)
  end

  def run_program(instructions, ip, initial \\ [0, 0, 0, 0, 0, 0], options \\ %{}), do: run_program(initial, instructions, ip, 0, options)
  def run_program(regs, instructions, _ip, ipv, _options) when ipv < 0 or ipv >= length(instructions), do: regs
  def run_program(regs, instructions, ip, ipv, options) do
    new_options = check_test_mode(regs, ipv, options)

    [op, a, b, c] = Enum.at(instructions, ipv)
    updated_regs = execute(op, a, b, c, regs)
    new_ipv = Enum.at(updated_regs, ip) + 1

    List.replace_at(updated_regs, ip, new_ipv)
    |> run_program(instructions, ip, new_ipv, new_options)
  end

  defp check_test_mode(_regs, _ipv, options) when map_size(options) == 0, do: options
  defp check_test_mode(_regs, ipv, options = %{ipv: i}) when ipv != i, do: options
  defp check_test_mode(regs, _ipv, %{test_mode: reg5_values, ipv: i}) do
    reg5 = Enum.at(regs, 5)
    if reg5 in reg5_values do
      IO.puts(hd(reg5_values))
      exit(:normal)
    else
      %{test_mode: [reg5 | reg5_values], ipv: i}
    end
  end

  # addr (add register) stores into register C the result of adding register A and register B.
  defp execute("addr", a, b, c, regs_before) do
    List.replace_at(regs_before, c, Enum.at(regs_before, a) + Enum.at(regs_before, b))
  end
  # addi (add immediate) stores into register C the result of adding register A and value B.
  defp execute("addi", a, b, c, regs_before) do
    List.replace_at(regs_before, c, Enum.at(regs_before, a) + b)
  end
  # mulr (multiply register) stores into register C the result of multiplying register A and register B.
  defp execute("mulr", a, b, c, regs_before) do
    List.replace_at(regs_before, c, Enum.at(regs_before, a) * Enum.at(regs_before, b))
  end
  # muli (multiply immediate) stores into register C the result of multiplying register A and value B.
  defp execute("muli", a, b, c, regs_before) do
    List.replace_at(regs_before, c, Enum.at(regs_before, a) * b)
  end
  # banr (bitwise AND register) stores into register C the result of the bitwise AND of register A and register B.
  defp execute("banr", a, b, c, regs_before) do
    List.replace_at(regs_before, c, Enum.at(regs_before, a) &&& Enum.at(regs_before, b))
  end
  # bani (bitwise AND immediate) stores into register C the result of the bitwise AND of register A and value B.
  defp execute("bani", a, b, c, regs_before) do
    List.replace_at(regs_before, c, Enum.at(regs_before, a) &&& b)
  end
  # borr (bitwise OR register) stores into register C the result of the bitwise OR of register A and register B.
  defp execute("borr", a, b, c, regs_before) do
    List.replace_at(regs_before, c, Enum.at(regs_before, a) ||| Enum.at(regs_before, b))
  end
  # bori (bitwise OR immediate) stores into register C the result of the bitwise OR of register A and value B.
  defp execute("bori", a, b, c, regs_before) do
    List.replace_at(regs_before, c, Enum.at(regs_before, a) ||| b)
  end
  # setr (set register) copies the contents of register A into register C. (Input B is ignored.)
  defp execute("setr", a, _b, c, regs_before) do
    List.replace_at(regs_before, c, Enum.at(regs_before, a))
  end
  # seti (set immediate) stores value A into register C. (Input B is ignored.)
  defp execute("seti", a, _b, c, regs_before) do
    List.replace_at(regs_before, c, a)
  end
  # gtir (greater-than immediate/register) sets register C to 1 if value A is greater than register B. Otherwise, register C is set to 0.
  defp execute("gtir", a, b, c, regs_before) do
    List.replace_at(regs_before, c, test_gt(a, Enum.at(regs_before, b)))
  end
  # gtri (greater-than register/immediate) sets register C to 1 if register A is greater than value B. Otherwise, register C is set to 0.
  defp execute("gtri", a, b, c, regs_before) do
    List.replace_at(regs_before, c, test_gt(Enum.at(regs_before, a), b))
  end
  # gtrr (greater-than register/register) sets register C to 1 if register A is greater than register B. Otherwise, register C is set to 0.
  defp execute("gtrr", a, b, c, regs_before) do
    List.replace_at(regs_before, c, test_gt(Enum.at(regs_before, a), Enum.at(regs_before, b)))
  end
  # eqir (equal immediate/register) sets register C to 1 if value A is equal to register B. Otherwise, register C is set to 0.
  defp execute("eqir", a, b, c, regs_before) do
    List.replace_at(regs_before, c, test_eq(a, Enum.at(regs_before, b)))
  end
  # eqri (equal register/immediate) sets register C to 1 if register A is equal to value B. Otherwise, register C is set to 0.
  defp execute("eqri", a, b, c, regs_before) do
    List.replace_at(regs_before, c, test_eq(Enum.at(regs_before, a), b))
  end
  # eqrr (equal register/register) sets register C to 1 if register A is equal to register B. Otherwise, register C is set to 0.
  defp execute("eqrr", a, b, c, regs_before) do
    List.replace_at(regs_before, c, test_eq(Enum.at(regs_before, a), Enum.at(regs_before, b)))
  end

  defp test_gt(v1, v2) when v1 > v2, do: 1
  defp test_gt(_v1, _v2), do: 0
  defp test_eq(v1, v2) when v1 == v2, do: 1
  defp test_eq(_v1, _v2), do: 0

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


# What is the lowest non-negative integer value for register 0 that causes the program to halt after executing the fewest instructions?
#ip 3
# The program starts with:
# 0. seti 123 0 5 -> reg[5] = 123
# 1. bani 5 456 5 -> reg[5] = bitwise_and(reg[5], 456) = bitwise_and(123, 456) = 72
# 2. eqri 5 72 5  -> reg[5] == 72 ? true => reg[5] = 1
# 3. addr 5 3 3   -> reg[3] = reg[3] + reg[5] => change IP to 3 + 1 + 1 = 5 -> next instruction is 5, we jump 4, which was 
#                                                                              4. seti 0 0 3   -> reg[3] = 0 (starting again)

# 5. seti 0 3 5   -> reg[5] = 0
# 6. bori 5 65536 4 -> reg[4] = bitwise_or(reg[5], 65536) = bitwise_or(0, 65536) = 65536 // 2^16
# 7. seti 8858047 4 5 -> reg[5] = 8858047
# 8. bani 4 255 2     -> reg[2] = bitwise_and(reg[4], 255) = bitwise_and(65536, 255) = 0 // Keep 8 lower bits
# 9. addr 5 2 5       -> reg[5] = reg[5] + reg[2] = 8858047
# 10. bani 5 16777215 5 -> reg[5] = bitwise_and(reg[5], 16777215) = bitwise_and(8858047, 16777215) = 8858047 // Keep 24 lower bits
# 11. muli 5 65899 5    -> reg[5] = reg[5] * 65899 = 583736439253
# 12. bani 5 16777215 5 -> reg[5] = reg[5] &&& 16777215 = 6762965 // Keep 24 lower bits
# 13. gtir 256 4 2      -> 256 > reg[4] ? false => reg[2] = 0
# 14. addr 2 3 3        -> reg[3] = reg[2] + reg[3] = 0 + reg[3] => we don't jump, we continue on the next instruction, that adds 1 to IP
# 15. addi 3 1 3        -> reg[3] = reg[3] + 1, so we jump over seti 27 5 3, which is reg[3] = 27. In that case, we'd go to instruction 28, 
# which is the only one where reg 0 takes part, eqrr 5 0 2, that is, reg[2] = reg[5] == reg[0]. If that was true, we'd finish
# the program. The value that reg[5] has when we reach instruction 28 for the first time would be the value we need in reg[0] to finish the 
# the program in the fewest instructions. 
# We just modify the input to stop at instruction 28 and halt:
# Device.read_and_parse_program("./inputs/input21-modified.txt")
# |> Device.run_program(3, [0, 0, 0, 0, 0, 0])
# |> IO.inspect()

# 28: ["eqrr", 5, 0, 2]
#  -> [1, 1, 0, 28, 1, 11513432], next ip: 29
# [1, 1, 0, 29, 1, 11513432]

# And now, starting the full program with that value in 0 it quickly finishes. 
Device.read_and_parse_program("./inputs/input21.txt")
|> Device.run_program(3, [11513432, 0, 0, 0, 0, 0])
|> IO.inspect()

# --- Part Two ---
# What is the lowest non-negative integer value for register 0 that causes the program to halt after executing the most instructions?
# Following the same idea as before, we know that we'd halt when reg[5] and reg[0] are the same in instruction 28. Since reg[0] is never modified
# during the program, we must assume reg[5] decreases at some point. When it reaches its minimum value, we'd be at the max number
# of instructions. Running the program outputting only the values of the registers in instruction 28 we confirm that it goes up and down.
# We need to find when it repeats a cycle, and at that point we know that the last value it takes before going into a cycle is the number we
# need to assing to register 0. 
Device.read_and_parse_program("./inputs/input21.txt")
|> Device.run_program(3, [0, 0, 0, 0, 0, 0], %{test_mode: [], ipv: 28})
|> IO.inspect()

