-- --- Day 8: Seven Segment Search ---

-- Some utilities
chars = (str) ->
  [ c for c in string.gmatch(str, ".") ]

string_sort = (str) ->
  list = chars(str)
  table.sort(list)
  table.concat(list)

string_intersection = (str1, str2) ->
  list1, list2 = chars(str1), chars(str2)
  intersection = {}
  for c2 in *list2 do for c1 in *list1 do intersection[#intersection + 1] = c2 if c1 == c2
  table.concat(intersection)

class Observation
  only_digits: { "2": 1, "4": 4, "3": 7, "7": 8 }

  new: (signals, outputs) =>
    @unknowns = {}
    @signals = {}
    @outputs = outputs
    for s in *signals
      d = @digit(s)
      if d != nil
        @signals[d] = s
      else
        table.insert(@unknowns, s)

  digit: (s) =>
    @only_digits[tostring(#s)]

  only_digits_count: =>
    c = 0
    for s in *@outputs do c += 1 if @only_digits[tostring(#s)] != nil
    c

  deduce: =>
    @find_six!
    @find_nine_and_zero!
    @find_three!
    @find_five_and_two!
    @compute_output!

  -- Numbers using six segments are 0, 6 and 9.
  -- 0 and 9 cover 7 completely, so their intersection has size 3
  -- 6 is the only one that doesn't overlap completely, intersection
  -- is size 2. Thus, if we have 7, we can deduce 6
  find_six: =>
    for i, s in ipairs(@unknowns)
      if #s == 6 and #string_intersection(s, @signals[7]) < 3
        @signals[6] = s
        table.remove(@unknowns, i)
        break

  -- Once 6 is found, only 0 and 9 are using 6 segments.
  -- 9 covers 4 completely, so their intersection has size 4,
  -- while 0 doesn't cover the middle segment, so their
  -- intersection has size 3
  find_nine_and_zero: =>
    for s in *@unknowns
      if #s == 6
        if #string_intersection(s, @signals[4]) == 4
          @signals[9] = s
        else
          @signals[0] = s

  -- 3 is the only one with size 5 that covers 7 completely,
  -- 2 and 5 don't. We look at the intersection of 3 with
  -- 7, that should have size 3
  find_three: =>
    for i, s in ipairs(@unknowns)
      if #s == 5 and #string_intersection(s, @signals[7]) == 3
        @signals[3] = s
        table.remove(@unknowns, i)
        break

  -- Once 3 is found, 5 is the only one covered completely by 6,
  -- and 2 is the remaining one with size 5
  find_five_and_two: =>
    for s in *@unknowns
      if #s == 5
        if #string_intersection(@signals[6], s) == 5
          @signals[5] = s
        else
          @signals[2] = s

  compute_output: =>
    dict = { v, k for k, v in pairs @signals}
    sum = 0
    for i, s in ipairs(@outputs)
      sum += 10^(4-i) * dict[s]
    sum

parse = (line) ->
  signals = {}
  outputs = {}
  i = 1
  for s in string.gmatch(line, "(%a+)")
    signals[i] = string_sort(s) if i <= 10
    outputs[i - 10] = string_sort(s) if i > 10
    i += 1
  Observation(signals, outputs)

input = (path) ->
  obs = {}
  for line in io.lines(path)
    obs[#obs + 1] = parse(line)
  obs

observations = input(arg[1])

count = 0
for obs in *observations do count += obs\only_digits_count!
print count

sum = 0
for obs in *observations do sum += obs\deduce!
print sum

-- moon day08.moon inputs/input08.txt
-- 362
-- 1020159.0
