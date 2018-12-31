# --- Day 23: Safe Cracking ---

# --- Part One ---

# For one-argument instructions, inc becomes dec, and all other one-argument instructions become inc.
# For two-argument instructions, jnz becomes cpy, and all other two-instructions become jnz.
# The arguments of a toggled instruction are not affected.
def toggle(instruction)
  parts = instruction.split(' ')
  # One argument instruction
  if parts.count == 2
    parts[0] = parts[0] == 'inc' ? 'dec' : 'inc'
  elsif parts.count == 3
    parts[0] = parts[0] == 'jnz' ? 'cpy' : 'jnz'
  end

  parts.join(' ')
end

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

def process_instruction(instruction, pointer, registers, code)
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
  when /tgl ([a-d]|-?\d+)/
    x = value($1, registers)
    to_change = code[pointer + x] if (pointer + x) >= 0
    if to_change
      code[pointer + x] = toggle(to_change)
      code = optimise(code)
    end
    pointer = pointer + 1
  when /multadd ([a-d]) ([a-d]) ([a-d])/
    registers[$1.to_sym] += registers[$2.to_sym]*registers[$3.to_sym]
    registers[$2.to_sym] = 0
    registers[$3.to_sym] = 0
    pointer = pointer + 1
  else
    # Invalid instruction: skip
    pointer = pointer + 1
  end

  pointer
end

def execute(code, registers)
  i = 0
  while i < code.count
    i = process_instruction(code[i], i, registers, code)
  end

  registers[:a]
end

code = File.readlines('inputs/input23.txt').map(&:strip)
code = optimise(code)
puts execute(code, { a: 7, b: 0, c: 0, d: 0 })

# --- Part Two ---
code = File.readlines('inputs/input23.txt').map(&:strip)
code = optimise(code)
puts execute(code, { a: 12, b: 0, c: 0, d: 0 })

