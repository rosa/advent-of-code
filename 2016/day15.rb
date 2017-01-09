# --- Day 15: Timing is Everything ---

# --- Part One ---

instructions = ["Disc #1 has 17 positions; at time=0, it is at position 15.",
                "Disc #2 has 3 positions; at time=0, it is at position 2.",
                "Disc #3 has 19 positions; at time=0, it is at position 4.",
                "Disc #4 has 13 positions; at time=0, it is at position 2.",
                "Disc #5 has 7 positions; at time=0, it is at position 2.",
                "Disc #6 has 5 positions; at time=0, it is at position 0."]

def valid?(multipliers, offsets, i)
  multipliers.each_with_index do |m, j|
    if (offsets[j] + i) % m != 0
      return false
    end
  end

  true
end

def time(instructions)
  multipliers = []
  offsets = []
  i = 1
  instructions.each do |instruction|
    instruction =~ /has (\d+) positions; at time=0, it is at position (\d+)./
    multipliers << $1.to_i
    offsets << ($2.to_i + i) % $1.to_i
    i += 1
  end

  factor = multipliers.max
  i = factor - offsets[multipliers.index(factor)]

  while !valid?(multipliers, offsets, i)
    i += factor
  end

  i
end

puts time(instructions)

# --- Part Two ---

instructions << "Disc #7 has 11 positions; at time=0, it is at position 0."
puts time(instructions)