# --- Day 9: Explosives in Cyberspace ---

# --- Part One ---

compressed = File.read('input_day9.txt').gsub(/\n|\s/, '')

def marker(marker)
  return [0, 1] unless marker && marker =~ /(\d+)x(\d+)/
  [$1, $2].map(&:to_i)
end

def process_marker(data, current_marker)
  x, y = current_marker
  result = if x >= data.size
    data.size * y
  else
    x * y + data.size - x
  end
  result
end

def decompressed_length(compressed, rec = false)
  count = 0
  data = ''
  marker = nil
  current_marker = [0, 1]
  section = 0

  compressed.chars.each do |c|
    if c == '(' && marker.nil? && section <= 0
      # Start new marker
      count += (rec ? process_marker_rec(data, current_marker) : process_marker(data, current_marker))
      section = 0
      marker = ''
    elsif c == ')' && !marker.nil?
      # Finish storing a marker and start storing data
      current_marker = marker(marker)
      section = current_marker[0]
      data = ''
      marker = nil
    elsif c != '(' && c != ')' && !marker.nil?
      # Continue processing a new marker
      marker << c
    else
      data << c
      section -= 1
    end
  end

  # Add remaining data
  count + (rec ? process_marker_rec(data, current_marker) : process_marker(data, current_marker))
end

puts decompressed_length(compressed)

# --- Part Two ---

def process_marker_rec(data, current_marker)
  x, y = current_marker
  
  # Check if we need to expand an extra marker
  # within the current marker section
  marker_section = data[0...x]
  size = if marker_section =~ /\(\d+x\d+\)/
    decompressed_length(marker_section, true)
  else
    marker_section.size
  end

  result = if x >= data.size
    size * y
  else
    size * y + data.size - x
  end
  result
end

puts decompressed_length(compressed, true)
