# --- Day 12: Leonardo's Monorail ---

# --- Part One ---

code = %(cpy 1 a
        cpy 1 b
        cpy 26 d
        jnz c 2
        jnz 1 5
        cpy 7 c
        inc d
        dec c
        jnz c -2
        cpy a c
        inc a
        dec b
        jnz b -2
        cpy c b
        dec d
        jnz d -6
        cpy 14 c
        cpy 14 d
        inc a
        dec d
        jnz d -2
        dec c
        jnz c -5).split("\n").map(&:strip)

def process_instruction(instruction, pointer, registers)
  case instruction
  when /cpy (\d+) ([a-d])/
    registers[$2.to_sym] = $1.to_i
    pointer = pointer + 1
  when /cpy ([a-d]) ([a-d])/
    registers[$2.to_sym] = registers[$1.to_sym]
    pointer = pointer + 1
  when /(inc|dec) ([a-d])/
    change = $1 == 'inc' ? 1 : -1
    registers[$2.to_sym] += change
    pointer = pointer + 1
  when /jnz ([a-d]) (-?\d+)/
    pointer = registers[$1.to_sym] != 0 ? pointer + $2.to_i : pointer + 1
  when /jnz (\d+) (-?\d+)/
    pointer = $1.to_i != 0 ? pointer + $2.to_i : pointer + 1
  end

  pointer
end

def execute(code, registers)
  i = 0
  while i < code.count
    i = process_instruction(code[i], i, registers)
  end

  registers[:a]
end

puts execute(code, { a: 0, b: 0, c: 0, d: 0})


# --- Part Two ---

puts execute(code, { a: 0, b: 0, c: 1, d: 0})
