# --- Day 14: One-Time Pad ---

# --- Part One ---
require 'digest/md5'

def next_1000(salt, index, stretches = 1)
  i = index
  r = []
  1000.times do
    h = salt + i.to_s
    stretches.times do
      h = Digest::MD5.hexdigest(h)
    end
    r << h
    i += 1
  end
  r
end

def find_triplet(key)
  triplet = []
  key.chars.each do |c|
    if triplet.last == c
      triplet << c
      break if triplet.size == 3
    else
      triplet = [c]
    end
  end
  triplet.size == 3 ? triplet.join : nil
end

def key?(triplet, batch)
  batch[0...1000].any? { |key| key.include? triplet }
end

salt = 'zpqevtbw'
keys = []
index = 0
batch = next_1000(salt, index)
batch |= next_1000(salt, index + 1000)

while keys.size < 64 do
  key = batch.shift
  triplet = find_triplet(key)
  keys << [index, key] if triplet && key?(triplet + triplet[0..1], batch)
  index += 1
  batch |= next_1000(salt, index + 1000) if index % 1000 == 0
end

puts keys.map { |k| k.join(' ') }.join("\n")

# --- Part Two ---

salt = 'zpqevtbw'
# salt = 'abc'
keys = []
index = 0
batch = next_1000(salt, index, 2017)
batch |= next_1000(salt, index + 1000, 2017)

while keys.size < 64 do
  key = batch.shift
  triplet = find_triplet(key)
  keys << [index, key] if triplet && key?(triplet + triplet[0..1], batch)
  index += 1
  batch |= next_1000(salt, index + 1000, 2017) if index % 1000 == 0
end

puts keys.map { |k| k.join(' ') }.join("\n")
