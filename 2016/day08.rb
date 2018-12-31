# --- Day 8: Two-Factor Authentication ---

# --- Part One ---

COLS = 50
ROWS = 6

# COLS = 7
# ROWS = 3

def process(instruction, screen)
  if instruction =~ /rect (\d+)x(\d+)/
    a = $1.to_i
    b = $2.to_i
    b.times do |i|
      a.times do |j|
        screen[i][j] = '#'
      end
    end
  elsif instruction =~ /rotate row y=(\d+) by (\d+)/
    a = $1.to_i
    b = $2.to_i
    rotated = screen[a].dup
    screen[a].each_with_index do |p, i|
      rotated[(i+b)% COLS] = p
    end
    screen[a] = rotated
  elsif instruction =~ /rotate column x=(\d+) by (\d+)/
    a = $1.to_i
    b = $2.to_i

    rotated = screen.map { |r| r[a] }
    ROWS.times do |i|
      p = screen[i][a]
      rotated[(i+b)%ROWS] = p
    end

    rotated.each_with_index do |p, i|
      screen[i][a] = p
    end
  end

  screen
end

screen = []
ROWS.times do
  screen << ['.']*COLS
end

instructions = File.readlines('inputs/input08.txt').map(&:strip)

# instructions = ['rect 3x2', 'rotate column x=1 by 1', 'rotate row y=0 by 4', 'rotate column x=1 by 1']

instructions.each do |instruction|
  screen = process(instruction, screen)
end

puts screen.map(&:join).join("\n")
puts screen.flatten.count('#')

# --- Part Two ---

puts screen.map(&:join).join("\n")



