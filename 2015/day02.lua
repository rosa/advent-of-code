-- --- Day 2: I Was Told There Would Be No Math ---

function readpresents(path)
  local presents = {}
  for line in io.lines(path) do
    presents[#presents + 1] = parsedimensions(line)
  end
  return presents
end

function parsedimensions(line)
  -- Each line is of the form: 19x18x22
  local vl, vw, vh = line:match("(%d+)x(%d+)x(%d+)")
  return {l=tonumber(vl), w=tonumber(vw), h=tonumber(vh)}
end

function paper(box)
  -- Surface area of the box, 2*l*w + 2*w*h + 2*h*l, plus area of the smallest side
  local areas = {box.l*box.w, box.w*box.h, box.h*box.l}
  return 2*areas[1] + 2*areas[2] + 2*areas[3] + math.min(unpack(areas))
end

-- How many total square feet of wrapping paper should they order?
local presents = readpresents("inputs/input02.txt")
local total = 0
for _, present in ipairs(presents) do
  total = total + paper(present)
end

print("Paper: " .. total)

-- --- Part Two ---
function ribbon(box)
  local perimeters = {box.l+box.w, box.w+box.h, box.h+box.l}
  return 2*math.min(unpack(perimeters)) + box.l*box.w*box.h
end

-- How many total feet of ribbon should they order?
total = 0
for _, present in ipairs(presents) do
  total = total + ribbon(present)
end

print("Ribbon: " .. total)
