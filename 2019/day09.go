// --- Day 9: Sensor Boost ---

package main

import (
	"bufio"
	"fmt"
	"math"
	"os"
	"strconv"
	"strings"
)

type Program interface {
	Run([]int) int
	NextInstruction() Instruction
	NextParameters() []int
	Execute() int
}

type Instruction interface {
	IsHalt() bool
	IsOutput() bool
	ValueForParam(int *Program) int
	StoreResult(int *Program)
	AdvanceIp(int *Program)
}

type IntcodeProgram struct {
	Intcodes     []int
	Ip           int
	RelativeBase int
}

type IntcodeInstruction struct {
	Operation      int
	Parameters     []int
	ParameterModes []int
}

func (instruction IntcodeInstruction) IsHalt() bool {
	return instruction.Operation == 99
}

func (instruction IntcodeInstruction) IsOutput() bool {
	return instruction.Operation == 4
}

func (instruction IntcodeInstruction) ValueForParam(index int, program *IntcodeProgram) int {
	// parameter mode 0, position mode, which causes the parameter to be interpreted as a position
	// parameter mode 1, immediate mode. In immediate mode, a parameter is interpreted as a value
	// parameter mode 2, relative mode, like position but from the relative base
	var value int
	switch instruction.ParameterModes[index] {
	case 0:
		value = program.Intcodes[instruction.Parameters[index]]
	case 1:
		value = instruction.Parameters[index]
	case 2:
		value = program.Intcodes[program.RelativeBase+instruction.Parameters[index]]
	}
	return value
}

func (instruction IntcodeInstruction) StoreResult(result int, program *IntcodeProgram) {
	var position int

	base := 0
	switch instruction.Operation {
	case 1, 2, 7, 8:
		if instruction.ParameterModes[2] == 2 {
			base = program.RelativeBase
		}
		position = base + instruction.Parameters[2]
	case 3:
		if instruction.ParameterModes[0] == 2 {
			base = program.RelativeBase
		}
		position = base + instruction.Parameters[0]
	default:
		position = -1
	}

	if position >= 0 {
		program.Intcodes[position] = result
	}
}

func (instruction IntcodeInstruction) AdvanceIp(program *IntcodeProgram) {
	// Opcode 5 is jump-if-true: if the first parameter is non-zero,
	// it sets the instruction pointer to the value from the second parameter
	// Opcode 6 is jump-if-false: if the first parameter is zero,
	// it sets the instruction pointer to the value from the second parameter
	switch {
	case instruction.Operation == 5 && instruction.ValueForParam(0, program) != 0:
		program.Ip = instruction.ValueForParam(1, program)
	case instruction.Operation == 6 && instruction.ValueForParam(0, program) == 0:
		program.Ip = instruction.ValueForParam(1, program)
	default:
		program.Ip = program.Ip + 1 + len(instruction.Parameters)
	}
}

func countParameters(opcode int) int {
	var count int
	switch opcode % 100 {
	case 1, 2, 7, 8:
		count = 3
	case 3, 4, 9:
		count = 1
	case 5, 6:
		count = 2
	default:
		count = 0
	}
	return count
}

func getParameterModes(opcode int) []int {
	count := countParameters(opcode)
	parameterModes := make([]int, 0, count)
	for i := 0; i < count; i++ {
		divisor := int(math.Pow10(i + 2))
		parameterModes = append(parameterModes, (opcode/divisor)%10)
	}
	return parameterModes
}

func (program IntcodeProgram) NextParameters() []int {
	count := countParameters(program.Intcodes[program.Ip])
	return program.Intcodes[program.Ip+1 : program.Ip+count+1]
}

func (program IntcodeProgram) NextInstruction() IntcodeInstruction {
	opcode := program.Intcodes[program.Ip]
	return IntcodeInstruction{opcode % 100, program.NextParameters(), getParameterModes(opcode)}
}

// Opcode 1 adds together numbers
// Opcode 2 multiples together numbers
// Opcode 3 takes a single integer as input and saves it to the position given by its only parameter
// Opcode 4 outputs the value of its only parameter.
// Opcode 7 is less than: if the first parameter is less than the second parameter, it stores 1 in the position given by the third parameter. Otherwise, it stores 0.
// Opcode 8 is equals: if the first parameter is equal to the second parameter,
// it stores 1 in the position given by the third parameter. Otherwise, it stores 0.
// Opcode 9 adjusts the relative base by the value of its only parameter.
func (program *IntcodeProgram) Execute(instruction IntcodeInstruction, input int) int {
	var result int
	switch instruction.Operation {
	case 1:
		result = instruction.ValueForParam(0, program) + instruction.ValueForParam(1, program)
	case 2:
		result = instruction.ValueForParam(0, program) * instruction.ValueForParam(1, program)
	case 3:
		result = input
	case 4:
		result = instruction.ValueForParam(0, program)
	case 7:
		if instruction.ValueForParam(0, program) < instruction.ValueForParam(1, program) {
			result = 1
		}
	case 8:
		if instruction.ValueForParam(0, program) == instruction.ValueForParam(1, program) {
			result = 1
		}
	case 9:
		program.RelativeBase = program.RelativeBase + instruction.ValueForParam(0, program)
		result = 0
	default:
		result = 0
	}

	instruction.StoreResult(result, program)
	instruction.AdvanceIp(program)
	return result
}

func (program IntcodeProgram) Run(input int) int {
	output := 0
	instruction := program.NextInstruction()

	for !instruction.IsHalt() {
		partialOutput := program.Execute(instruction, input)
		if instruction.IsOutput() {
			output = partialOutput
		}
		instruction = program.NextInstruction()
	}

	return output
}

func parseIntcodes(codes []string) []int {
	var str string
	var i int

	intcodes := make([]int, 1000000)
	for i, str = range codes {
		n, _ := strconv.Atoi(str)
		intcodes[i] = n
	}
	return intcodes
}

func main() {
	if file, err := os.Open("inputs/input09.txt"); err == nil {
		defer file.Close()

		reader := bufio.NewReader(file)
		line, _ := reader.ReadString('\n')
		line = strings.Trim(line, "\n")
		intcodes := parseIntcodes(strings.Split(line, ","))
		program := IntcodeProgram{intcodes, 0, 0}
		// --- Part One ---
		fmt.Printf("%v\n", program.Run(1))
		// --- Part Two ---
		fmt.Printf("%v\n", program.Run(2))
	}
}

// go run day09.go
// 3512778005
// 35920
