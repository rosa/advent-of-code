# --- Day 17: Two Steps Forward ---

# --- Part One ---
elves = 3012210
gifts = [true]*elves
i = 0

while gifts.count(true) > 1
  gifts.index(true).upto(elves - 1) do |i|
    next unless gifts[i]
    j = (i + 1) % elves
    while !gifts[j] do
      j = (j + 1) % elves
    end
    gifts[j] = false
  end
end

puts gifts.index(true) + 1

# --- Part Two ---

elves = (1..3012210).to_a

i = 0
while elves.count > 1
  c = (i + elves.count/2) % elves.count
  elves.delete_at(c)
  i -= 1 if c < i
  i = (i + 1) % elves.count
end

puts elves.first
