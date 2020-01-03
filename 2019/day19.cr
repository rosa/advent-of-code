# --- Day 19: Tractor Beam ---

class DroneSystem
  getter intcodes : String
  getter program : Program

  def initialize(intcodes : String)
    @intcodes = intcodes
    @program = Program.new(intcodes)
  end

  def discover_beam_shape
    outputs = [[] of Int64]

    (0...50).each do |i|
      outputs << [] of Int64
      (0...50).each do |j|
        outputs[i] << send_probe(i, j)
      end
    end

    outputs
  end

  def find_100x100_square
    i = j = 0
    while send_probe(i + 99, j) != 1
      j += 1
      while send_probe(i, j + 99) != 1
        i += 1
      end
    end

    [i, j]
  end

  private def send_probe(i : Int, j : Int)
    reset
    program.inputs = [i, j]
    program.run
    program.outputs.last
  end

  private def reset
    @program = Program.new(intcodes)
  end
end

class Program
  getter memory : Array(Int64)
  getter ip : Int64
  getter relative_base : Int64

  getter inputs : Array(Int64)
  getter outputs : Array(Int64)

  def initialize(intcodes : String)
    @memory = intcodes.split(",").map(&.to_i64) + Array.new(1000, 0_i64)
    @ip = @relative_base = 0
    @halted = @waiting_for_input = false
    @inputs = [] of Int64
    @outputs = [] of Int64
  end

  def inputs=(inputs)
    @waiting_for_input = false
    @inputs = inputs.map(&.to_i64)
  end

  def run
    input = 0

    while true
      instruction = next_instruction
      if instruction.halt?
        @halted = true
        break
      end

      if instruction.input? && inputs.empty?
        @waiting_for_input = true
        break
      elsif instruction.input?
        input = inputs.shift
      end

      output = execute(instruction, input.to_i64)
      outputs << output if instruction.output?
    end
  end

  def halted?
    @halted
  end

  def waiting_for_input?
    @waiting_for_input
  end

  def to_s(io)
    io << "#{memory[0..100]}, ip = #{ip}, relative_base = #{relative_base}"
  end

  private def execute(instruction, input)
    params = parameter_values(instruction)
    output = instruction.execute(params, input).to_i64
    @relative_base = instruction.next_relative_base(params, relative_base)
    @ip = instruction.next_ip(params, ip)

    position = instruction.position_to_store(relative_base)
    if position >= 0
      memory[position.as(Int)] = output
    end

    output
  end

  private def next_instruction
    Instruction.new(next_parameters, memory[ip])
  end

  private def next_parameters
    count = Instruction.count_parameters(memory[ip])
    memory[(ip + 1)...(ip + 1 + count)]
  end

  # parameter mode 0, position mode, which causes the parameter to be interpreted as a position
  # parameter mode 1, immediate mode. In immediate mode, a parameter is interpreted as a value
  # parameter mode 2, relative mode, like position but from the relative base
  private def parameter_values(instruction : Instruction)
    (0...instruction.parameters.size).map do |i|
      case instruction.modes[i]
      when 0 then memory[instruction.parameters[i]]
      when 1 then instruction.parameters[i]
      when 2 then memory[relative_base + instruction.parameters[i]]
      else        0_i64
      end
    end
  end
end

class Instruction
  getter operation : Int64
  getter parameters : Array(Int64)
  getter modes : Array(Int32)

  def self.count_parameters(opcode)
    case opcode % 100
    when 1, 2, 7, 8 then 3
    when 3, 4, 9    then 1
    when 5, 6       then 2
    else                 0
    end
  end

  def initialize(@parameters, opcode)
    @operation = opcode % 100
    @modes = [] of Int32
    (0...parameters.size).each do |i|
      @modes << ((opcode / 10**(i + 2)).to_i % 10)
    end
  end

  def halt?
    operation == 99
  end

  def output?
    operation == 4
  end

  def input?
    operation == 3
  end

  # Opcode 1 adds together numbers
  # Opcode 2 multiples together numbers
  # Opcode 3 takes a single integer as input and saves it to the position given by its only parameter
  # Opcode 4 outputs the value of its only parameter.
  # Opcode 7 is less than: if the first parameter is less than the second parameter, it stores 1 in the position given by the third parameter. Otherwise, it stores 0.
  # Opcode 8 is equals: if the first parameter is equal to the second parameter, it stores 1 in the position given by the third parameter. Otherwise, it stores 0.
  def execute(parameter_values : Array(Int64), input : Int64)
    case operation
    when 1 then parameter_values[0] + parameter_values[1]
    when 2 then parameter_values[0] * parameter_values[1]
    when 3 then input
    when 4 then parameter_values[0]
    when 7 then (parameter_values[0] < parameter_values[1]) ? 1 : 0
    when 8 then (parameter_values[0] == parameter_values[1]) ? 1 : 0
    else        0
    end
  end

  # Opcode 5 is jump-if-true: if the first parameter is non-zero,
  # it sets the instruction pointer to the value from the second parameter
  # Opcode 6 is jump-if-false: if the first parameter is zero,
  # it sets the instruction pointer to the value from the second parameter
  def next_ip(parameter_values : Array(Int64), ip : Int64)
    if operation == 5 && parameter_values[0] != 0
      parameter_values[1]
    elsif operation == 6 && parameter_values[0] == 0
      parameter_values[1]
    else
      ip + parameters.size + 1
    end
  end

  def next_relative_base(parameter_values : Array(Int64), relative_base : Int64)
    operation == 9 ? relative_base + parameter_values[0] : relative_base
  end

  def position_to_store(relative_base : Int64)
    case operation
    when 1, 2, 7, 8 then (modes[2] == 2) ? relative_base + parameters[2] : parameters[2]
    when 3          then (modes[0] == 2) ? relative_base + parameters[0] : parameters[0]
    else                 -1
    end
  end

  def to_s(io)
    io << "(#{operation}, (#{parameters.join(',')}), (#{modes.join(',')})"
  end
end

intcodes = File.read("inputs/input19.txt")
drone_system = DroneSystem.new(intcodes)
# --- Part One ---
beam_shape = drone_system.discover_beam_shape
puts beam_shape.flatten.count(1)
beam_shape.each do |row|
  puts row.join("")
end

# --- Part Two ---
# What value do you get if you take that point's X coordinate, multiply it by 10000, then add the point's Y coordinate?
x, y = drone_system.find_100x100_square
puts 10000*x + y
