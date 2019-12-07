// --- Day 5: Sunny with a Chance of Asteroids ---

import kotlin.math.*
import java.io.File

class Program(program: String) {
    val intcodes: MutableList<Int> = program.split(",").map { it.toInt() }.toMutableList()
    var ip: Int = 0

    fun run(input: Int): Int {
        var instruction: Instruction
        var output = 0

        do {
            val parameterCount = Instruction.parametersCount(intcodes[ip])
            instruction = Instruction(intcodes[ip], getParameters(parameterCount), ip)

            val partialOutput = instruction.execute(input, intcodes)

            if (instruction.isOutput()) {
                output = partialOutput
            }
            ip = instruction.nextIp(intcodes)
        } while (!instruction.isHalt())

        return output
    }

    private fun getParameters(count: Int): IntArray {
        val parameters = IntArray(count)
        for ((i, p) in intcodes.subList(ip + 1, ip + count + 1).withIndex()) {
            parameters[i] = p
        }
        return parameters
    }
}

class Instruction(opcode: Int, val parameters: IntArray, val ip: Int) {
    val operation: Int
    val parameterModes: IntArray

    init {
        operation = opcode % 100
        parameterModes = IntArray(parameters.size) { 0 }
        for (i in 0..(parameters.size - 1)) {
            var divisor = 10.0.pow(i + 2).toInt()
            parameterModes[i] = (opcode / divisor) % 10
        }
    }

    fun isHalt(): Boolean = operation == 99
    fun isOutput(): Boolean = operation == 4

    // Opcode 1 adds together numbers
    // Opcode 2 multiples together numbers
    // Opcode 3 takes a single integer as input and saves it to the position given by its only parameter
    // Opcode 4 outputs the value of its only parameter.
    // Opcode 7 is less than: if the first parameter is less than the second parameter, it stores 1 in the position given by the third parameter. Otherwise, it stores 0.
    // Opcode 8 is equals: if the first parameter is equal to the second parameter, it stores 1 in the position given by the third parameter. Otherwise, it stores 0.
    fun execute(input: Int, intcodes: MutableList<Int>): Int {
        val result = when (operation) {
            1 -> valueForParam(0, intcodes) + valueForParam(1, intcodes)
            2 -> valueForParam(0, intcodes) * valueForParam(1, intcodes)
            3 -> input
            4 -> valueForParam(0, intcodes)
            7 -> if (valueForParam(0, intcodes) < valueForParam(1, intcodes)) 1 else 0
            8 -> if (valueForParam(0, intcodes) == valueForParam(1, intcodes)) 1 else 0
            else -> 0
        }

        storeResult(result, intcodes)
        return result
    }

    // Opcode 5 is jump-if-true: if the first parameter is non-zero, it sets the instruction pointer to the value from the second parameter
    // Opcode 6 is jump-if-false: if the first parameter is zero, it sets the instruction pointer to the value from the second parameter
    fun nextIp(intcodes: MutableList<Int>): Int {
        val nextIp = if (operation == 5 && valueForParam(0, intcodes) != 0) {
            valueForParam(1, intcodes)
        } else if (operation == 6 && valueForParam(0, intcodes) == 0) {
            valueForParam(1, intcodes)
        } else {
            ip + 1 + parameters.size
        }

        return nextIp
    }

    override fun toString(): String {
        return "Operation: $operation, Modes: ${parameterModes.joinToString()}, Parameters: ${parameters.joinToString()}"
    }

    private fun storeResult(result: Int, intcodes: MutableList<Int>) {
        val position: Int = when (operation) {
            1, 2, 7, 8 -> parameters[2]
            3 -> parameters[0]
            else -> -1
        }
        if (position >= 0) {
            intcodes[position] = result
        }
    }

    // parameter mode 0, position mode, which causes the parameter to be interpreted as a position
    // parameter mode 1, immediate mode. In immediate mode, a parameter is interpreted as a value
    private fun valueForParam(index: Int, intcodes: MutableList<Int>): Int {
        val value = if (parameterModes[index] == 0) {
            intcodes[parameters[index]]
        } else {
            parameters[index]
        }
        return value
    }

    companion object {
        fun parametersCount(opcode: Int): Int {
            val count = when (opcode % 100) {
                1, 2, 7, 8 -> 3
                3, 4 -> 1
                5, 6 -> 2
                else -> 0
            }
            return count
        }
    }
}

fun main(args: Array<String>) {
    val input = File("inputs/input05.txt").readText().trim()
    // --- Part One ---
    // After providing 1 to the only input instruction
    // and passing all the tests, what diagnostic code does the program produce?
    var output = Program(input).run(1)
    println(output)

    // --- Part Two ---
    // What is the diagnostic code for system ID 5?
    output = Program(input).run(5)
    println(output)
}

// kotlinc day05.kt -include-runtime -d day05.jar
// java -jar day05.jar
// 5577461
// 7161591
