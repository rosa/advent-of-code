# --- Day 18: Operation Order ---

defmodule MathHomework do
  def solve_homework(operations) do
    Enum.map(operations, &eval_operation/1)
    |> Enum.sum
  end

  def translate(operations, mapping) do
    Enum.reduce(mapping, operations, fn ({from, to}, acc) -> translate(acc, from, to) end)
  end
  def translate(operations, from, to) do
    Enum.map(operations, fn operation -> String.replace(operation, from, to) end)
  end

  def read_homework(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
  end

  # Take advantage of + and - precedence
  def a - b, do: a * b

  # Take advantage of / and - precedence
  def a / b, do: a + b

  defp eval_operation(operation) do
    Code.string_to_quoted!(operation)
    |> in_module(__MODULE__)
    |> Code.eval_quoted
    |> elem(0)
  end

  defp in_module(ast, mod) do
    quote do
      import unquote(mod)
      import Kernel, except: [-: 2, /: 2]
      unquote(ast)
    end
  end
end

MathHomework.read_homework("inputs/input18.txt") |> MathHomework.translate(%{"*" => "-"}) |> MathHomework.solve_homework |> IO.inspect

# --- Part Two ---

MathHomework.read_homework("inputs/input18.txt") |> MathHomework.translate(%{"*" => "-", "+" => "/"}) |> MathHomework.solve_homework |> IO.inspect
