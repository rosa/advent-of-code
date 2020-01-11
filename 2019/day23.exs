# --- Day 23: Category Six ---

defmodule Network do
  defstruct(
    computers: %{},
    queues: %{},
    nat: []
  )

  def new(filename) do
    nic_program = File.read!(filename)
    %Network{computers: init_computers(nic_program), queues: init_queues()}
  end

  def run(network, mode \\ :send_and_receive), do: assign_addresses(network) |> run(0, mode, [])
  def run(network, 50, mode = :nat, resumes) do
    if !Enum.empty?(network.nat) and idle?(network) do
      resume(network, resumes)
    else
      run(network, 0, mode, resumes)
    end
  end

  def run(network, 50, mode, resumes), do: run(network, 0, mode, resumes)
  def run(network, addr, mode, resumes) do
    if !Enum.empty?(network.nat) and mode == :send_and_receive do
      network.nat
    else
      {inputs, network_received} = receive_packets(network, addr)
      {assigned, outputs, _} = Program.run(network.computers[addr], inputs)
      network_sent = send_packets(network_received, outputs)
      %{network_sent | computers: Map.put(network.computers, addr, assigned)}
      |> run(addr + 1, mode, resumes)
    end
  end

  defp init_computers(nic_program), do: Enum.map(0..49, fn addr -> {addr, Program.new(nic_program)} end) |> Map.new
  defp init_queues, do: Enum.map(0..49, fn addr -> {addr, []} end) |> Map.new

  defp assign_addresses(network), do: assign_addresses(network, 0)
  defp assign_addresses(network, 50), do: network
  defp assign_addresses(network, i) do
    {assigned, outputs, _} = Program.run(network.computers[i], [i])
    network_sent = send_packets(network, outputs)
    %{network_sent | computers: Map.put(network.computers, i, assigned)}
    |> assign_addresses(i + 1)
  end

  defp send_packets(network, []), do: network
  defp send_packets(network, [255, x, y | rest]), do: send_packets(%{network | nat: [x, y]}, rest)
  defp send_packets(network, [addr, x, y | rest]) do
    queues = Map.put(network.queues, addr, Map.get(network.queues, addr, []) ++ [x, y])
    send_packets(%{network | queues: queues}, rest)
  end

  defp receive_packets(network, addr) do
    if Enum.empty?(network.queues[addr]) do
      {[-1], network}
    else
      {Enum.take(network.queues[addr], 2), %{network | queues: Map.put(network.queues, addr, Enum.drop(network.queues[addr], 2))}}
    end
  end

  defp resume(%{nat: [_, y]}, [y|_]), do: y
  defp resume(network = %{nat: [x, y]}, resumes), do: send_packets(network, [0, x, y]) |> run(0, :nat, [y | resumes])

  defp idle?(network), do: network.queues |> Map.values |> Enum.all?(&Enum.empty?/1)
end

defmodule Program do
  alias Program.Instruction

  defstruct(
    memory: %{},
    ip: 0,
    relative_base: 0
  )

  def new(intcodes) do
    %Program{memory: parse_intcodes(intcodes)}
  end

  def run(program, inputs), do: run(program, inputs, next_instruction(program), [])
  def run(program, inputs, instruction, outputs) do
    cond do
      Instruction.halt?(instruction) -> {program, outputs, :halted}
      Instruction.input?(instruction) and Enum.empty?(inputs) -> {program, outputs, :waiting_for_input}
      true -> apply(Program, :run, execute(program, inputs, instruction, outputs))
    end
  end

  defp execute(program, inputs, instruction, outputs) do
    values = parameter_values(program, instruction)
    input = if Enum.empty?(inputs), do: 0, else: hd(inputs)
    output = Instruction.execute(instruction, values, input)
    updated_program = %{program |
      memory: store(program, instruction, output),
      ip: Instruction.next_ip(instruction, values, program.ip),
      relative_base: Instruction.next_relative_base(instruction, values, program.relative_base)}
    cond do
      Instruction.input?(instruction) -> [updated_program, tl(inputs), next_instruction(updated_program), outputs]
      Instruction.output?(instruction) -> [updated_program, inputs, next_instruction(updated_program), outputs ++ [output]]
      true -> [updated_program, inputs, next_instruction(updated_program), outputs]
    end
  end

  defp store(program, instruction, value) do
    position = Instruction.position_to_store(instruction, program.relative_base)
    if position > 0 do
      Map.put(program.memory, position, value)
    else
      program.memory
    end
  end

  defp next_instruction(program), do: Instruction.new(next_opcode(program), next_parameters(program))

  defp next_parameters(program) do
    count = next_opcode(program) |> rem(100) |> Instruction.count_parameters
    Enum.map(program.ip + 1..program.ip + count, &(Map.get(program.memory, &1, 0)))
  end

  defp next_opcode(program), do: Map.get(program.memory, program.ip, 0)

  defp parameter_values(program, instruction) do
    Enum.map(0..Enum.count(instruction.parameters) - 1, fn i -> parameter_value(program, instruction, i) end)
  end

  # parameter mode 0, position mode, which causes the parameter to be interpreted as a position
  # parameter mode 1, immediate mode. In immediate mode, a parameter is interpreted as a value
  # parameter mode 2, relative mode, like position but from the relative base
  defp parameter_value(program, instruction, i) do
    case Enum.at(instruction.modes, i) do
      0 -> Map.get(program.memory, Enum.at(instruction.parameters, i), 0)
      1 -> Enum.at(instruction.parameters, i)
      2 -> Map.get(program.memory, program.relative_base + Enum.at(instruction.parameters, i), 0)
    end
  end

  defp parse_intcodes(intcodes) do
    opcodes = String.trim(intcodes)
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)

    Enum.zip(0..Enum.count(opcodes)-1, opcodes)
    |> Map.new
  end
end

defmodule Program.Instruction do
  defstruct(
    operation: nil,
    parameters: [],
    modes: []
  )

  def new(opcode, parameters) do
    %Program.Instruction{
      operation: rem(opcode, 100),
      parameters: parameters,
      modes: get_modes(opcode, parameters)
    }
  end

  def count_parameters(operation) when operation in [1, 2, 7, 8], do: 3
  def count_parameters(operation) when operation in [3, 4, 9], do: 1
  def count_parameters(operation) when operation in [5, 6], do: 2
  def count_parameters(_), do: 0

  def halt?(instruction), do: instruction.operation == 99
  def output?(instruction), do: instruction.operation == 4
  def input?(instruction), do: instruction.operation == 3

  def execute(%Program.Instruction{operation: operation}, values, input), do: execute(operation, values, input)
  # Opcode 1 adds together numbers
  def execute(1, [x, y, _], _), do: x + y
  # Opcode 2 multiples together numbers
  def execute(2, [x, y, _], _), do: x * y
  # Opcode 3 takes a single integer as input and saves it to the position given by its only parameter
  def execute(3, _, input), do: input
  # Opcode 4 outputs the value of its only parameter.
  def execute(4, [x], _), do: x
  # Opcode 7 is less than: if the first parameter is less than the second parameter, it stores 1 in the position given by the third parameter. Otherwise, it stores 0.
  def execute(7, [x, y, _], _), do: if x < y, do: 1, else: 0
  # Opcode 8 is equals: if the first parameter is equal to the second parameter, it stores 1 in the position given by the third parameter. Otherwise, it stores 0.
  def execute(8, [x, y, _], _), do: if x == y, do: 1, else: 0
  def execute(_, _, _), do: 0

  def position_to_store(%Program.Instruction{operation: operation, parameters: parameters, modes: modes}, relative_base) do
    position_to_store(operation, parameters, modes, relative_base)
  end
  def position_to_store(operation, [_, _, z], [_, _, mz], relative_base) when operation in [1, 2, 7, 8], do: if mz == 2, do: relative_base + z, else: z
  def position_to_store(3, [x], [mx], relative_base), do: if mx == 2, do: relative_base + x, else: x
  def position_to_store(_, _, _, _), do: -1

  # Opcode 5 is jump-if-true: if the first parameter is non-zero,
  # it sets the instruction pointer to the value from the second parameter
  # Opcode 6 is jump-if-false: if the first parameter is zero,
  # it sets the instruction pointer to the value from the second parameter
  def next_ip(instruction, values, ip) do
    cond do
      instruction.operation == 5 and Enum.at(values, 0) != 0 -> Enum.at(values, 1)
      instruction.operation == 6 and Enum.at(values, 0) == 0 -> Enum.at(values, 1)
      true -> ip + Enum.count(instruction.parameters) + 1
    end
  end

  def next_relative_base(%Program.Instruction{operation: 9}, values, relative_base), do: relative_base + Enum.at(values, 0)
  def next_relative_base(_, _, relative_base), do: relative_base

  defp get_modes(opcode, parameters), do: Enum.map(0..Enum.count(parameters) - 1, fn i -> div(opcode, round(:math.pow(10, i+2))) |> rem(10) end)
end

# --- Part One ---
Network.new("inputs/input23.txt")
|> Network.run()
|> IO.inspect()

# [60397, 23701]

# --- Part Two ---
Network.new("inputs/input23.txt")
|> Network.run(:nat)
|> IO.inspect()

# 17225
