# --- Day 16: Dragon Checksum ---

# --- Part One ---

def neg(b)
  b.chars.collect { |c| c == '1' ? '0' : '1' }.join
end

def fill_disk(init, size)
  a = init
  while a.size < size
    b = a
    b = b.reverse
    b = neg(b)
    a = a + '0' + b
  end
  a
end

def checksum(data)
  data = data.chars
  checksum = []
  while true
    data.each_slice(2) do |g|
      if g[0] == g[1]
        checksum << '1'
      else
        checksum << '0'
      end
    end

    return checksum.join if checksum.size.odd?

    data = checksum.dup
    checksum = []
  end

  checksum.join
end

input = '11110010111001001'
length = 272

data = fill_disk(input, length)
puts checksum(data[0...length])

# --- Part Two ---

length = 35651584

data = fill_disk(input, length)
puts checksum(data[0...length])
