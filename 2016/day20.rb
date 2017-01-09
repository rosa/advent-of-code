# --- Day 20: Firewall Rules ---

# --- Part One ---
MAX = 4294967295
# MAX = 9
intervals = File.readlines('input_day20.txt').map(&:strip).map { |block| block.split('-').map(&:to_i) }
# intervals = [[5,8], [0,2], [4,7]]
intervals.sort_by! { |i| i.first }

ip = 0
intervals.each do |interval|
  ip = interval.last + 1 if interval.first <= ip && ip <= interval.last
end

puts ip

# --- Part Two ---

ip = 0
allowed = 0
intervals.each do |interval|
  allowed += interval.first - ip if interval.first >= ip
  ip = interval.last + 1 if ip <= interval.last
end

allowed += MAX - ip + 1

puts allowed
