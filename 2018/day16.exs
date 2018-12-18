# --- Day 16: Chronal Classification ---

defmodule Device do
  use Bitwise, only_operators: true

  def read_and_parse_samples(file) do
    read(file)
    |> parse_samples()
  end

  def with_three_or_more_candidates(samples) do
    Enum.filter(samples, fn sample -> Enum.count(posible_ops(sample)) >= 3 end)
  end

  def read_program(file) do
    read(file)
    |> Enum.map(&parse_regs/1)
  end

  def run_program(instructions, map), do: run_program([0, 0, 0, 0], instructions, map)
  def run_program(regs, [], _map), do: regs
  def run_program(regs, [[op, a, b, c] | instructions], map) do
    execute(map[op], a, b, c, regs)
    |> run_program(instructions, map)
  end

  def map_opcodes(samples) do
    Enum.reduce(samples, %{}, fn sample, acc -> Map.put(acc, hd(sample.instruction), posible_ops(sample)) end)
  end

  def deduce(map_opcodes), do: deduce(map_opcodes, %{})
  def deduce(map_opcodes, deduced) when map_size(map_opcodes) == 0, do: deduced
  def deduce(map_opcodes, deduced) do
    {n, [op]} = Enum.find(map_opcodes, fn {_, ops} -> Enum.count(ops) == 1 end)

    Map.delete(map_opcodes, n)
    |> Enum.reduce(%{}, fn {n, ops}, acc -> Map.put(acc, n, List.delete(ops, op)) end)
    |> deduce(Map.put(deduced, n, op))
  end

  @ops ~w(addr addi mulr muli banr bani borr bori setr seti gtir gtri gtrr eqir eqri eqrr)

  def posible_ops(%{instruction: instruction, regs_after: regs_after, regs_before: regs_before}), do: posible_ops(regs_before, instruction, regs_after)
  def posible_ops(regs_before, instruction, regs_after) do
    Enum.filter(@ops, fn op -> valid?(op, regs_before, instruction, regs_after) end)
  end

  def valid?(op, regs_before, [_, a, b, c], regs_after), do: execute(op, a, b, c, regs_before) == regs_after

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

  defp parse_samples(lines), do: parse_samples(lines, [])
  defp parse_samples([], parsed), do: parsed
  # Before: [0, 0, 2, 2]
  # 9 2 3 0
  # After:  [4, 0, 2, 2]
  defp parse_samples([before, instruction, afteri | lines], parsed) do
    parse_samples(lines, parsed ++ [parse_sample(before, instruction, afteri)])
  end

  defp parse_sample(before, instruction, afteri) do
    [_, regs_before] = Regex.run(~r/Before:\s+\[(\d+, \d+, \d+, \d+)\]/, before)
    [_, regs_after] = Regex.run(~r/After:\s+\[(\d+, \d+, \d+, \d+)\]/, afteri)
    %{regs_before: parse_regs(regs_before), instruction: parse_regs(instruction), regs_after: parse_regs(regs_after)}
  end

  defp parse_regs(regs), do: String.split(regs, ~r/,? /, trim: true) |> Enum.map(&String.to_integer/1)

  defp read(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
  end
end

Device.read_and_parse_samples("./inputs/input16-1.txt")
|> Device.with_three_or_more_candidates()
|> Enum.count()
|> IO.puts()

# --- Part Two ---
map = Device.read_and_parse_samples("./inputs/input16-1.txt")
|> Device.map_opcodes()
|> Device.deduce()

Device.read_program("./inputs/input16-2.txt")
|> Device.run_program(map)
|> IO.inspect()

