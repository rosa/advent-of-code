# --- Day 16: Packet Decoder ---

fs = require 'fs'

input = -> fs.readFileSync 'inputs/input16.txt', 'utf8'

pad = (s) -> s.padStart(Math.ceil(s.length / 4) * 4, 0)
hexStringToBinaryList = (s) -> (pad(parseInt(c, 16).toString(2)) for c in s ).join("").split("")
binaryListToInt = (l) -> parseInt(l.join(""), 2)

processPackets = (stream, decoded = [], n = -1) ->
  if n is 0 or stream.length is 0 or binaryListToInt(stream) is 0
    return [decoded, stream]

  version = binaryListToInt(stream[0...3])
  type = binaryListToInt(stream[3...6])

  [ value, stream ] = switch type
    when 4 then decodeLiteral(stream[6..])
    else decodeOperator(stream[6..])

  decoded.push({version, type, value})
  processPackets(stream, decoded, n - 1)

decodeLiteral = (stream) ->
  # All digits part of the literal start with 1 except the last
  i = 0
  numbers = []
  while i < stream.length
    numbers.push(stream[i+1...i+5])
    break if stream[i] is '0'
    i += 5

  numbers.reduce((x, y) -> x + y)
  [ binaryListToInt(numbers.map((x) -> x.join(""))), stream[i+5..] ]

decodeOperator = (stream) ->
  lengthTypeID = parseInt(stream[0])
  if lengthTypeID is 0
    # the next 15 bits are a number that represents the total length in bits
    # of the sub-packets contained by this packet
    lengthInBits = binaryListToInt(stream[1...16])
    [ subpackets, _ ] = processPackets(stream[16...(16 + lengthInBits)])
    [ subpackets, stream[(16 + lengthInBits)..] ]
  else
    # the next 11 bits are a number that represents the number of sub-packets
    # immediately contained by this packet
    numberOfPackets = binaryListToInt(stream[1...12])
    processPackets(stream[12...], [], numberOfPackets)

addVersions = (packet) ->
  if packet.type is 4
    packet.version
  else
    packet.version + packet.value.map((p) -> addVersions(p)).reduce((x, y) -> x + y)

sum = (packets) -> packets.map((p) -> compute(p)).reduce((x, y) -> x + y)
mul = (packets) -> packets.map((p) -> compute(p)).reduce((x, y) -> x * y)
min = (packets) -> Math.min(packets.map((p) -> compute(p))...)
max = (packets) -> Math.max(packets.map((p) -> compute(p))...)
gt = (packets) -> if compute(packets[0]) > compute(packets[1]) then 1 else 0
lt = (packets) -> if compute(packets[0]) < compute(packets[1]) then 1 else 0
eq = (packets) -> if compute(packets[0]) == compute(packets[1]) then 1 else 0

compute = (packet) ->
  switch packet.type
    when 4 then packet.value
    when 0 then sum(packet.value)
    when 1 then mul(packet.value)
    when 2 then min(packet.value)
    when 3 then max(packet.value)
    when 5 then gt(packet.value)
    when 6 then lt(packet.value)
    when 7 then eq(packet.value)

stream = hexStringToBinaryList(input())
[ packets, _ ] = processPackets(stream)
console.log(addVersions(packets[0]))
console.log(compute(packets[0]))

# coffee -c day16.coffee && node day16.js
# 936
# 6802496672062
