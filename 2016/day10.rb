# --- Day 10: Balance Bots ---

# --- Part One ---

def init_game(init)
  bots = {}
  init.each do |i|
    next unless i =~ /value (\d+) goes to bot (\d+)/
    value = $1.to_i
    bot = "bot #{$2}"
    bots[bot] ||= []
    bots[bot] << value
  end

  bots
end

def assign_instructions(instructions)
  assigned = {}

  instructions.each do |instruction|
    next unless instruction =~ /(bot \d+) gives low to (bot \d+|output \d+) and high to (bot \d+|output \d+)/
    bot = $1
    low = $2
    high = $3
    assigned[bot] = [low, high]
  end

  assigned
end

def play_round(bots, outputs, instructions)
  # Look for bots with 2 chips, and process them
  playing = bots.select { |b, values| values.count == 2}
  playing.each do |bot, values|
    values.sort!
    next unless instructions[bot]
    low, high = instructions[bot]
    if low.start_with? 'bot'
      bots[low] ||= []
      bots[low] << values[0]
    else
      outputs[low] ||= []
      outputs[low] << values[0]
    end

    if high.start_with? 'bot'
      bots[high] ||= []
      bots[high] << values[1]
    else
      outputs[high] ||= []
      outputs[high] << values[1]
    end

    bots[bot] = []
  end
end

def go!(bots, instructions, magic_pair = [17, 61])
  # Check if some bot have the magic pair, and if it has, return
  winner = bots.detect { |b, values| values.sort == magic_pair }
  return winner.first if winner

  play_round(bots, {}, instructions)

  go!(bots, instructions, magic_pair)
end

instructions = File.readlines('input_day10.txt').map(&:strip)

init = instructions.select { |ins| ins.start_with? 'value' }
bots = init_game(init)
instructions = assign_instructions(instructions - init)
puts go!(bots, instructions)

# --- Part Two ---

def output!(bots, outputs, instructions)
  while bots.detect { |_, values| values.count == 2 }
    play_round(bots, outputs, instructions)
  end
end

outputs = {}
output!(bots, outputs, instructions)

puts %w(0 1 2).inject(1) { |acc, o| acc * outputs["output #{o}"].first.to_i }
