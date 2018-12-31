# --- Day 7: Internet Protocol Version 7 ---

# --- Part One ---

def abba?(chars)
  chars.count.times do |i|
    break if i + 3 > chars.count - 1

    return true if chars[i] != chars[i+1] && chars[i] == chars[i+3] && chars[i+1] == chars[i+2]
  end

  false
end

def ins_and_outs(ip)
  groups = ip.scan(/\w*\[\w+\]\w*/)
  ins = []
  outs = []
  groups.each do |group|
    if group =~ /(\w*)\[(\w+)\](\w*)/
      ins << $2
      outs << $1 unless $1.empty?
      outs << $3 unless $3.empty?
    end
  end

  [ins, outs]
end

def tls?(ip)
  ins, outs = ins_and_outs(ip)
  outs.any? { |s| abba?(s.chars) } && !ins.any? { |s| abba?(s.chars) }
end

lines = File.readlines('inputs/input07.txt').map(&:strip)

puts lines.count { |line| tls?(line) }

# --- Part Two ---

def abas(chars)
  abas = []
  chars.count.times do |i|
    break if i + 2 > chars.count - 1
    abas << chars[i..i+2].join if chars[i] != chars[i+1] && chars[i] == chars[i+2]
  end
  abas
end

def bab(aba)
  bab = [aba[1], aba[0], aba[1]].join
end

def ssl?(ip)
  ins, outs = ins_and_outs(ip)

  all_abas = outs.map { |s| abas(s.chars) }.flatten
  all_babs = all_abas.map { |aba| bab(aba) }
  ins.any? do |out|
    all_babs.any? { |bab| out.include? (bab) }
  end
end

puts lines.count { |line| ssl?(line) }
