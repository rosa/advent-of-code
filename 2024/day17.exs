# --- Day 17: Chronospatial Computer ---

defmodule Handheld do
  import Bitwise

  # Start for the last instruction and go adding bits to A in groups of 3, 3 bits per value in the output
  def quine({{_, b, c}, instructions}) do
    [i|rest] = Map.values(instructions) |> Enum.reverse()
    quine({{0, b, c}, instructions}, rest, [i])
  end

  def quine(program, [], output), do: quine(program, output)
  def quine(program={{_, b, c}, instructions}, [r|rest], output) do
    partial_a = quine(program, output)
    quine({{partial_a <<< 3, b, c}, instructions}, rest, [r] ++ output)
  end

  def quine(program={{a, b, c}, instructions}, output) do
    cond do
      run(program) == Enum.join(output, ",") -> a
      true -> quine({{a+1, b, c}, instructions}, output)
    end
  end

  def run({registers, instructions}), do: run({registers, 0, []}, instructions)
  def run({_, ip, output}, instructions) when ip >= map_size(instructions), do: Enum.join(output, ",")
  def run({registers, ip, output}, instructions) do
    instruction = {Map.get(instructions, ip), Map.get(instructions, ip+1)}

    execute(instruction, registers, ip, output) |> run(instructions)
  end

  # Combo operands 0 through 3 represent literal values 0 through 3.
  # Combo operand 4 represents the value of register A.
  # Combo operand 5 represents the value of register B.
  # Combo operand 6 represents the value of register C.
  # Combo operand 7 is reserved and will not appear in valid programs.
  defp combo(op, _) when op in (0..3), do: op
  defp combo(op, registers), do: elem(registers, op - 4)

  # adv instruction (opcode 0) - divide A by combo op into A
  defp execute({0, op}, registers = {a, b, c}, ip, output), do: {{a >>> combo(op, registers), b, c}, ip + 2, output}
  # bxl instruction (opcode 1) - bitwise B XOR literal op
  defp execute({1, op}, {a, b, c}, ip, output), do: {{a, bxor(b, op), c}, ip + 2, output}
  # bst instruction (opcode 2) - combo mod 8
  defp execute({2, op}, registers = {a, _, c}, ip, output), do: {{a, band(combo(op, registers), 7), c}, ip + 2, output}
  # jnz instruction (opcode 3) - jump to literal op if A is not zero
  defp execute({3, _}, registers = {0, _, _}, ip, output), do: {registers, ip + 2, output}
  defp execute({3, op}, registers, _, output), do: {registers, op, output}
  # bxc instruction (opcode 4) - B XOR C
  defp execute({4, _}, {a, b, c}, ip, output), do: {{a, bxor(b, c), c}, ip + 2, output}
  # out instruction (opcode 5) - output combo mod 8
  defp execute({5, op}, registers, ip, output), do: {registers, ip + 2, output ++ [band(combo(op, registers), 7)]}
  # bdv instruction (opcode 6) - divide A by combo op into B
  defp execute({6, op}, registers = {a, _, c}, ip, output), do: {{a, a >>> combo(op, registers), c}, ip + 2, output}
  # cdv instruction (opcode 7) - divide A by combo op into C
  defp execute({7, op}, registers = {a, b, _}, ip, output), do: {{a, b, a >>> combo(op, registers)}, ip + 2, output}

  def read_program(file) do
    [registers, instructions] = File.read!(file)
    |> String.split(~r{\n\n}, trim: true)
    |> Enum.map(&(String.split(&1, ~r{\n}, trim: true)))

    {parse_registers(registers), parse_instructions(instructions)}
  end

  defp parse_registers(lines) do
    Enum.map(lines, &parse_register/1)
    |> List.to_tuple()
  end

  defp parse_register(line) do
    [_, value] = String.split(line, ": ", trim: true)
    String.to_integer(value)
  end

  defp parse_instructions([line]) do
    [_, instructions] = String.split(line, ": ", trim: true)
    parsed = String.split(instructions, ",", trim: true)
    |> Enum.map(&String.to_integer/1)

    Enum.zip((0..length(parsed)), parsed) |> Enum.into(%{})
  end
end

Handheld.read_program("inputs/input17.txt") |> Handheld.run() |> IO.puts()

# --- Part Two ---

Handheld.read_program("inputs/input17.txt") |> Handheld.quine() |> IO.puts()
