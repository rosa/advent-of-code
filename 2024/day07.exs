# --- Day 7: Bridge Repair ---

defmodule BridgeOperations do
  def total_calibration(equations, operators) do
    Enum.filter(equations, &(fixable?(&1, operators)))
    |> Enum.map(&(elem(&1, 0)))
    |> Enum.sum
  end

  defp fixable?({result, [op|operands]}, operators), do: test_operators(result, operands, op, operators)

  defp test_operators(result, [], result, _), do: true
  defp test_operators(_, [], _, _), do: false
  defp test_operators(result, [op|operands], total, operators) do
    Enum.any?(operators, fn operator -> test_operators(result, operands, operator.(total, op), operators) end)
  end

  def concat(a, b), do: "#{a}#{b}" |> String.to_integer

  def read_equations(path) do
    File.read!(path)
    |> String.split(~r{\n}, trim: true)
    |> Enum.map(&parse_equation/1)
  end

  defp parse_equation([result|operands]), do: {result, operands}
  # 3267: 81 40 27
  defp parse_equation(line) do
    String.split(line, ~r{:?\s}, trim: true)
    |> Enum.map(&String.to_integer/1)
    |> parse_equation
  end
end

sum = &Kernel.+/2
mul = &Kernel.*/2
con = &BridgeOperations.concat/2

BridgeOperations.read_equations("./inputs/input07.txt") |> BridgeOperations.total_calibration([sum, mul]) |> IO.inspect

# --- Part Two ---
BridgeOperations.read_equations("./inputs/input07.txt") |> BridgeOperations.total_calibration([sum, mul, con]) |> IO.inspect

