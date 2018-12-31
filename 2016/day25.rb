# --- Day 25: Clock Signal ---

# --- Part One ---
require 'byebug'
def optimise(code)
  # Convert loops in multiplications
  # cpy something <reg2>
  # inc <reg1>
  # dec/inc <reg2>
  # jnz <reg2> -2
  # dec/inc <reg3>
  # jnz <reg3> -5
  # This is add <reg1> <reg2>*<reg3>

  to_optimise = code.select { |inst| inst =~ /jnz [a-d] -5/ }
  to_optimise.each do |jump|
    i = code.index(jump)
    jump =~ /jnz ([a-d]) -5/
    reg3 = $1.to_sym
    next unless i - 5 >= 0
    next unless code[i-1] =~ /(dec|inc) #{reg3}/ && code[i-2] =~ /jnz ([a-d]) -2/
    reg2 = $1.to_sym
    next unless code[i-3] =~ /(dec|inc) #{reg2}/ && code[i-4] =~ /inc ([a-d])/
    reg1 = $1.to_sym
    next unless code[i-5] =~ /cpy [^\s]+ #{reg2}/
    code = code[0..i-5] + ["multadd #{reg1} #{reg2} #{reg3}"] + ['skip']*4 + code[i+1..-1]
  end

  code
end

def value(operand, registers)
  'abcd'.include?(operand) ? registers[operand.to_sym] : operand.to_i
end

def process_instruction(instruction, pointer, registers, output)
  # debugger if pointer >= 20
  case instruction
  when /cpy ([a-d]|(-?\d+)) ([a-d])/
    registers[$3.to_sym] = value($1, registers)
    pointer = pointer + 1
  when /(inc|dec) ([a-d])/
    change = $1 == 'inc' ? 1 : -1
    registers[$2.to_sym] += change
    pointer = pointer + 1
  when /jnz ([a-d]|-?\d+) ([a-d]|-?\d+)/
    check = value($1, registers)
    steps = value($2, registers)
    pointer = check != 0 ? pointer + steps : pointer + 1
  when /multadd ([a-d]) ([a-d]) ([a-d])/
    registers[$1.to_sym] += registers[$2.to_sym]*registers[$3.to_sym]
    registers[$2.to_sym] = 0
    registers[$3.to_sym] = 0
    pointer = pointer + 1
  when /out ([a-d])/
    value = registers[$1.to_sym]
    puts "Output: #{value}"
    if output.last.nil? && value == 0 || !output.last.nil? && value != output.last.last
      return :success if output.count > 10000
      output << [registers, value]
    else
      return :error
    end
    pointer = pointer + 1
  else
    # Invalid instruction: skip
    pointer = pointer + 1
  end

  pointer
end

def execute(code, registers)
  i = 0
  output = []
  while i < code.count
    i = process_instruction(code[i], i, registers, output)
    return i if i == :error || i == :success
  end
end

code = File.readlines('inputs/input25.txt').map(&:strip)
code = optimise(code)

result = :error
a = 1
while result != :success
  result = execute(code, { a: a, b: 0, c: 0, d: 0 })
  puts "Got #{result} for a=#{a}"
  a += 1
end
