# --- Day 11: Radioisotope Thermoelectric Generators ---
require 'pqueue'

# --- Part One ---

class Position
  # A position is determined by each floor's contents and where the lift is
  attr_accessor :lift, :floors

  def initialize(lift)
    @lift = lift
    @floors = []
    4.times { @floors << [] }
  end

  def add(floor, contents)
    self.floors[floor] = contents.dup.uniq.sort
  end

  def children
    # Positions we can obtain from the one we are in, going up and down
    moves = []
    # Going down
    moves |= moves(lift - 1) if lift > 0
    # Going up
    moves |= moves(lift + 1) if lift < 3

    moves.sort
  end

  def ==(position)
    # Two positions are the same if the lift is in the same floor and they
    # have the same configuration of microchips and generators in each floor
    # They are sorted, so we can check with Array == directly
    self.lift == position.lift && (0..3).all? { |i| self.floors[i] == position.floors[i] }
  end

  alias eql? ==

  def hash
    self.lift.hash ^ self.floors.hash
  end

  def <=>(position)
    self.score <=> position.score
  end

  def score
    # How close we are to completion
    total = floors[0..2].reduce(0) { |acc, f| acc += f.count }
    (total / 2.0).ceil
  end

  def to_s
    s = ["\n"]
    3.downto(0) do |i|
      i == lift ? (s << "* | #{floors[i].join(' ')}") : (s << "  | #{floors[i].join(' ')}")
    end
    s.join("\n")
  end

  def inspect
    self.to_s
  end

  private

  def gen?(elem)
    elem.include?('-gen')
  end

  def mc?(elem)
    elem.include?('-mc')
  end

  def gen_for_mc(elem)
    "#{elem.split('-').first}-gen"
  end

  def valid?(contents)
    # There are no generators, or all microchips have their generator
    contents.none? { |e| gen?(e) } || contents.all? { |e| !mc?(e) || contents.include?(gen_for_mc(e)) }
  end

  def moves(to)
    # Possible moves from our current position to floor 'to'
    # We need to choose 1 or 2 items to carry with us, always leaving valid positions
    source = floors[lift]
    moves = []

    # Choose one item
    source.each do |elem|
      move = go(to, [elem])
      moves << move if move
    end

    # Choose two items
    source.combination(2) do |pair|
      move = go(to, pair)
      moves << move if move
    end

    moves
  end

  def go(to, carry)
    target = floors[to]
    source = floors[lift]
    return nil unless valid?(source - carry) && valid?(target + carry)

    Position.new(to).tap do |move|
      0.upto(3) do |i|
        if i == to
          move.add(i, target + carry)
        elsif i == lift
          move.add(i, source - carry)
        else
          move.add(i, floors[i])
        end
      end
    end
  end
end

def path(previous, start)
  start ? [start] + path(previous, previous[start]) : []
end

def shortest_path(position)
  # queue = PQueue.new([[0, position]]) { |a, b| a.first > b.first }
  queue = [position]
  previous = { position => nil }
  distances = { position => 0 }

  while !queue.empty?
    puts queue.count

    # _, v = queue.shift
    v = queue.shift
    return path(previous, v) if v.score == 0 # Finished!

    children = v.children
    new_distance = distances[v] + 1
    children.each do |child|
      if !distances[child] || distances[child] > new_distance
        # queue << [new_distance + child.score, child]
        queue << child
        distances[child] = new_distance
        previous[child] = v
      end
    end
  end
end

# thulium, plutonium, strontium, promethium, ruthenium
# The first floor contains a thulium generator, a thulium-compatible microchip,
# a plutonium generator, and a strontium generator.
initial_contents = [
  %w(thulium-mc thulium-gen plutonium-gen strontium-gen),
# The second floor contains a plutonium-compatible microchip and a strontium-compatible microchip.
  %w(strontium-mc plutonium-mc),
# The third floor contains a promethium generator, a promethium-compatible microchip,
# a ruthenium generator, and a ruthenium-compatible microchip.
  %w(promethium-gen promethium-mc ruthenium-gen ruthenium-mc),
# The fourth floor contains nothing relevant.
  []]

# The first floor contains a hydrogen-compatible microchip and a lithium-compatible microchip.
# The second floor contains a hydrogen generator.
# The third floor contains a lithium generator.
# The fourth floor contains nothing relevant.
# initial_contents = [%w(hydrogen-mc lithium-mc), %w(hydrogen-gen), %w(lithium-gen), []]

# position = Position.new(0).tap { |p| 0.upto(3) { |i| p.add(i, initial_contents[i])} }

# puts shortest_path(position).count - 1

# --- Part Two ---

# Parts on the first floor that weren't listed on the record outside:
# An elerium generator.
# An elerium-compatible microchip.
# A dilithium generator.
# A dilithium-compatible microchip.

initial_contents[0] |= %w(elerium-mc elerium-gen dilithium-mc dilithium-gen)
position = Position.new(0).tap { |p| 0.upto(3) { |i| p.add(i, initial_contents[i])} }

puts shortest_path(position).count - 1
