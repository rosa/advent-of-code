// --- Day 15: Oxygen System ---

import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math';

class Program {
  List<int> memory;
  int ip = 0, relativeBase = 0;
  bool halted = false;

  Program(List<String> intcodes) : memory = List<int>.from(intcodes.map(int.parse)) + List<int>.filled(1000, 0);

  int countParameters(int opcode) {
    const Map<int,int> counts = {1: 3, 2: 3, 3: 1, 4: 1, 5: 2, 6: 2, 7: 3, 8: 3, 9: 1, 99: 0};
    return counts[opcode % 100];
  }

  List<int> nextParameters() {
    int count = countParameters(memory[ip]);
    List<int> parameters = List(count);
    List.copyRange<int>(parameters, 0, memory, ip + 1, ip + 1 + count);
    return parameters;
  }

  Instruction nextInstruction() => Instruction(memory[ip], nextParameters(), memory, relativeBase);

  int execute(Instruction instruction, int input) {
    int result = instruction.execute(input);
    relativeBase = instruction.nextRelativeBase();
    ip = instruction.nextIp(ip);

    int position = instruction.positionToStore();
    if (position >= 0) memory[position] = result;

    return result;
  }

  int run(input) {
    int output = 0;

    while (true) {
      Instruction instruction = nextInstruction();
      if (instruction.isHalt()) {
        halted = true;
        break;
      }
      output = execute(instruction, input);
      if (instruction.isOutput()) break;
    }

    return output;
  }

  @override
  String toString() {
    return "Memory: " + memory.sublist(0, 100).toString() + "\nIP: " + ip.toString() + "\nRelative Base: " + relativeBase.toString();
  }
}

class Instruction {
  int operation;
  List<int> parameters, modes, memory;
  int relativeBase;

  Instruction(int opcode, this.parameters, this.memory, this.relativeBase) {
    operation = opcode % 100;
    modes = [];
    for (int i = 0; i < parameters.length; i++) {
      int divisor = pow(10, i + 2);
      modes.add((opcode ~/ divisor) % 10);
    }
  }

  bool isHalt() => operation == 99;
  bool isOutput() => operation == 4;

  int parameterValue(int index) {
    // parameter mode 0, position mode, which causes the parameter to be interpreted as a position
    // parameter mode 1, immediate mode. In immediate mode, a parameter is interpreted as a value
    // parameter mode 2, relative mode, like position but from the relative base
    int mode = modes[index];
    int value = parameters[index];
    if (mode == 0) {
      value = memory[value];
    } else if (mode == 2) {
      value = memory[relativeBase + value];
    }

    return value;
  }

  int add(int input) => parameterValue(0) + parameterValue(1);
  int mult(int input) => parameterValue(0) * parameterValue(1);
  int inop(int input) => input;
  int output(int input) => parameterValue(0);
  int lessthan(int input) => parameterValue(0) < parameterValue(1) ? 1 : 0;
  int equals(int input) => parameterValue(0) == parameterValue(1) ? 1 : 0;

  int execute(int input) {
    final Map<int,Function> operations = {1: add, 2: mult, 3: inop, 4: output, 7: lessthan, 8: equals};
    return operations[operation] != null ? operations[operation](input) : 0;
  }

  // Opcode 5 is jump-if-true: if the first parameter is non-zero,
  // it sets the instruction pointer to the value from the second parameter
  // Opcode 6 is jump-if-false: if the first parameter is zero,
  // it sets the instruction pointer to the value from the second parameter
  int nextIp(int ip) {
    int nextIp = ip + parameters.length + 1;
    if (operation == 5 && parameterValue(0) != 0) {
      nextIp = parameterValue(1);
    } else if (operation == 6 && parameterValue(0) == 0) {
      nextIp = parameterValue(1);
    }

    return nextIp;
  }

  int nextRelativeBase() => operation == 9 ? relativeBase + parameterValue(0) : relativeBase;

  int positionToStore() {
    int position = -1;
    if ([1, 2, 7, 8].contains(operation)) {
      position = modes[2] == 2 ? relativeBase + parameters[2] : parameters[2];
    } else if (operation == 3) {
      position = modes[0] == 2 ? relativeBase + parameters[0] : parameters[0];
    }

    return position;
  }

  @override
  String toString() {
    return [operation.toString(), parameters.toString(), modes.toString(), relativeBase.toString()].join(" ");
  }
}

class RepairDroid {
  List<String> intcodes;
  List<int> commandsToOxygen;

  RepairDroid(this.intcodes) : commandsToOxygen = [];

  // Only four movement commands are understood: north (1), south (2), west (3), and east (4)
  List <int> nextCommands(int command) {
    // Never go back/unwalk the walked
    const Map<int,List<int>> next = {1: [1, 3, 4], 2: [2, 3, 4], 3: [1, 2, 3], 4: [1, 2, 4]};
    return next[command];
  }

  List<List<int>> neighbours(List <int> commands) {
    if (commands.isEmpty) {
      return List.from([1, 2, 3, 4].map((command) => [command]));
    } else {
      return List.from(nextCommands(commands.last).map((command) => [...commands, command]));
    }
  }

  int run(List<int> commands) {
    Program program = Program(intcodes);
    int output;

    for (int command in commands) {
      output = program.run(command);
    }

    return output;
  }

  // 0: The repair droid hit a wall. Its position has not changed.
  // 1: The repair droid has moved one step in the requested direction.
  // 2: The repair droid has moved one step in the requested direction; its new position is the location of the oxygen system.
  void searchOxygenSystem() {
    Queue<List<int>> queue = Queue<List<int>>.from(neighbours([]));

    while (queue.isNotEmpty) {
      List<int> commands = queue.removeFirst();
      int outcome = run(commands);
      if (outcome == 2) {
        commandsToOxygen = commands;
      } else if (outcome == 1) {
        queue.addAll(neighbours(commands));
      }
    }
  }

  // --- Part Two ---
  List<int> mapArea() {
    if (commandsToOxygen.isEmpty) searchOxygenSystem();

    Queue<List<int>> queue = Queue<List<int>>.from(neighbours([]));
    List<int> commands = [];

    while (queue.isNotEmpty) {
      commands = queue.removeFirst();
      // Go to oxygen system and map from there
      int outcome = run(commandsToOxygen + commands);
      if (outcome == 1) {
        queue.addAll(neighbours(commands));
      }
    }

    commands.removeLast();
    return commands;
  }
}

void main() {
  new File('inputs/input15.txt').readAsString().then((String contents) {
    List<String> intcodes = contents.split(',');
    RepairDroid repairDroid = RepairDroid(intcodes);
    repairDroid.searchOxygenSystem();
    print("Number of steps: ${repairDroid.commandsToOxygen.length}");
    print("Map size: ${repairDroid.mapArea().length}");
  });
}
