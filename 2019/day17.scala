/* --- Day 17: Set and Forget --- */

import scala.io.Source
import scala.collection.mutable.ArrayBuffer
import scala.util.control.Breaks

class ASCII(val intcodes: String) {
  var program = new Program(intcodes)
  var view: ArrayBuffer[String] = initCameraView
  var currentPosition: (Int, Int, Char) = initRobotPosition
  var movements: ArrayBuffer[String] = new ArrayBuffer[String]

  def aligmentParameters: IndexedSeq[Int] = findIntersections.map(x => x._1 * x._2)

  def traverseScaffold = while(move) ()

  def vacuum(routine: String, a: String, b: String, c: String) = {
    // Restart
    program = new Program(intcodes)
    // Force the vacuum robot to wake up by changing the value in your ASCII program at address 0 from 1 to 2
    program.memory(0) = 2
    while (!program.waitingForInput) program.run

    feed(routine)
    feed(a)
    feed(b)
    feed(c)
    feed("n")

    program.run
    // Dust collected
    println(program.outputs.last)
  }

  def feed(function: String) = {
    program.outputs.clear
    program.inputs = function.getBytes.map(_.toLong).to(ArrayBuffer)
    program.inputs += 10
    program.run
    println(program.outputs.map(_.toChar).mkString(""))
  }

  override def toString: String = view.mkString("\n")

  private[this] def initCameraView = {
    while (!program.halted) program.run
    program.outputs.map(_.toChar).mkString("").split("\n").to(ArrayBuffer)
  }

  private[this] def initRobotPosition: (Int, Int, Char) = {
    val i: Int = view.indexWhere((row) => row.contains('^'))
    val j: Int = view(i).indexOf('^')
    (i, j, '^')
  }

  private[this] def findIntersections: IndexedSeq[(Int, Int)] = {
    for (i <- 0 until view.size;
         j <- 0 until view(i).size if isIntersection(i, j))
      yield (i, j)
  }

  private[this] def isIntersection(i: Int, j: Int): Boolean = withinDimensions(i, j) && view(i)(j) == '#' && view(i-1)(j) == '#' && view(i)(j-1) == '#' && view(i+1)(j) == '#' && view(i)(j+1) == '#'
  private[this] def withinDimensions(i: Int, j: Int): Boolean = i-1 >= 0 && j-1 >= 0 && i+1 < view.size && j+1 < view(i).size && j+1 < view(i-1).size && j+1 < view(i+1).size

  private[this] def move: Boolean = if (canAdvanceForward) advanceForward else turn

  private[this] def canAdvanceForward: Boolean = currentPosition match {
    case (i, j, '^') => onScaffold(i-1, j)
    case (i, j, '>') => onScaffold(i, j+1)
    case (i, j, 'v') => onScaffold(i+1, j)
    case (i, j, '<') => onScaffold(i, j-1)
    case _ => false
  }

  private[this] def onScaffold(i: Int, j: Int): Boolean = i >= 0 && j >= 0 && i < view.size && j < view(i).size && view(i)(j) == '#'

  private[this] def advanceForward: Boolean = {
    currentPosition = currentPosition match {
      case (i, j, '^') => (i-1, j, '^')
      case (i, j, '>') => (i, j+1, '>')
      case (i, j, 'v') => (i+1, j, 'v')
      case (i, j, '<') => (i, j-1, '<')
      case _ => currentPosition
    }

    if (movements.last.forall(_.isDigit)) {
      movements(movements.size - 1) = (movements.last.toInt + 1).toString
    } else {
      movements += "1"
    }
    true
  }

  private[this] def turn: Boolean = {
    var turn = true
    currentPosition match {
      case (i, j, '^') if onScaffold(i, j+1) => {
        movements += "R"
        currentPosition = (i, j, '>')
      }
      case (i, j, '^') if onScaffold(i, j-1) => {
        movements += "L"
        currentPosition = (i, j, '<')
      }

      case (i, j, '>') if onScaffold(i+1, j) => {
        movements += "R"
        currentPosition = (i, j, 'v')
      }
      case (i, j, '>') if onScaffold(i-1, j) => {
        movements += "L"
        currentPosition = (i, j, '^')
      }

      case (i, j, 'v') if onScaffold(i, j-1) => {
        movements += "R"
        currentPosition = (i, j, '<')
      }
      case (i, j, 'v') if onScaffold(i, j+1) => {
        movements += "L"
        currentPosition = (i, j, '>')
      }

      case (i, j, '<') if onScaffold(i-1, j) => {
        movements += "R"
        currentPosition = (i, j, '^')
      }
      case (i, j, '<') if onScaffold(i+1, j) => {
        movements += "L"
        currentPosition = (i, j, 'v')
      }

      case _ => turn = false
    }
    turn
  }
}

class Program(val intcodes: String) {
  var memory: ArrayBuffer[Long] = intcodes.split(",").map(_.toLong).to(ArrayBuffer) ++ ArrayBuffer.fill[Long](10000)(0)
  var ip: Int = 0
  var relativeBase: Int = 0
  var halted: Boolean = false
  var waitingForInput: Boolean = false
  var inputs: ArrayBuffer[Long] = new ArrayBuffer[Long]
  var outputs: ArrayBuffer[Long] = new ArrayBuffer[Long]

  override def toString: String = s"[$memory.take(50)...], ip: $ip, relative base: $relativeBase"

  def run = {
    var output: Long = 0
    var input: Long = 0
    val loop: Breaks = new Breaks

    loop.breakable {
      while (true) {
        val instruction: Instruction = nextInstruction
        if (instruction.isHalt) {
          halted = true
          loop.break
        }

        if (instruction.isInput && inputs.isEmpty) {
          waitingForInput = true
          loop.break
        } else if (instruction.isInput) {
          waitingForInput = false
          input = inputs.head
          inputs = inputs.drop(1)
        }

        output = execute(instruction, input)
        if (instruction.isOutput) outputs += output
      }
    }
  }

  private[this] def execute(instruction: Instruction, input: Long): Long = {
    val params = parameterValues(instruction)
    val output = instruction.execute(params, input)
    relativeBase = instruction.nextRelativeBase(params, relativeBase).toInt
    ip = instruction.nextIp(params, ip).toInt

    val position = instruction.positionToStore(relativeBase).toInt
    if (position >= 0) memory(position) = output

    output
  }

  private[this] def nextInstruction: Instruction = new Instruction(memory(ip), nextParameters)

  private[this] def nextParameters: IndexedSeq[Long] = {
    val count: Int = Instruction.countParameters(memory(ip))
    memory.slice(ip + 1, ip + 1 + count).toIndexedSeq
  }

  // parameter mode 0, position mode, which causes the parameter to be interpreted as a position
  // parameter mode 1, immediate mode. In immediate mode, a parameter is interpreted as a value
  // parameter mode 2, relative mode, like position but from the relative base
  private[this] def parameterValues(instruction: Instruction): IndexedSeq[Long] = {
    for (i <- 0 until instruction.parameters.size)
      yield instruction.modes(i) match {
        case 0 => memory(instruction.parameters(i).toInt)
        case 1 => instruction.parameters(i)
        case 2 => memory(relativeBase + instruction.parameters(i).toInt)
      }
  }
}

class Instruction (val opcode: Long, val parameters: IndexedSeq[Long]) {
  val operation: Int = (opcode % 100).toInt
  val modes: IndexedSeq[Int] = for (i <- 0 until parameters.size)
    yield ((opcode / Math.pow(10, i + 2)) % 10).toInt

  def isHalt: Boolean = operation == 99
  def isOutput: Boolean = operation == 4
  def isInput: Boolean = operation == 3

  // Opcode 1 adds together numbers
  // Opcode 2 multiples together numbers
  // Opcode 3 takes a single integer as input and saves it to the position given by its only parameter
  // Opcode 4 outputs the value of its only parameter.
  // Opcode 7 is less than: if the first parameter is less than the second parameter, it stores 1 in the position given by the third parameter. Otherwise, it stores 0.
  // Opcode 8 is equals: if the first parameter is equal to the second parameter, it stores 1 in the position given by the third parameter. Otherwise, it stores 0.
  def execute(parameterValues: IndexedSeq[Long], input: Long): Long = operation match {
    case 1 => parameterValues(0) + parameterValues(1)
    case 2 => parameterValues(0) * parameterValues(1)
    case 3 => input
    case 4 => parameterValues(0)
    case 7 => if (parameterValues(0) < parameterValues(1)) 1 else 0
    case 8 => if (parameterValues(0) == parameterValues(1)) 1 else 0
    case _ => 0
  }

  // Opcode 5 is jump-if-true: if the first parameter is non-zero,
  // it sets the instruction pointer to the value from the second parameter
  // Opcode 6 is jump-if-false: if the first parameter is zero,
  // it sets the instruction pointer to the value from the second parameter
  def nextIp(parameterValues: IndexedSeq[Long], ip: Long): Long = {
    if (operation == 5 && parameterValues(0) != 0)
      parameterValues(1)
    else if (operation == 6 && parameterValues(0) == 0)
      parameterValues(1)
    else
      ip + parameters.size + 1
  }

  def nextRelativeBase(parameterValues: IndexedSeq[Long], relativeBase: Long): Long = if (operation == 9) relativeBase + parameterValues(0) else relativeBase

  def positionToStore(relativeBase: Long): Long = operation match { 
    case 1 | 2 | 7 | 8 => if (modes(2) == 2) relativeBase + parameters(2) else parameters(2)
    case 3 => if (modes(0) == 2) relativeBase + parameters(0) else parameters(0)
    case _ => -1
  }

  override def toString: String = s"($operation, $parameters, $modes)"
}

object Instruction {
  def countParameters(opcode: Long): Int = (opcode % 100) match {
    case 1 | 2 | 7 | 8 => 3
    case 3 | 4 | 9 => 1
    case 5 | 6 => 2
    case _ => 0
  }
}

def readIntcodes(filename: String): String = {
  return Source.fromFile(filename).getLines().next()
}

val intcodes = readIntcodes("inputs/input17.txt")
val ascii = new ASCII(intcodes)
// --- Part One ---
// What is the sum of the alignment parameters for the scaffold intersections?
println(ascii.aligmentParameters.sum)
println(ascii)

// scala day17.scala
// 8408
// ........................................#########...........#########........
// ........................................#.......#...........#.......#........
// ........................................#.......#...........#.......#........
// ........................................#.......#...........#.......#........
// ........................................#.......#...........#.......#........
// ........................................#.......#...........#.......#........
// ........................................#.......#...........#.......#........
// ........................................#.......#...........#.......#........
// ........................................#.......#.......#############........
// ........................................#.......#.......#...#................
// #########...................#############.......#.....^######................
// #.......#...................#...................#.......#....................
// #.......#...................#...................###########..................
// #.......#...................#...........................#.#..................
// #.......#...................#...........................#.#..................
// #.......#...................#...........................#.#..................
// #.......#...................#...........................###########..........
// #.......#...................#.............................#.......#..........
// ###########.................#.............................###########........
// ........#.#.................#.....................................#.#........
// ........#.#...........#######.....................................#.#........
// ........#.#...........#...........................................#.#........
// ........###########...#...........................................###########
// ..........#.......#...#.............................................#.......#
// ..........###########.#.............................................#.......#
// ..................#.#.#.............................................#.......#
// ..................#.#.#.............................................#.......#
// ..................#.#.#.............................................#.......#
// ..................###########.......................................#.......#
// ....................#.#.............................................#.......#
// ................#######.............................................#########
// ................#...#........................................................
// ........#############........................................................
// ........#.......#............................................................
// ........#.......#............................................................
// ........#.......#............................................................
// ........#.......#............................................................
// ........#.......#............................................................
// ........#.......#............................................................
// ........#.......#............................................................
// ........#########............................................................

// --- Part Two ---
ascii.traverseScaffold
println(ascii.movements.mkString(","))
// R,6,L,10,R,8,R,8,R,12,L,8,L,10,R,6,L,10,R,8,R,8,R,12,L,10,R,6,L,10,R,12,L,8,L,10,R,12,L,10,R,6,L,10,R,6,L,10,R,8,R,8,R,12,L,8,L,10,R,6,L,10,R,8,R,8,R,12,L,10,R,6,L,10

// A = R,6,L,10,R,8,R,8
// B = R,12,L,8,L,10
// C = R,12,L,10,R,6,L,10

// Routine: A,B,A,C,B,C,A,B,A,C
ascii.vacuum("A,B,A,C,B,C,A,B,A,C", "R,6,L,10,R,8,R,8", "R,12,L,8,L,10", "R,12,L,10,R,6,L,10")

// Function A:

// Function B:

// Function C:

// Continuous video feed?


// ........................................#########...........#########........
// ........................................#.......#...........#.......#........
// ........................................#.......#...........#.......#........
// ........................................#.......#...........#.......#........
// ........................................#.......#...........#.......#........
// ........................................#.......#...........#.......#........
// ........................................#.......#...........#.......#........
// ........................................#.......#...........#.......#........
// ........................................#.......#.......#############........
// ........................................#.......#.......#...#................
// #########...................#############.......#.....#######................
// #.......#...................#...................#.......#....................
// #.......#...................#...................###########..................
// #.......#...................#...........................#.#..................
// #.......#...................#...........................#.#..................
// #.......#...................#...........................#.#..................
// #.......#...................#...........................###########..........
// #.......#...................#.............................#.......#..........
// ###########.................#.............................###########........
// ........#.#.................#.....................................#.#........
// ........#.#...........#######.....................................#.#........
// ........#.#...........#...........................................#.#........
// ........###########...#...........................................###########
// ..........#.......#...#.............................................#.......#
// ..........###########.#.............................................#.......#
// ..................#.#.#.............................................#.......#
// ..................#.#.#.............................................#.......#
// ..................#.#.#.............................................#.......#
// ..................##########>.......................................#.......#
// ....................#.#.............................................#.......#
// ................#######.............................................#########
// ................#...#........................................................
// ........#############........................................................
// ........#.......#............................................................
// ........#.......#............................................................
// ........#.......#............................................................
// ........#.......#............................................................
// ........#.......#............................................................
// ........#.......#............................................................
// ........#.......#............................................................
// ........#########............................................................

// 혴
// 1168948
