# --- Day 13: A Maze of Twisty Little Cubicles ---

# --- Part One ---

def print_board(board)
  puts board.map { |l| l.join }.join("\n")
end

def draw_board(favourite_number, size)
  board = []
  size.times do
    board << ['.']*size
  end

  size.times do |y|
    size.times do |x|
      exp = x*x + 3*x + 2*x*y + y + y*y + favourite_number
      ones = exp.to_s(2).chars.count('1')
      board[y][x] = '#' unless ones % 2 == 0
    end
  end

  board
end

def children(x, y, board)
  children = []

  children << [x+1, y] if x + 1 < board.count && board[y][x+1] == '.'
  children << [x-1, y] if x - 1 >= 0 && board[y][x-1] == '.'
  children << [x, y+1] if y + 1 < board.count && board[y+1][x] == '.'
  children << [x, y-1] if y - 1 >= 0 && board[y-1][x] == '.'

  children
end

def bfs(board)
  x, y = 1, 1
  board[y][x] = 0 # visited
  queue = [[x, y]]
  distance = 0
  while queue.size > 0 do
    v = queue.shift
    # puts "v: #{v}"
    # puts "queue: #{queue}"
    x, y = v
    distance = board[y][x]
    children(x, y, board).each do |u|
      ux, uy = u
      board[uy][ux] = distance + 1 # visited
      queue << [ux, uy]
    end
  end
end

favourite_number = 1358
target = [31, 39]
current = [1, 1]

# favourite_number = 10
# target = [7, 4]
# current = [1, 1]

board = draw_board(favourite_number, 50)
bfs(board)
puts board[target[1]][target[0]]

# --- Part Two ---

puts board.flatten.count { |d| d != '.' && d != '#' && d <= 50 }
print_board(board)



