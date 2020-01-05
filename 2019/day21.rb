# --- Day 21: Springdroid Adventure ---

class Springdroid
  attr_accessor :program

  def initialize(intcodes)
    @program = Program.new(intcodes)
  end

  def wait_for_input
    while !program.waiting_for_input? do
      program.run
    end
    puts program.outputs.map(&:chr).join("")
  end

  def feed(instructions)
    program.outputs.clear
    instructions.map { |instruction| instruction.bytes + [10] }.tap do |inputs|
      program.inputs = inputs.flatten
    end

    program.run
    puts program.outputs.map { |output| output < 256 ? output.chr : output }.join("")
  end
end

class Program
  attr_accessor :memory, :ip, :relative_base
  attr_reader :inputs, :outputs

  def initialize(intcodes)
    @memory = intcodes.split(",").map(&:to_i) + [0]*1000
    @ip = @relative_base = 0
    @halted = @waiting_for_input = false
    @inputs = []
    @outputs = []
  end

  def inputs=(inputs)
    @waiting_for_input = false
    @inputs = inputs
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

      output = execute(instruction, input)
      outputs << output if instruction.output?
    end
  end

  def halted?
    @halted
  end

  def waiting_for_input?
    @waiting_for_input
  end

  def to_s
    "#{memory[0..100]}, ip = #{ip}, relative_base = #{relative_base}"
  end

  private
    def execute(instruction, input)
      params = parameter_values(instruction)
      output = instruction.execute(params, input)
      self.relative_base = instruction.next_relative_base(params, relative_base)
      self.ip = instruction.next_ip(params, ip)

      position = instruction.position_to_store(relative_base)
      if position >= 0
        memory[position] = output
      end

      output
    end

    def next_instruction
      Instruction.new(next_parameters, memory[ip])
    end

    def next_parameters
      count = Instruction.count_parameters(memory[ip])
      memory[(ip + 1)...(ip + 1 + count)]
    end

    # parameter mode 0, position mode, which causes the parameter to be interpreted as a position
    # parameter mode 1, immediate mode. In immediate mode, a parameter is interpreted as a value
    # parameter mode 2, relative mode, like position but from the relative base
    def parameter_values(instruction)
      (0...instruction.parameters.size).map do |i|
        case instruction.modes[i]
        when 0 then memory[instruction.parameters[i]]
        when 1 then instruction.parameters[i]
        when 2 then memory[relative_base + instruction.parameters[i]]
        else        0
        end
      end
    end
end

class Instruction
  attr_accessor :operation, :parameters, :modes

  def self.count_parameters(opcode)
    case opcode % 100
    when 1, 2, 7, 8 then 3
    when 3, 4, 9    then 1
    when 5, 6       then 2
    else                 0
    end
  end

  def initialize(parameters, opcode)
    @parameters = parameters
    @operation = opcode % 100
    @modes = []
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
  def execute(parameter_values, input)
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
  def next_ip(parameter_values, ip)
    if operation == 5 && parameter_values[0] != 0
      parameter_values[1]
    elsif operation == 6 && parameter_values[0] == 0
      parameter_values[1]
    else
      ip + parameters.size + 1
    end
  end

  def next_relative_base(parameter_values, relative_base)
    operation == 9 ? relative_base + parameter_values[0] : relative_base
  end

  def position_to_store(relative_base)
    case operation
    when 1, 2, 7, 8 then (modes[2] == 2) ? relative_base + parameters[2] : parameters[2]
    when 3          then (modes[0] == 2) ? relative_base + parameters[0] : parameters[0]
    else                 -1
    end
  end

  def to_s
    "(#{operation}, (#{parameters.join(',')}), (#{modes.join(',')})"
  end
end

# --- Part One ---
intcodes = File.read("inputs/input21.txt")
springdroid = Springdroid.new(intcodes)
springdroid.wait_for_input
# Input instructions:
# Test with OR D J
# Walking...

# Didn't make it across:

# .................
# .................
# @................
# #####.#..########

# .................
# .@...............
# .................
# #####.#..########

# ..@..............
# .................
# .................
# #####.#..########

# .................
# ...@.............
# .................
# #####.#..########

# .................
# .................
# ....@............
# #####.#..########

# .................
# .................
# .................
# #####@#..########

# Real instructions
# Jump if there's no ground either 1, 2 or 3 tiles away and there's ground 4 tiles away
instructions = ["NOT A J",
  "NOT B T",
  "OR T J",
  "NOT C T",
  "OR T J",
  "AND D J",
  "WALK"]
springdroid.feed(instructions)
# Input instructions:

# Walking...

# 19357544

# --- Part Two ---
# Trying with same instructions as part one:
# Input instructions:

# Running...


# Didn't make it across:

# .................
# .................
# @................
# #####.#..########

# .................
# .................
# .@...............
# #####.#..########

# .................
# .................
# ..@..............
# #####.#..########

# .................
# .................
# ...@.............
# #####.#..########

# .................
# .................
# ....@............
# #####.#..########

# .................
# .................
# .................
# #####@#..########

# Jump if there's no ground either 1, 2 or 3 tiles away and there's ground 4 tiles away, but
# not if there's no ground 8 tiles away or 5 tiles away (so the springdroid can walk or jump right
# after landing).
springdroid = Springdroid.new(intcodes)
springdroid.wait_for_input

instructions = ["NOT A J",
  "NOT B T",
  "OR T J",
  "NOT C T",
  "OR T J",
  "AND D J",
  "NOT H T",
  "NOT T T",
  "OR E T",
  "AND T J",
  "RUN"]
springdroid.feed(instructions)
# Input instructions:

# Running...

# 1144498646
