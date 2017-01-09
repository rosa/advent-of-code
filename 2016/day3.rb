# --- Day 3: Squares With Three Sides ---

# --- Part One ---

def possible?(triangle)
  (triangle[0] + triangle[1]) > triangle[2] &&
  (triangle[1] + triangle[2]) > triangle[0] &&
  (triangle[0] + triangle[2]) > triangle[1]
end

def possible_triangles(triangles)
  triangles.count { |triangle| possible?(triangle.map(&:to_i)) }
end

triangles = File.readlines('input_day3.txt').map(&:strip).map(&:split)

puts possible_triangles(triangles)

# --- Part Two ---
lines = File.readlines('input_day3.txt').map(&:strip).map(&:split)
transposed = [[], [], []]
triangles = []
lines.each do |line|
  transposed[0] << line[0]
  transposed[1] << line[1]
  transposed[2] << line[2]
end

transposed.each do |column|
  while column.count > 0
    triangles << column.shift(3)
  end
end

puts possible_triangles(triangles)
