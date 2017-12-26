# --- Day 8: I Heard You Like Registers ---

# b inc 5 if a > 1
# a inc 1 if b < 5
# c dec -10 if a >= 1
# c inc -20 if c == 10

defmodule Register do

  def execute_program(filename) do
    execute_program(%{}, lines(filename)) |> Map.values |> Enum.max
  end

  def execute_program(registers, []), do: registers
  def execute_program(registers, [line|lines]) do
    execute_instruction(registers, line) |> execute_program(lines)
  end

  def execute_program_biggest_held(filename) do
    execute_program_biggest_held(%{}, lines(filename)) |> elem(0)
  end

  def execute_program_biggest_held(registers, []), do: {Map.values(registers) |> Enum.max, registers}
  def execute_program_biggest_held(registers, [line|lines]) do
    registers = execute_instruction(registers, line)
    max = Map.values(registers) |> Enum.max
    {final_max, final_registers} = execute_program_biggest_held(registers, lines)
    {Enum.max([max, final_max]), final_registers}
  end

  defp execute_instruction(registers, line) do
    [operation, condition] = String.split(line, " if ", trim: true)
    case evaluate_condition(registers, condition) do
      {true, registers} -> execute_operation(registers, operation)
      {false, registers} -> registers
    end
  end

  defp evaluate_condition(registers, condition) do
    [_, register, operator, value] = Regex.run(~r{(\w+)\s(<|>|!=|==|>=|<=)\s(-?\d+)}, condition)
    {true_or_false?(registers[register], operator, value), Map.put_new(registers, register, 0)}
  end

  defp true_or_false?(nil, operator, value), do: true_or_false?(0, operator, value)
  defp true_or_false?(register_value, operator, value), do: eval("#{register_value} #{operator} #{value}")

  defp execute_operation(registers, operation) do
    [_, register, operator, value] = Regex.run(~r{(\w+)\s(inc|dec)\s(-?\d+)}, operation)
    Map.put(registers, register, perform_operation(registers[register], equivalent_operator(operator), value))
  end

  defp perform_operation(nil, operator, value), do: perform_operation(0, operator, value)
  defp perform_operation(register_value, operator, value), do: eval("#{register_value} #{operator} #{value}")

  defp equivalent_operator("inc"), do: "+"
  defp equivalent_operator("dec"), do: "-"

  defp eval(code), do: Code.eval_string(code) |> elem(0)

  defp lines(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
  end
end

Register.execute_program("./inputs/input08.txt") |> IO.puts

# --- Part Two ---

Register.execute_program_biggest_held("./inputs/input08.txt") |> IO.puts