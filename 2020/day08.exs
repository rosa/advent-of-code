# --- Day 8: Handheld Halting ---

defmodule Handheld do
  def run_up_to_infinite_loop_or_halt(instructions), do: run_up_to_infinite_loop_or_halt({0, 0}, instructions, MapSet.new)
  def run_up_to_infinite_loop_or_halt({acc, ip}, instructions, ip_values) do
    cond do
      ip in ip_values -> {:loop, acc} # Infinite loop
      ip >= Enum.count(instructions) -> {:halt, acc} # Halt
      true -> execute(Enum.at(instructions, ip), acc, ip) |> run_up_to_infinite_loop_or_halt(instructions, MapSet.put(ip_values, ip))
    end
  end

  def fix_program(instructions), do: fix_program(instructions, 0)
  def fix_program(instructions, index) do
    instruction = Enum.at(instructions, index)
    if fixable?(instruction) do
      {state, acc} = List.replace_at(instructions, index, fixed(instruction))
      |> run_up_to_infinite_loop_or_halt()
      case state do
        :loop -> fix_program(instructions, index + 1)
        :halt -> {state, acc}
      end
    else
      fix_program(instructions, index + 1)
    end
  end

  defp fixable?({operation, argument}), do: operation == "jmp" || (operation == "nop" && argument != 0)

  defp fixed({"nop", argument}), do: {"jmp", argument}
  defp fixed({"jmp", argument}), do: {"nop", argument}

  # acc increases or decreases a single global value called the accumulator by the value given in the argument
  # jmp jumps to a new instruction relative to itself
  # nop stands for No OPeration - it does nothing. The instruction immediately below it is executed next.
  defp execute({"acc", argument}, acc, ip), do: {acc + argument, ip + 1}
  defp execute({"jmp", argument}, acc, ip), do: {acc, ip + argument}
  defp execute({"nop", _}, acc, ip), do: {acc, ip + 1}

  def read_instructions(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
    |> Enum.map(&parse_instruction/1)
  end

  defp parse_instruction(instruction) do
    [operation, argument] = String.split(instruction, ~r{\s}, trim: true)
    {operation, String.to_integer(argument)}
  end
end

Handheld.read_instructions("inputs/input08.txt") |> Handheld.run_up_to_infinite_loop_or_halt() |>  IO.inspect

# --- Part Two ---

Handheld.read_instructions("inputs/input08.txt") |> Handheld.fix_program() |> IO.inspect
