// --- Day 24: Arithmetic Logic Unit ---

class ALU {
  private variables = [w: 0, x: 0, y: 0, z: 0]
  def program = []
  def input = []

  ALU(program) {
    this.program = program
  }

  public reset() {
    input = []
    variables.keySet().each { variables[it] = 0 as Long }
  }

  public run(input) {
    this.input = input
    program.each { execute(it) }

    variables["z"]
  }

  public execute(instruction) {
    switch(instruction[0]) {
      case "inp":
        variables[instruction[1]] = input.remove(0)
        break
      case "add":
        variables[instruction[1]] += value(instruction[2])
        break
      case "mul":
        variables[instruction[1]] *= value(instruction[2])
        break
      case "div":
        variables[instruction[1]] = (variables[instruction[1]] / value(instruction[2])) as Long
        break
      case "mod":
        variables[instruction[1]] %= value(instruction[2])
        break
      case "eql":
        variables[instruction[1]] = (variables[instruction[1]] == value(instruction[2])) ? 1 : 0
        break
    }
  }

  private value(operand) {
    (this.variables[operand] != null) ? this.variables[operand] : operand as Long
  }
}

// MONAD is split into 14 blocks, each block starting with an "inp w" instruction.
// x, y, w are "reset" in each block, w gets the input and x and y are set to 0.
// The only one that carries over is z.

// In each block, a value is added to x. These are the values per block
// addx = 15, 12, 13, -14, 15, -7, 14, 15, 15, -7, -8, -7, -5, -10
// Same for y, a value is added to y in each block. These are the values:
// addy = 15, 5, 6, 7, 9, 6, 14, 3, 1, 3, 4, 6, 7, 1

// Each block i does:
// x = z % 26
// z = z / 26 if addx[i] < 0
// x = x + addx[i]
// y = x == w ? 26 : 1
// z = z * y + (x == w ? w + addy[i] : 0)
// That is:
// x = z % 26 + addx[i]
// z = z / 26 if addx[i] < 0
// if (x != w)
//   z = z * 26 + w + addy[i]
// There are 7 blocks that have addx[i] > 0 and 7 that have addx[i] < 0.
// For all blocks that have addx[i] > 0, they also have addx[i] > 10. That means
// that in these blocks, x = z % 26 + addx[i] can't never be equal to w, since w is
// always < 10, and x would be always > 10. Then, these blocks will always execute this:
//   z = z * 26 + w + addy[i]
// This will happen 7 times.
// For z to end up as 0, we need to have the other 7 blocks to divide z by 26 and not multiply it
// back. That is, we need this:
// if (x != w)
//   z = z * 26 + w + addy[i]
// to not execute. Then, x = z % 26 + addx[i] needs to be equal to w.
// Having this into account and going block by block from 0 to 13 we can find the conditions
// that the different digits in w need to satisfy.
// Example for the first few blocks:
// w0, z = 0, addx = 15, addy = 15
// x = z mod 26 = 0
// z = w0 + 15
// ---
// w1, z = w0 + 15, addx = 12, addy = 5
// x = (w0 + 15) mod 26 + 12
// z = 26*(w0 + 15) + w1 + 5
// ---
// w2, z = 26*(w0 + 15) + w1 + 5, addx = 13, addy = 6
// x = (w1 + 5) mod 26 + 13
// z = 26*(26*(w0 + 15) + w1 + 5) + w2 + 6
// ---
// w3, z = 26*(26*(w0 + 15) + w1 + 5) + w2 + 6, addx = -14, addy = 7
// x = (w2 + 6) mod 26 - 14
// z = 26*(w0 + 15) + w1 + 5 (division by 26 because addx < 0)
// For x == w, it needs to be (w2 + 6) mod 26 = w3 + 14 --> first condition
// ...
// Continuing until w13, we find the following conditions:

def bruteforceInput(start, end, incr) {
  w = []
  for (i in 0..13) {
    w.add(0)
  }

  // w2 and w3
  // (w2 + 6) mod 26 == w3 + 14
  (x, y) = solveEquation(6, 14, start, end, incr)
  w[2] = x
  w[3] = y

  // w4 and w5
  // (w4 + 9) mod 26 == w5 + 7
  (x, y) = solveEquation(9, 7, start, end, incr)
  w[4] = x
  w[5] = y

  // w8 and w9
  // (w8 + 1) mod 26 == w9 + 7
  (x, y) = solveEquation(1, 7, start, end, incr)
  w[8] = x
  w[9] = y

  // w7 and w10
  // (w7 + 3) mod 26 == w10 + 8
  (x, y) = solveEquation(3, 8, start, end, incr)
  w[7] = x
  w[10] = y

  // w6 and w11
  // (w6 + 14) mod 26 == w11 + 7
  (x, y) = solveEquation(14, 7, start, end, incr)
  w[6] = x
  w[11] = y

  // w1 and w12
  // (w1 + 5) mod 26 == w12 + 5
  (x, y) = solveEquation(5, 5, start, end, incr)
  w[1] = x
  w[12] = y

  // w0 and w13
  // (w0 + 15) mod 26 == w13 + 10
  (x, y) = solveEquation(15, 10, start, end, incr)
  w[0] = x
  w[13] = y

  w
}

// Equation (x + a) mod 26 = y + b
// If multiple solutions, we return the first based
// on order given by start, end and incr
def solveEquation(a, b, start, end, incr) {
  for (x = start; x != end; x += incr) {
    for (y = start; y != end; y += incr) {
      if ((x + a) % 26 == y + b) {
        return [x, y]
      }
    }
  }
}

def program = []
new File(args[0]).eachLine { line ->
  program.add(line.split(" "))
}

def alu = new ALU(program)

// Part 1
def input = bruteforceInput(9, 0, -1)
println(input.join(""))
assert (alu.run(input) == 0)

alu.reset()

// Part 2
input = bruteforceInput(1, 10, 1)
println(input.join(""))
assert (alu.run(input) == 0)

// groovy day24.groovy inputs/input24.txt
// 49917929934999
// 11911316711816
