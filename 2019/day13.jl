# --- Day 13: Care Package ---

using Printf

mutable struct Program
    memory::Vector{Int}
    ip::Int
    relativebase::Int
    halted::Bool

    Program(intcodes) = new(vcat(intcodes, zeros(Int, 1000000 - length(intcodes))), 1, 0, false)
end

struct Instruction
    operation::Int
    parameters::Vector{Int}
    modes::Vector{Int}

    function Instruction(opcode::Int, parameters::Vector{Int})
        operation = opcode % 100
        modes = [div(opcode, 10^(i + 1)) % 10 for i in eachindex(parameters)]
        new(operation, parameters, modes)
    end
end

mutable struct Arcade
    program::Program
    grid::Array{Int, 2}
    score::Int
    paddle::Int
    ball::Int

    Arcade(program::Program) = new(program, zeros(Int, 100, 100), 0, 0)
end

# Operations 1, 2, 7, 8 take 3 parameters
# Operations 3, 4, 9 take 1 parameter
# Operations 5 and 6 take 2 parameters
const global parametercounts = [3, 3, 1, 1, 2, 2, 3, 3, 1]

countparameters(opcode) = (opcode % 100) == 99 ? 0 : parametercounts[opcode % 100]

nextparameters(program::Program)::Vector{Int} = [program.memory[program.ip + i] for i=1:countparameters(program.memory[program.ip])]
nextinstruction(program::Program)::Instruction = Instruction(program.memory[program.ip], nextparameters(program))

function parametervalue(program::Program, index::Int, instruction::Instruction)::Int
    # parameter mode 0, position mode, which causes the parameter to be interpreted as a position
    # parameter mode 1, immediate mode. In immediate mode, a parameter is interpreted as a value
    # parameter mode 2, relative mode, like position but from the relative base
    mode = instruction.modes[index]
    value = instruction.parameters[index]
    if mode == 0
        program.memory[value + 1]
    elseif mode == 1
        value
    elseif mode == 2
        program.memory[program.relativebase + value + 1]
    end
end

# Opcode 1 adds together numbers
# Opcode 2 multiples together numbers
# Opcode 3 takes a single integer as input and saves it to the position
# given by its only parameter
# Opcode 4 outputs the value of its only parameter.
# Opcode 7 is less than: if the first parameter is less than the second parameter,
# it stores 1 in the position given by the third parameter. Otherwise, it stores 0.
# Opcode 8 is equals: if the first parameter is equal to the second parameter,
# it stores 1 in the position given by the third parameter. Otherwise, it stores 0.
add(program::Program, instruction::Instruction, input::Int) = parametervalue(program, 1, instruction) + parametervalue(program, 2, instruction)
mult(program::Program, instruction::Instruction, input::Int) = parametervalue(program, 1, instruction) * parametervalue(program, 2, instruction)
input(program::Program, instruction::Instruction, input::Int) = input
output(program::Program, instruction::Instruction, input::Int) = parametervalue(program, 1, instruction)
lessthan(program::Program, instruction::Instruction, input::Int) = parametervalue(program, 1, instruction) < parametervalue(program, 2, instruction) ? 1 : 0
equals(program::Program, instruction::Instruction, input::Int) = parametervalue(program, 1, instruction) == parametervalue(program, 2, instruction) ? 1 : 0

const global operations = Dict{Int,Function}(1 => add, 2 => mult, 3 => input, 4 => output, 7 => lessthan, 8 => equals)

function updatebase!(program::Program, instruction::Instruction)
    if instruction.operation == 9
        program.relativebase += parametervalue(program, 1, instruction)
    end
end

function store!(program::Program, instruction::Instruction, result::Int)
    position = if instruction.operation in [1, 2, 7, 8]
        instruction.modes[3] == 2 ? program.relativebase + instruction.parameters[3] : instruction.parameters[3]
    elseif instruction.operation == 3
        instruction.modes[1] == 2 ? program.relativebase + instruction.parameters[1] : instruction.parameters[1]
    else
        -1
    end

    if position >= 0
        program.memory[position + 1] = result
    end
end

# Opcode 5 is jump-if-true: if the first parameter is non-zero,
# it sets the instruction pointer to the value from the second parameter
# Opcode 6 is jump-if-false: if the first parameter is zero,
# it sets the instruction pointer to the value from the second parameter
function advance!(program::Program, instruction::Instruction)
    if instruction.operation == 5 && parametervalue(program, 1, instruction) != 0
        program.ip = parametervalue(program, 2, instruction) + 1
    elseif instruction.operation == 6 && parametervalue(program, 1, instruction) == 0
        program.ip = parametervalue(program, 2, instruction) + 1
    else
        program.ip = program.ip + length(instruction.parameters) + 1
    end
end

function execute!(program::Program, instruction::Instruction, input::Int)::Int
    result = haskey(operations, instruction.operation) ? operations[instruction.operation](program, instruction, input) : 0
    updatebase!(program, instruction)
    store!(program, instruction, result)
    advance!(program, instruction)

    result
end

function run!(arcade)
    output = 0

    while true
        instruction = nextinstruction(arcade.program)
        if instruction.operation == 99 # Halt
            arcade.program.halted = true
            break
        end
        output = execute!(arcade.program, instruction, nexttilt(arcade))
        if instruction.operation == 4 # Output
            break
        end
    end

    output
end

blockscount(arcade::Arcade) = sum(t->t==2, arcade.grid)

# Input to program:
# If the joystick is in the neutral position, provide 0.
# If the joystick is tilted to the left, provide -1.
# If the joystick is tilted to the right, provide 1.
# Then:
# If ball is on the left of the paddle, tilt joystick left
# If ball is on the right of the paddle, tilt joystick right
# Else: keep the joystick neutral
nexttilt(arcade::Arcade) = sign(arcade.ball - arcade.paddle)

# 0 is an empty tile. No game object appears in this tile.
# 1 is a wall tile. Walls are indestructible barriers.
# 2 is a block tile. Blocks can be broken by the ball.
# 3 is a horizontal paddle tile. The paddle is indestructible.
# 4 is a ball tile. The ball moves diagonally and bounces off objects.
function update!(arcade::Arcade, x::Int, y::Int, z::Int)
    if x == -1 && y == 0
        arcade.score = z
    else
        arcade.grid[y+1, x+1] = z
        if z == 3
            arcade.paddle = x + 1
        elseif z == 4
            arcade.ball = x + 1
        end
    end
end

function play!(arcade::Arcade)
    while true
        if arcade.program.halted
            break
        end

        x = run!(arcade)
        y = run!(arcade)
        z = run!(arcade)
        update!(arcade, x, y, z)
    end
end

function main()
    intcodes = parse.(Int, split(readline("inputs/input13.txt"), ","))
    arcade = Arcade(Program(intcodes))

    # --- Part One ---
    # How many block tiles are on the screen when the game exits?
    play!(arcade)
    @printf("Block tiles: %d\n", blockscount(arcade))

    # --- Part Two ---
    arcade = Arcade(Program(intcodes))
    # Memory address 0 represents the number of quarters that have been inserted; set it to 2 to play for free.
    arcade.program.memory[1] = 2
    play!(arcade)
    @printf("Score: %d\n", arcade.score)
end

main()
