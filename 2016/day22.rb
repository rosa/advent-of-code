# --- Day 22: Grid Computing ---

# --- Part One ---

class Node
  attr_accessor :size, :used, :avail, :percent, :x, :y

  def inspect
    "#{name} #{size}T   #{used}T    #{avail}T   #{percent}%"
  end

  def to_s
    self.inspect
  end

  def ==(node)
    self.name == node.name
  end

  def name
    "node-x#{x}-y#{y}"
  end
end

def viable_pairs(nodes)
  pairs = []

  nodes.each do |node_a|
    nodes.each do |node_b|
      # Nodes A and B are not the same node.
      # Node A is not empty (its Used is not zero).
      # The data on node A (its Used) would fit on node B (its Avail).
      next unless node_a != node_b && node_a.used > 0 && node_a.used <= node_b.avail
      pairs << [node_a, node_b]
    end
  end

  pairs
end


df = File.readlines('input_day22.txt').map(&:strip)
nodes = []

df.each do |df_line|
  # Filesystem              Size  Used  Avail  Use%
  # /dev/grid/node-x0-y0     92T   70T    22T   76%
  next unless df_line =~ /\/dev\/grid\/node-x(\d+)-y(\d+)\s+(\d+)T\s+(\d+)T\s+(\d+)T\s+(\d+)%/
  node = Node.new
  node.x = $1.to_i
  node.y = $2.to_i
  node.size = $3.to_i
  node.used = $4.to_i
  node.avail = $5.to_i
  node.percent = $6.to_i
  nodes << node
end

pairs = viable_pairs(nodes)
puts pairs.count

# --- Part Two ---

# We are looking for a path from G (node with y=0 and the highest x, that is, the node 
# in the top-right corner) to the init node (x0-y0).
g = Node.new
g.x = nodes.map(&:x).max
g.y = 0
s = Node.new
s.x = s.y = 0

g_pairs = pairs.select { |p| p.first == g || p.last == g }
s_pairs = pairs.select { |p| p.first == s || p.last == s }
middle = [s_pairs + g_pairs].flatten.uniq
middle.delete(g)
middle.delete(s)
middle = middle.first

obstacles = nodes.select { |n| !pairs.flatten.include? n }
obs_x = obstacles.map(&:x).min
# Going up to y0: going up to obstacle, going around obstacle
steps = middle.y + (middle.x - obs_x + 1)*2
# Going right up to g.x
steps += g.x - middle.x
# 5 steps on moving G to the left
steps += 5*(g.x - 1)

puts steps
