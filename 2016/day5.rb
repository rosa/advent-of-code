# --- Day 5: How About a Nice Game of Chess? ---
require 'digest/md5'

# --- Part One ---

input = 'ugkcyxxp'
index = 0
password = ''

# Result obtained
password = 'd4cd2ee1'

while password.size < 8 do
  key = Digest::MD5.hexdigest(input + index.to_s)
  index += 1
  next unless key.start_with? '00000'
  password += key[5]
  puts password
end

puts password

# --- Part Two ---
index = 0
password = [nil]*8
while password.compact.size < 8 do
  key = Digest::MD5.hexdigest(input + index.to_s)
  index += 1
  next unless key.start_with? '00000'
  position = key[5]
  next if position < '0' || position > '7'
  password[position.to_i] ||= key[6]
  puts password.join
end

puts password.join