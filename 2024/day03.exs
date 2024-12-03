# --- Day 3: Mull It Over ---

defmodule Memory do
  def extract_all_muls(path), do: input(path) |> scan |> all_muls |> calculate

  def extract_applicable_muls(path), do: input(path) |> scan |> applicable_muls |> calculate

  defp all_muls(region), do: Enum.filter(region, &is_tuple/1)

  defp applicable_muls(region), do: applicable_muls(region, [], :do)
  defp applicable_muls([], muls, _), do: muls
  defp applicable_muls([:dont|region], muls, _), do: applicable_muls(region, muls, :dont)
  defp applicable_muls([:do|region], muls, _), do: applicable_muls(region, muls, :do)
  defp applicable_muls([mul|region], muls, :do), do: applicable_muls(region, muls ++ [mul], :do)
  defp applicable_muls([_|region], muls, :dont), do: applicable_muls(region, muls, :dont)

  defp calculate(muls), do: Enum.map(muls, fn {x, y} -> x * y end) |> Enum.sum

  defp scan(region) do
    Regex.scan(~r/mul\(\d{1,3},\d{1,3}\)|don\'t\(\)|do\(\)/, region)
    |> Enum.map(&hd/1)
    |> Enum.map(&parse_op/1)
  end

  defp parse_op("don't()"), do: :dont
  defp parse_op("do()"), do: :do
  defp parse_op(mul) do
    [_, d1, d2] = Regex.run(~r/mul\((\d{1,3}),(\d{1,3})\)/, mul)
    {String.to_integer(d1), String.to_integer(d2)}
  end

  defp input(path) do
    File.read!(path)
  end
end

Memory.extract_all_muls("./inputs/input03.txt") |> IO.puts

# --- Part Two ---

Memory.extract_applicable_muls("./inputs/input03.txt") |> IO.puts
