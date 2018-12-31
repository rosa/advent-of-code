# --- Day 24: Air Duct Spelunking ---

# --- Part One ---

def open(value)
  value == '.'
end

def children(x, y, board)
  children = []

  children << [x+1, y] if x + 1 < board.first.count && open(board[y][x+1])
  children << [x-1, y] if x - 1 >= 0 && open(board[y][x-1])
  children << [x, y+1] if y + 1 < board.count && open(board[y+1][x])
  children << [x, y-1] if y - 1 >= 0 && open(board[y-1][x])

  children
end

def bfs(board, start)
  x, y = start
  board[y][x] = 0 # visited
  queue = [[x, y]]
  distance = 0
  while queue.size > 0 do
    v = queue.shift
    x, y = v
    distance = board[y][x]
    children(x, y, board).each do |u|
      ux, uy = u
      board[uy][ux] = distance + 1 # visited
      queue << [ux, uy]
    end
  end
end

def index(number, board)
  y = board.index { |l| l.include? number }
  x = board[y].index(number)
  [x, y]
end

def dup(board)
  dupped = []
  board.each do |row|
    dup_row = []
    row.each do |c|
      dup_row << c
    end
    dupped << dup_row
  end
  dupped
end

def len(order, distances)
  len = 0
  current = '0'
  order.each do |c|
    len += distances[[current, c].sort]
    current = c
  end
  len
end

board = File.readlines('inputs/input24.txt').map(&:strip).map(&:chars)

numbers = board.flatten.select { |d| d =~ /\d+/ }.sort
indexes = {}
# Replace all numbers with '.' and store the indexes
numbers.each do |n| 
  x, y = index(n, board)
  board[y][x] = '.'
  indexes[n] = [x, y]
end

distances = {}
0.upto(numbers.count - 2) do |i|
  a = numbers[i]
  aux_board = dup(board)
  bfs(aux_board, indexes[a])
  (i+1).upto(numbers.count - 1) do |j|
    b = numbers[j]
    target = indexes[b]
    distances[[a, b]] = aux_board[target[1]][target[0]]
  end
end

min_steps = board.count * board.first.count
min_order = nil
(numbers - ["0"]).permutation do |order|
  candidate = len(order, distances)
  if min_steps > candidate
    min_steps = candidate
    min_order = order
  end
end

puts min_steps
puts min_order.join(' ')

# --- Part Two ---

min_steps = board.count * board.first.count
min_order = nil
(numbers - ["0"]).permutation do |order|
  # Always go back to 0
  order << '0'
  candidate = len(order, distances)
  if min_steps > candidate
    min_steps = candidate
    min_order = order
  end
end

puts min_steps
puts min_order.join(' ')

