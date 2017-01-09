grid = %w(R2 L3 R2 R4 L2 L1 R2 R4 R1 L4 L5 R5 R5 R2 R2 R1 L2 L3 L2 L1 R3 L5 R187 R1 R4 L1 R5 L3 L4 R50 L4 R2 R70 L3 L2 R4 R3 R194 L3 L4 L4 L3 L4 R4 R5 L1 L5 L4
          R1 L2 R4 L5 L3 R4 L5 L5 R5 R3 R5 L2 L4 R4 L1 R3 R1 L1 L2 R2 R2 L3 R3 R2 R5 R2 R5 L3 R2 L5 R1 R2 R2 L4 L5 L1 L4 R4 R3 R1 R2 L1 L2 R4 R5 L2 R3 L4 L5 L5
          L4 R4 L2 R1 R1 L2 L3 L2 R2 L4 R3 R2 L1 L3 L2 L4 L4 R2 L3 L3 R2 L4 L3 R4 R3 L2 L1 L4 R4 R2 L4 L4 L5 L1 R2 L5 L2 L3 R2 L2)

# --- Part One ---

def next_operation(operation, direction)
  case operation    
  when [0, 1] # North
    direction == 'R' ? [1, 0] : [-1, 0]
  when [0, -1] # South
    direction == 'R' ? [-1, 0] : [1, 0]
  when [-1, 0] # West
    direction == 'R' ? [0, 1] : [0, -1]
  when [1, 0] # East
    direction == 'R' ? [0, -1] : [0, 1]
  end
end

def blocks_away_part_1(grid)
  position = [0, 0]
  operation = [0, 1] # Facing north

  grid.each do |move|
    direction = move[0]
    steps = move[1..-1].to_i
    operation = next_operation(operation, direction)
    position = [position[0] + operation[0]*steps, position[1] + operation[1]*steps]
  end

  position.map(&:abs).reduce(&:+)
end


puts blocks_away_part_1(grid)

# --- Part Two ---

def blocks_away_part_2(grid)
  position = [0, 0]
  operation = [0, 1] # Facing north
  positions = []

  grid.each do |move|
    direction = move[0]
    steps = move[1..-1].to_i
    operation = next_operation(operation, direction)
    steps.times do
      position = [position[0] + operation[0], position[1] + operation[1]]
      return position.map(&:abs).reduce(&:+) if positions.include?(position)
      positions << position
    end
  end

  position.map(&:abs).reduce(&:+)
end

puts blocks_away_part_2(grid)