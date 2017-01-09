# --- Day 17: Two Steps Forward ---

require 'digest/md5'

# --- Part One ---

def next_steps(string)
  h = Digest::MD5.hexdigest(string).chars[0...4]
  # up, down, left, and right
  h.map { |c| ('b'..'f').include?(c) }
end

def children(i, j, current_path)
  children = []
  steps = next_steps(current_path)
  # up
  children << [i-1, j, 'U'] if i-1 >= 0 && steps[0]
  # down
  children << [i+1, j, 'D'] if i+1 < 4 && steps[1]
  # left
  children << [i, j-1, 'L'] if j-1 >= 0 && steps[2]
  # right
  children << [i, j+1, 'R'] if j+1 < 4 && steps[3]

  children
end

def shortest_path(i, j, current_path)
  return current_path if i == 3 && j == 3

  children = children(i, j, current_path)
  return nil unless children.any?

  path = nil
  children.each do |child|
    child_path = shortest_path(child[0], child[1], current_path + child[2])
    path = child_path if child_path && (path.nil? || path.size > child_path.size)
  end

  path
end

passcode = 'qzthpkfp'
puts shortest_path(0, 0, passcode).gsub(passcode, '')

# --- Part Two ---

def longest_path(i, j, current_path)
  return current_path if i == 3 && j == 3

  children = children(i, j, current_path)
  return nil unless children.any?

  path = nil
  children.each do |child|
    child_path = longest_path(child[0], child[1], current_path + child[2])
    path = child_path if child_path && (path.nil? || path.size < child_path.size)
  end

  path
end

puts longest_path(0, 0, passcode).gsub(passcode, '').size