-- --- Day 7: Amplification Circuit ---

function readprogram(path)
  local intcodes = {}
  io.input(path)
  local program = io.read()

  for intcode in program:gmatch("(-?%d+)") do
    intcodes[#intcodes + 1] = tonumber(intcode)
  end

  return intcodes
end

function table.clone(org)
  return {table.unpack(org)}
end

PARAM_COUNT = {3, 3, 1, 1, 2, 2, 3, 3}

function nextinstruction(memory, ip)
  local operation = memory[ip + 1] % 100
  local paramCount = PARAM_COUNT[operation] or 0
  local parameters, modes = {}, {}

  for i = 1, paramCount
  do
    divisor = 10^(i + 1)
    parameters[#parameters + 1] = memory[ip + i + 1]
    modes[#modes + 1] = (memory[ip + 1] // divisor) % 10
  end

  return {operation=operation, parameters=parameters, modes=modes}
end


-- parameter mode 0, position mode, which causes the parameter to be interpreted as a position
-- parameter mode 1, immediate mode. In immediate mode, a parameter is interpreted as a value
function valueforparam(instruction, memory, index)
  if instruction.modes[index] == 0 then
    return memory[instruction.parameters[index] + 1]
  else
    return instruction.parameters[index]
  end
end

-- Opcode 1 adds together numbers
-- Opcode 2 multiples together numbers
-- Opcode 3 takes a single integer as input and saves it to the position given by its only parameter
-- Opcode 4 outputs the value of its only parameter.
-- Opcode 7 is less than: if the first parameter is less than the second parameter, it stores 1 in the position given by the third parameter. Otherwise, it stores 0.
-- Opcode 8 is equals: if the first parameter is equal to the second parameter, it stores 1 in the position given by the third parameter. Otherwise, it stores 0.
ACTION = {
  [1] = function (x, y) return x + y end,
  [2] = function (x, y) return x * y end,
  [7] = function (x, y) if x < y then return 1 else return 0 end end,
  [8] = function (x, y) if x == y then return 1 else return 0 end end
}
-- Opcode 5 is jump-if-true: if the first parameter is non-zero, it sets the instruction pointer to the value from the second parameter
-- Opcode 6 is jump-if-false: if the first parameter is zero, it sets the instruction pointer to the value from the second parameter
function nextip(instruction, memory, ip)
  if (instruction.operation == 5) and (valueforparam(instruction, memory, 1) ~= 0) then
    return valueforparam(instruction, memory, 2)
  elseif (instruction.operation == 6) and (valueforparam(instruction, memory, 1) == 0) then
    return valueforparam(instruction, memory, 2)
  else
    return ip + 1 + #instruction.parameters
  end
end

function store(instruction, output, memory)
  if PARAM_COUNT[instruction.operation] == 3 then
    memory[instruction.parameters[3] + 1] = output
  elseif instruction.operation == 3 then
    memory[instruction.parameters[1] + 1] = output
  end
end

function execute(instruction, input, memory, ip)
  local output = nil

  if ACTION[instruction.operation] then
    output = ACTION[instruction.operation](valueforparam(instruction, memory, 1), valueforparam(instruction, memory, 2))
  elseif instruction.operation == 3 then
    output = input
  elseif instruction.operation == 4 then
    output = valueforparam(instruction, memory, 1)
  end

  nextIp = nextip(instruction, memory, ip)
  store(instruction, output, memory)

  return {ip=nextIp, output=output}
end

function runprogram(memory, inputs, outputmode, ip)
  outputmode = outputmode or false
  ip = ip or 0
  local output = 0
  local inputIndex = 1

  repeat
    instruction = nextinstruction(memory, ip)
    local result = execute(instruction, inputs[inputIndex], memory, ip)

    ip = result.ip

    if instruction.operation == 4 then
      output = result.output
      if outputmode then
        return {ip=ip, output=output, halted=false}
      end
    end

    if (instruction.operation == 3) then
      inputIndex = inputIndex + 1
    end
  until(instruction.operation == 99)

  return {ip=ip, output=output, halted=true}
end

function table.print(t)
  for _, i in ipairs(t) do
    print(i)
  end
end

function runamplifiers(intcodes, phases)
  local result = {output=0, ip=0}
  for _, phase in ipairs(phases) do
    local memory = table.clone(intcodes)
    result = runprogram(memory, {phase, result.output})
  end
  return result.output
end

function runfeedbackloop(intcodes, phases)
  -- Need to keep the state for all amplifiers
  local outputs = {}
  local memories = {}
  local ips = {}
  for i = 1, 5 do
    outputs[#outputs + 1] = 0
    memories[#memories + 1] = table.clone(intcodes)
    ips[#ips + 1] = 0
  end

  -- Run first with phases
  for i, phase in ipairs(phases) do
    local outputindex = (i - 1 == 0) and 5 or i - 1
    local result = runprogram(memories[i], {phase, outputs[outputindex]}, true, ips[i])
    outputs[i], ips[i] = result.output, result.ip
  end

  -- And now run until halt
  repeat
    local halted = false
    for i, memory in ipairs(memories) do
      local outputindex = (i - 1 == 0) and 5 or i - 1
      local result = runprogram(memory, {outputs[outputindex]}, true, ips[i])
      halted = result.halted and (i == 5)
      if not halted then
        outputs[i], ips[i] = result.output, result.ip
      end
    end
  until(halted)

  return outputs[5]
end

function generatephase(elements, n)
  if n == 0 then
    coroutine.yield(elements)
  else
    for i = 1, n do
      -- Put i-th element as the last one
      elements[n], elements[i] = elements[i], elements[n]
      -- Generate all permutations of the other elements
      generatephase(elements, n - 1)
      -- Restore i-th element
      elements[n], elements[i] = elements[i], elements[n]
    end
  end
end

function allphases(elements)
  local n = #elements
  return coroutine.wrap(function () generatephase(elements, n) end)
end

function maxthrustersignal(intcodes, fn, codes)
  local maxsignal = 0
  for phases in allphases(codes) do
    local signal = fn(intcodes, phases)
    if signal > maxsignal then
      maxsignal = signal
    end
  end

  return maxsignal
end

local intcodes = readprogram("inputs/input07.txt")
print(maxthrustersignal(intcodes, runamplifiers, {0,1,2,3,4}))
-- 437860

-- --- Part Two ---
print(maxthrustersignal(intcodes, runfeedbackloop, {5,6,7,8,9}))
-- 49810599
