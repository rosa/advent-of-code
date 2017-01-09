# --- Day 4: Security Through Obscurity ---

# --- Part One ---
rooms = File.readlines('4.in').map(&:strip)

def room(line)
  return nil unless line =~ /((\w|-)+)-(\d+)\[(\w+)\]\z/
  [$1, $3.to_i, $4]
end

def checksum(encrypted_name)
  letters = encrypted_name.split('-').join.chars
  counts = Hash.new(0).tap { |h| letters.each { |letter| h[letter] += 1 } }
  counts = counts.sort { |a, b| (a[1] == b[1]) ? a[0] <=> b[0] : -1*(a[1] <=> b[1]) }
  counts.take(5).map(&:first).join
end

sector_sums = 0
rooms.each do |room_line|
  encrypted_name, sector_id, checksum = room(room_line)
  sector_sums += sector_id if checksum(encrypted_name) == checksum
end

puts sector_sums
  
# --- Part Two ---

def decrypt_room_name(encrypted_name, sector_id)
  letters = encrypted_name.chars
  decrypted_name = []
  letters.each do |letter|
    if letter == '-'
      decrypted_name << ' '
    else
      decrypted_name << ((letter.ord - 97 + sector_id) % 26 + 97).chr
    end
  end
  decrypted_name.join
end

names = []
rooms.each do |room_line|
  encrypted_name, sector_id, checksum = room(room_line)
  names << [decrypt_room_name(encrypted_name, sector_id), sector_id] if checksum(encrypted_name) == checksum
end

puts names.detect { |name, _| name[/north/i] }
