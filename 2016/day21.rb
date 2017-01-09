# --- Day 21: Scrambled Letters and Hash ---

# --- Part One ---

def swap(input, x, y)
  swapped = input.dup
  swapped[x] = input[y]
  swapped[y] = input[x]
  swapped
end

def rotate(input, direction, steps)
  steps = steps % input.size
  if direction == 'right'
    steps = -1 * steps
  end

  input.rotate(steps)
end

def scramble(input, instruction)
  # - swap position X with position Y means that the letters at
  # indexes X and Y (counting from 0) should be swapped.
  case instruction
  when /swap position (\d+) with position (\d+)/
    swap(input, $1.to_i, $2.to_i)
  # - swap letter X with letter Y means that the letters X and Y should be swapped
  # (regardless of where they appear in the string).
  when /swap letter (\w) with letter (\w)/
    x = input.index($1)
    y = input.index($2)
    swap(input, x, y)
  # - rotate left/right X steps means that the whole string should be rotated;
  # for example, one right rotation would turn abcd into dabc.
  when /rotate (left|right) (\d+) step/
    rotate(input, $1, $2.to_i)
  # - rotate based on position of letter X means that the whole string should 
  # be rotated to the right based on the index of letter X (counting from 0)
  # as determined before this instruction does any rotations.
  # Once the index is determined, rotate the string to the right one time, 
  # plus a number of times equal to that index, plus one additional time if 
  # the index was at least 4.
  when /rotate based on position of letter (\w)/
    steps = input.index($1) + 1
    steps += 1 if steps > 4
    rotate(input, 'right', steps)
  # - reverse positions X through Y means that the span of letters at indexes X through Y 
  # (including the letters at X and Y) should be reversed in order.
  when /reverse positions (\d+) through (\d+)/
    x = $1.to_i
    y = $2.to_i
    input[0...x] + input[x..y].reverse + input[y+1..-1]
  # - move position X to position Y means that the letter which is at index X should be removed
  # from the string, then inserted such that it ends up at index Y.
  when /move position (\d+) to position (\d+)/
    s = input.dup
    x = s.delete_at($1.to_i)
    s.insert($2.to_i, x)
    s
  end
end

def password(input, instructions)
  input = input.chars
  instructions.each do |instruction|
    input = scramble(input, instruction)
  end
  input.join
end

instructions = File.readlines('input_day21.txt').map(&:strip)
puts password('abcdefgh', instructions)

# --- Part Two ---

def calculate_steps(input, x)
  target = input.index(x)
  steps = nil
  input.size.times do |i|
    steps = i + 1 + (i >= 4 ? 1 : 0)
    return steps if ((i + steps) % input.size) == target
  end
end

def unscramble(input, instruction)
  # - swap position X with position Y means that the letters at
  # indexes X and Y (counting from 0) should be swapped.
  case instruction
  when /swap position (\d+) with position (\d+)/
    swap(input, $2.to_i, $1.to_i)
  # - swap letter X with letter Y means that the letters X and Y should be swapped
  # (regardless of where they appear in the string).
  when /swap letter (\w) with letter (\w)/
    x = input.index($1)
    y = input.index($2)
    swap(input, y, x)
  # - rotate left/right X steps means that the whole string should be rotated;
  # for example, one right rotation would turn abcd into dabc.
  when /rotate (left|right) (\d+) step/
    direction = ($1 == 'right') ? 'left' : 'right'
    rotate(input, direction, $2.to_i)
  # - rotate based on position of letter X means that the whole string should 
  # be rotated to the right based on the index of letter X (counting from 0)
  # as determined before this instruction does any rotations.
  # Once the index is determined, rotate the string to the right one time, 
  # plus a number of times equal to that index, plus one additional time if 
  # the index was at least 4.
  when /rotate based on position of letter (\w)/
    steps = calculate_steps(input, $1)
    rotate(input, 'left', steps)
  # - reverse positions X through Y means that the span of letters at indexes X through Y 
  # (including the letters at X and Y) should be reversed in order.
  when /reverse positions (\d+) through (\d+)/
    x = $1.to_i
    y = $2.to_i
    input[0...x] + input[x..y].reverse + input[y+1..-1]
  # - move position X to position Y means that the letter which is at index X should be removed
  # from the string, then inserted such that it ends up at index Y.
  when /move position (\d+) to position (\d+)/
    s = input.dup
    y = s.delete_at($2.to_i)
    s.insert($1.to_i, y)
    s
  end
end

def original(scrambled, instructions)
  scrambled = scrambled.chars
  instructions.reverse.each do |instruction|
    scrambled = unscramble(scrambled, instruction)
  end

  scrambled.join
end

puts original('fbgdceah', instructions)
