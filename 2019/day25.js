// --- Day 25: Cryostasis ---

'use strict';

const fs = require('fs');
const readline = require('readline');

class Instruction {
  operation = 0;
  parameters = [];
  modes = [];

  constructor(opcode, parameters) {
    this.operation = opcode % 100;
    this.parameters = parameters;
    for (let i = 0; i < this.parameters.length; i++) {
      this.modes.push(Math.floor(opcode / 10**(i + 2)) % 10);
    }
  }

  static countParameters(operation) {
    let count = 0;
    if ([1, 2, 7, 8].includes(operation))
      count = 3;
    else if ([3, 4, 9].includes(operation))
      count = 1
    else if ([5, 6].includes(operation))
      count = 2;

    return count;
  }

  isHalt() {
    return this.operation == 99;
  }

  isOutput() {
    return this.operation == 4;
  }

  isInput() {
    return this.operation == 3;
  }

  execute(values, input) {
    switch (this.operation) {
      case 1:
        return values[0] + values[1];
      case 2:
        return values[0] * values[1];
      case 3:
        return input;
      case 4:
        return values[0];
      case 7:
        return (values[0] < values[1]) ? 1 : 0;
      case 8:
        return (values[0] == values[1]) ? 1 : 0;
      default:
        return 0;
    }
  }

  nextIp(values, ip) {
    let nextIp = ip + this.parameters.length + 1;

    if (this.operation == 5 && values[0] != 0)
      nextIp = values[1];
    else if (this.operation == 6 && values[0] == 0)
      nextIp = values[1];

    return nextIp;
  }

  nextRelativeBase(values, relativeBase) {
    return this.operation == 9 ? relativeBase + values[0] : relativeBase;
  }

  positionToStore(relativeBase) {
    let position = -1;
    if ([1, 2, 7, 8].includes(this.operation))
      position = this.modes[2] == 2 ? relativeBase + this.parameters[2] : this.parameters[2];
    else if (this.operation == 3)
      position = this.modes[0] == 2 ? relativeBase + this.parameters[0] : this.parameters[0];

    return position;
  }
}

class Program {
  ip = 0;
  relativeBase = 0;
  memory = [];

  halted = false;
  waitingForInput = false;

  inputs = [];
  outputs = [];

  constructor(intcodes) {
    this.memory = intcodes.split(',').map(Number);
  }

  run() {
    let input = 0;
    while (true) {
      let instruction = this.nextInstruction;

      if (instruction.isHalt()) {
        this.halted = true
        break;
      }

      if (instruction.isInput() && this.inputs.length == 0) {
        this.waitingForInput = true;
        break;
      } else if (instruction.isInput()) {
        input = this.inputs.shift();
      }

      let output = this.execute(instruction, input);
      if (instruction.isOutput())
        this.outputs.push(output);
    }
  }

  clear() {
    this.inputs = this.outputs = [];
    this.halted = this.waitingForInput = false;
  }

  setInputs(inputs) {
    this.inputs = inputs;
    this.waitingForInput = false;
  }

  get output() {
    return String.fromCharCode.apply(null, this.outputs);
  }

  get nextInstruction() {
    return new Instruction(this.nextOpcode, this.nextParameters);
  }

  get nextParameters() {
    const count = Instruction.countParameters(this.nextOpcode % 100);
    return this.memory.slice(this.ip + 1, this.ip + 1 + count);
  }

  get nextOpcode() {
    return this.memory[this.ip];
  }

  // parameter mode 0, position mode, which causes the parameter to be interpreted as a position
  // parameter mode 1, immediate mode. In immediate mode, a parameter is interpreted as a value
  // parameter mode 2, relative mode, like position but from the relative base
  parameterValues(instruction) {
    return [...instruction.parameters .keys()].map(i => {
      switch (instruction.modes[i]) {
        case 0:
          return this.memory[instruction.parameters[i]];
        case 1:
          return instruction.parameters[i];
        case 2:
          return this.memory[this.relativeBase + instruction.parameters[i]];
      }
    });
  }

  execute(instruction, input) {
    const paramValues = this.parameterValues(instruction);
    const output = instruction.execute(paramValues, input);
    this.relativeBase = instruction.nextRelativeBase(paramValues, this.relativeBase);
    this.ip = instruction.nextIp(paramValues, this.ip);

    const position = instruction.positionToStore(this.relativeBase);
    if (position >= 0)
      this.memory[position] = output;

    return output;
  }
}

class Droid {
  constructor(intcodes) {
    this.program = new Program(intcodes);
    this.readline = readline.createInterface({
      input: process.stdin,
      output: process.stdout,
      terminal: false
    });
  }

  interactive() {
    this.readline.on('line', (line) => {
      this.sendCommand(line.trim());
    }).on('close', () => process.exit(0));

    this.program.run();
    console.log(this.program.output);
  }

  auto() {
    this.program.run();
    console.log(this.program.output);

    // See below for comments on how I got this playing interactively. Take all objects that can be
    // taken and go to the Security Checkpoint
    const commands = ['north', 'north', 'east', 'east', 'take cake', 'west', 'west', 'south', 'south',
      'south', 'west', 'take fuel cell', 'west', 'take easter egg', 'east', 'east', 'north',
      'east', 'take ornament', 'east', 'take hologram', 'east', 'take dark matter', 'north', 'north', 'east', 'take klein bottle', 'north', 'take hypercube', 'north', 'inv']

    commands.forEach((command) => this.sendCommand(command));

    const items = ['ornament', 'easter egg', 'hypercube', 'hologram', 'cake', 'fuel cell', 'dark matter', 'klein bottle'];

    // Now brute-force the weights. We have 8 items and need to try all combinations of them, so we can use binary numbers from 00000000 to 11111111, to decide
    // which items are taken (those with a 1)
    for (let i = 0; i < 256; i++) {
      let dropped = this.dropping(items, (i).toString(2));
      dropped.forEach((item) => this.sendCommand('drop ' + item));
      this.sendCommand('west');
      dropped.forEach((item) => this.sendCommand('take ' + item));
    }

  }

  sendCommand(command) {
    this.program.clear();
    this.program.setInputs( [...Buffer.from(command), 10]);
    this.program.run();
    console.log(this.program.output);
    if (this.program.halted)
      process.exit(0);
  }

  dropping(items, mask) {
    const dropped = [];
    const padded = mask.padStart(8, '0');
    for (let i = 0; i < 8; i++) {
      if (padded[i] == '0')
        dropped.push(items[i]);
    }

    return dropped;
  }
}

fs.readFile('inputs/input25.txt', (err, data) => {
  if (err) throw err;

  const intcodes = data.toString();
  const droid = new Droid(intcodes);
  if (process.argv.length >= 2 && process.argv[2] == "--interactive")
    droid.interactive();
   else
    droid.auto();
});


// Manual play to get the path
// node day25.js --interactive

// start - Hull Breach
// -> north - Kitchen (take escape pod -> launch you into space, bye!)
//   -> north - Passages
//     -> east - Hot Chocolate Fountain (take giant electromagnet -> it sticks to you and you can't do anything else)
//       -> east - Crew Quarters (take cake)
// -> south - Arcade (take infinite loop -> the program goes into an infinite loop ^_^U)
//   -> west - Hallway (take fuel cell)
//     -> west - Warp Drive Maintenance (take easter egg)
// -> east - Corridor (take ornament)
//   -> east - Sick Bay (take hologram)
//     -> east - Gift Wrapping Center (take dark matter)
//       -> north - Engineering
//         -> north - Navigation
//           -> east - Observatory (take klein bottle)
//             -> north - Holodeck (take hypercube)
//               -> north - Security Checkpoint
//                 -> west - Pressure-Sensitive Floor: droids are lighter/heavier -> ejected back to Checkpoint
//   -> south - Stables
//     -> east - Storage (take molten lava - You melt)
//       -> east - Science Lab (take photons - It is suddenly completely dark! You are eaten by a Grue!)
//
// In the security checkpoint:
// Items in your inventory:
// - ornament
// - easter egg
// - hypercube
// - hologram
// - cake
// - fuel cell
// - dark matter
// - klein bottle

// And auto play to brute-force the items and get the password!
// node day25.js --auto
// A loud, robotic voice says "Analysis complete! You may proceed." and you enter the cockpit.
// Santa notices your small droid, looks puzzled for a moment, realizes what has happened, and radios your ship directly.
// "Oh, hello! You should be able to get in by typing 1090617344 on the keypad at the main airlock."
