# --- Day 18: Duet ---

# set a 1
# add a 2
# mul a a
# mod a 5
# snd a
# set a 0
# rcv a
# jgz a -1
# set a 1
# jgz a -2

defmodule Duet do

  def recover(file) do
    lines(file)
    |> Enum.map(&parse_instruction/1)
    |> run_until_recover()
  end

  def run_in_parallel(file) do
    instructions = lines(file) |> Enum.map(&parse_instruction/1)
    run_in_parallel(init(), instructions)
    |> get_in([1, :sent])
  end

  def run_in_parallel(registers, instructions) do
    cond do 
      registers[:halted] -> registers
      true -> advance_program(registers, instructions, 0) |> advance_program(instructions, 1) |> run_in_parallel(instructions)
    end
  end

  defp advance_program(registers, instructions, p) do
    cond do
      registers[p][:halted] && registers[program(p+1)][:halted] -> Map.put(registers, :halted, true)
      registers[p][:ip] >= length(instructions) -> put_in(registers, [p, :halted], true)
      true -> execute_in_2(registers, Enum.at(instructions, registers[p][:ip]), p)
    end
  end

  defp init() do
    %{0 => %{ip: 0, queue: [], sent: 0}, 1 => %{ip: 0, queue: [], sent: 0}}
    |> put_in([0, "p"], 0)
    |> put_in([1, "p"], 1)
  end

  defp run_until_recover(instructions), do: run_until_recover(%{ip: 0, queue: []}, instructions)
  
  defp run_until_recover(registers, instructions) do
    cond do 
      registers[:halted] -> List.first(registers[:queue])
      registers[:ip] >= length(instructions) -> List.first(registers[:queue])
      true -> execute(registers, Enum.at(instructions, registers[:ip])) |> run_until_recover(instructions)      
    end
  end

  # snd X plays a sound with a frequency equal to the value of X.
  defp execute(registers, ["snd", x]) do
    Map.put(registers, :queue, [value(registers, x)] ++ registers[:queue])
    |> Map.put(:ip, registers[:ip] + 1)
  end
  # set X Y sets register X to the value of Y.
  defp execute(registers, ["set", x, y]) do
    Map.put(registers, x, value(registers, y))
    |> Map.put(:ip, registers[:ip] + 1)
  end
  # add X Y increases register X by the value of Y.
  defp execute(registers, ["add", x, y]) do
    Map.put(registers, x, value(registers, x) + value(registers, y))
    |> Map.put(:ip, registers[:ip] + 1)
  end
  # mul X Y sets register X to the result of multiplying the value contained in register X by the value of Y.
  defp execute(registers, ["mul", x, y]) do
    Map.put(registers, x, value(registers, x) * value(registers, y))
    |> Map.put(:ip, registers[:ip] + 1)
  end
  # mod X Y sets X to the result of X modulo Y)
  defp execute(registers, ["mod", x, y]) do
    Map.put(registers, x, rem(value(registers, x), value(registers, y)))
    |> Map.put(:ip, registers[:ip] + 1)
  end
  # rcv X recovers the frequency of the last sound played, but only when the value of X is not zero.
  # If it is zero, the command does nothing.
  defp execute(registers, ["rcv", x]) do
    if value(registers, x) != 0 do
      Map.put(registers, :halted, true)
    else
      Map.put(registers, :ip, registers[:ip] + 1)
    end
  end
  # jgz X Y jumps with an offset of the value of Y, but only if the value of X is greater than zero
  # An offset of 2 skips the next instruction, an offset of -1 jumps to the previous instruction, and so on.
  defp execute(registers, ["jgz", x, y]) do
    if value(registers, x) > 0 do
      Map.put(registers, :ip, registers[:ip] + value(registers, y))
    else
      Map.put(registers, :ip, registers[:ip] + 1)
    end
  end

  # snd X sends the value of X to the other program.
  # These values wait in a queue until that program is ready to receive them.
  # Each program has its own message queue, so a program can never receive a message it sent.
  def execute_in_2(registers, ["snd", x], p) do
    add_to_queue(registers, x, program(p+1))
    |> put_in([p, :sent], registers[p][:sent] + 1)
    |> put_in([p, :ip], registers[p][:ip] + 1)
  end

  # rcv X receives the next value and stores it in register X.
  # If no values are in the queue, the program waits for a value to be sent to it.
  # Programs do not continue to the next instruction until they have received a value.
  # Values are received in the order they are sent.
  def execute_in_2(registers, ["rcv", x], p) do
    case registers[p][:queue] do
      [] -> put_in(registers, [p, :halted], true)
      [value|queue] -> put_in(registers, [p, :queue], queue) |> execute_in_2(["set", x, Integer.to_string(value)], p)
    end
  end

  def execute_in_2(registers, instruction, p) do
    Map.put(registers, p, execute(registers[p], instruction))
  end

  defp add_to_queue(registers, x, p) do
    put_in(registers, [p, :queue], registers[p][:queue] ++ [value(registers[program(p+1)], x)])
    |> put_in([p, :halted], false)
  end

  defp program(n) do
    rem(n, 2)
  end

  defp value(registers, x) do
    if String.match?(x, ~r/[a-z]/) do
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


Duet.recover("./inputs/input18.txt") |> IO.puts

# --- Part Two ---

Duet.run_in_parallel("./inputs/input18.txt") |> IO.puts
