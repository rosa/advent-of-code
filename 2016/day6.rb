# --- Day 6: Signals and Noise ---

# --- Part One ---
lines = File.readlines('input_day6.txt').map(&:strip)

columns = []

lines.first.size.times do |i|
  columns << lines.map { |l| l[i] }
end

message = ''
columns.each do |column|
  counts = Hash.new(0).tap { |h| column.each { |letter| h[letter] += 1 } }
  counts = counts.sort { |a, b| (a[1] == b[1]) ? a[0] <=> b[0] : -1*(a[1] <=> b[1]) }
  message << counts.first.first
end

puts message

# --- Part Two ---

message = ''
columns.each do |column|
  counts = Hash.new(0).tap { |h| column.each { |letter| h[letter] += 1 } }
  counts = counts.sort { |a, b| (a[1] == b[1]) ? a[0] <=> b[0] : (a[1] <=> b[1]) }
  message << counts.first.first
end

puts message


