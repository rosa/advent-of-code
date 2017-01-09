# --- Day 18: Like a Rogue ---

# --- Part One ---

def next_row(row)
  tiles = row.chars
  next_row = []
  # A new tile is a trap only in one of the following situations:
  #  - Its left and center tiles are traps, but its right tile is not.
  #  - Its center and right tiles are traps, but its left tile is not.
  #  - Only its left tile is a trap.
  #  - Only its right tile is a trap.
  tiles.count.times do |i|
    if i > 0 && tiles[i-1] == '^' && tiles[i] == '^' && (i == tiles.count - 1 || tiles[i+1] == '.')
      next_row << '^'
    elsif i < tiles.count - 1 && tiles[i+1] == '^' && tiles[i] == '^' && (i == 0 || tiles[i-1] == '.')
      next_row << '^'
    elsif i > 0 && tiles[i-1] == '^' && tiles[i] == '.' && (i == tiles.count - 1 || tiles[i+1] == '.')
      next_row << '^'
    elsif i < tiles.count - 1 && tiles[i+1] == '^' && tiles[i] == '.' && (i == 0 || tiles[i-1] == '.')
      next_row << '^'
    else
      next_row << '.'
    end
  end

  next_row.join
end

def complete_room(start, size)
  room = []
  size.times do
    room << start
    start = next_row(start)
  end

  room
end

start = '.^^..^...^..^^.^^^.^^^.^^^^^^.^.^^^^.^^.^^^^^^.^...^......^...^^^..^^^.....^^^^^^^^^....^^...^^^^..^'

room = complete_room(start, 40)
puts room.join.chars.count('.')

# --- Part Two ---

room = complete_room(start, 400000)
puts room.join.chars.count('.')


