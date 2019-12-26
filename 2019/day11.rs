// --- Day 11: Space Police ---

use std::{collections::HashMap, fmt, fs::File, io, io::prelude::*};

#[derive(Debug)]
struct Program {
    memory: Vec<i64>,
    ip: usize,
    relative_base: i64,
    halted: bool,
}

#[derive(Debug)]
struct Instruction {
    operation: i64,
    parameters: Vec<i64>,
    parameter_modes: Vec<i64>,
}

#[derive(Debug)]
enum Direction {
    Up,
    Down,
    Right,
    Left,
}

#[derive(Debug)]
struct Robot {
    current: (i64, i64),
    panels: HashMap<(i64, i64), i64>,
    direction: Direction,
    program: Program,
}

impl Program {
    fn new(intcodes: Vec<i64>) -> Program {
        let mut memory = Vec::new();
        memory.extend_from_slice(&intcodes);
        memory.resize(1000000, 0);
        Program {
            memory: memory,
            ip: 0,
            relative_base: 0,
            halted: false,
        }
    }

    fn next_instruction(&self) -> Instruction {
        let opcode = self.memory[self.ip];
        Instruction::new(opcode, self.next_parameters())
    }

    fn next_parameters(&self) -> Vec<i64> {
        let count = Instruction::count_parameters(self.memory[self.ip]);
        self.memory[self.ip + 1..self.ip + 1 + count].to_vec()
    }

    fn value_for_param(&self, index: usize, instruction: &Instruction) -> i64 {
        // parameter mode 0, position mode, which causes the parameter to be interpreted as a position
        // parameter mode 1, immediate mode. In immediate mode, a parameter is interpreted as a value
        // parameter mode 2, relative mode, like position but from the relative base
        match instruction.parameter_modes[index] {
            0 => self.memory[instruction.parameters[index] as usize],
            1 => instruction.parameters[index],
            2 => self.memory[(self.relative_base + instruction.parameters[index]) as usize],
            _ => 0,
        }
    }

    fn store_result(&mut self, value: i64, instruction: &Instruction) {
        let mut base = 0;

        let position = match instruction.operation {
            1 | 2 | 7 | 8 => {
                if instruction.parameter_modes[2] == 2 {
                    base = self.relative_base;
                }
                base + instruction.parameters[2]
            }
            3 => {
                if instruction.parameter_modes[0] == 2 {
                    base = self.relative_base;
                }
                base + instruction.parameters[0]
            }
            _ => -1,
        };

        if position >= 0 {
            self.memory[position as usize] = value;
        }
    }

    // Opcode 9 adjusts the relative base by the value of its only parameter.
    fn update_base(&mut self, instruction: &Instruction) {
        if instruction.operation == 9 {
            self.relative_base += self.value_for_param(0, instruction);
        }
    }

    // Opcode 5 is jump-if-true: if the first parameter is non-zero,
    // it sets the instruction pointer to the value from the second parameter
    // Opcode 6 is jump-if-false: if the first parameter is zero,
    // it sets the instruction pointer to the value from the second parameter
    fn advance_ip(&mut self, instruction: &Instruction) {
        let new_ip = match instruction.operation {
            5 if self.value_for_param(0, instruction) != 0 => {
                self.value_for_param(1, instruction) as usize
            }
            6 if self.value_for_param(0, instruction) == 0 => {
                self.value_for_param(1, instruction) as usize
            }
            _ => self.ip + 1 + instruction.parameters.len(),
        };
        self.ip = new_ip;
    }

    // Opcode 1 adds together numbers
    // Opcode 2 multiples together numbers
    // Opcode 3 takes a single integer as input and saves it to the position
    // given by its only parameter
    // Opcode 4 outputs the value of its only parameter.
    // Opcode 7 is less than: if the first parameter is less than the second parameter,
    // it stores 1 in the position given by the third parameter. Otherwise, it stores 0.
    // Opcode 8 is equals: if the first parameter is equal to the second parameter,
    // it stores 1 in the position given by the third parameter. Otherwise, it stores 0.
    fn execute(&mut self, instruction: &Instruction, input: i64) -> i64 {
        let result = match instruction.operation {
            1 => self.value_for_param(0, instruction) + self.value_for_param(1, instruction),
            2 => self.value_for_param(0, instruction) * self.value_for_param(1, instruction),
            3 => input,
            4 => self.value_for_param(0, instruction),
            7 if self.value_for_param(0, instruction) < self.value_for_param(1, instruction) => 1,
            8 if self.value_for_param(0, instruction) == self.value_for_param(1, instruction) => 1,
            _ => 0,
        };

        self.update_base(&instruction);
        self.store_result(result, &instruction);
        self.advance_ip(&instruction);

        result
    }

    fn run(&mut self, input: i64) -> i64 {
        let mut output = 0;
        loop {
            let instruction = self.next_instruction();
            if instruction.is_halt() {
                self.halted = true;
                break output;
            }
            output = self.execute(&instruction, input);
            if instruction.is_output() {
                break output;
            }
        }
    }
}

impl Instruction {
    // Another static method, taking two arguments:
    fn new(opcode: i64, parameters: Vec<i64>) -> Instruction {
        let mut parameter_modes = vec![0; parameters.len()];
        for i in 0..parameters.len() {
            let exp = (i + 2) as u32;
            let divisor = 10_i64.pow(exp);
            parameter_modes[i] = (opcode / divisor) % 10
        }
        Instruction {
            operation: opcode % 100,
            parameters: parameters,
            parameter_modes: parameter_modes,
        }
    }

    fn count_parameters(opcode: i64) -> usize {
        match opcode % 100 {
            1 | 2 | 7 | 8 => 3,
            3 | 4 | 9 => 1,
            5 | 6 => 2,
            _ => 0,
        }
    }

    fn is_halt(&self) -> bool {
        self.operation == 99
    }

    fn is_output(&self) -> bool {
        self.operation == 4
    }
}

impl Robot {
    fn new(program: Program) -> Robot {
        Robot {
            current: (0, 0),
            panels: HashMap::new(),
            direction: Direction::Up,
            program: program,
        }
    }

    fn step(&mut self) {
        let (x, y) = match self.direction {
            Direction::Up => (0, 1),
            Direction::Right => (1, 0),
            Direction::Left => (-1, 0),
            Direction::Down => (0, -1),
        };
        self.current = (self.current.0 + x, self.current.1 + y)
    }

    fn turn(&mut self, n: i64) {
        // 0 means it should turn left 90 degrees, and 1 means it should turn right 90 degrees
        let new_direction = match self.direction {
            Direction::Up if n == 0 => Direction::Left,
            Direction::Up => Direction::Right,
            Direction::Right if n == 0 => Direction::Up,
            Direction::Right => Direction::Down,
            Direction::Left if n == 0 => Direction::Down,
            Direction::Left => Direction::Up,
            Direction::Down if n == 0 => Direction::Right,
            Direction::Down => Direction::Left,
        };
        self.direction = new_direction
    }

    fn paint(&mut self, colour: i64) {
        self.panels.insert(self.current, colour);
    }

    fn get_colour(&self, position: &(i64, i64)) -> i64 {
        if let Some(c) = self.panels.get(&position) {
            *c
        } else {
            0
        }
    }

    fn get_current_colour(&self) -> i64 {
        self.get_colour(&self.current)
    }

    fn run(&mut self) {
        loop {
            if self.program.halted {
                break;
            }

            let input = self.get_current_colour();
            let colour = self.program.run(input);
            let turn = self.program.run(input);

            self.paint(colour);
            self.turn(turn);
            self.step();
        }
    }
}

impl fmt::Display for Robot {
    // This trait requires `fmt` with this exact signature.
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let size = (self.panels.len() / 4) as i64;
        for x in -size..size {
            for y in -size..size {
                let colour = self.get_colour(&(x, y));
                write!(f, "{}", if colour == 0 { "." } else { "#" })?;
            }
            write!(f, "\n")?;
        }
        write!(f, "\n")
    }
}

fn read(path: &str) -> io::Result<String> {
    let mut file = File::open(path)?;
    let mut contents = String::new();
    file.read_to_string(&mut contents)?;
    Ok(contents)
}

fn parse(intcodes: String) -> Vec<i64> {
    intcodes
        .trim()
        .split(',')
        .map(|intcode| intcode.parse::<i64>().unwrap())
        .collect()
}

fn main() {
    let mut input = read("inputs/input11.txt").unwrap();
    let mut program = Program::new(parse(input));
    let mut robot = Robot::new(program);
    robot.run();
    // -- Part One --
    println!("Painted panels: {:?}", robot.panels.len());

    // -- Part Two --
    input = read("inputs/input11.txt").unwrap();
    program = Program::new(parse(input));
    robot = Robot::new(program);
    // Start on white
    robot.paint(1);
    robot.run();
    println!("{}", robot);
}

// rustc day11.rs
// RUST_BACKTRACE=1 ./day11
// Painted panels: 2343
// ............
// ....#.......
// ...#........
// ...#....#...
// ....#####...
// ............
// ...######...
// ......#.#...
// ......#.#...
// ........#...
// ............
// ...######...
// ...#..#.#...
// ...#..#.#...
// ....##.#....
// ............
// ...######...
// ...#..#.#...
// ...#..#.#...
// ...#....#...
// ............
// ...######...
// .....#..#...
// ....##..#...
// ...#..##....
// ............
// ...######...
// ...#..#.#...
// ...#..#.#...
// ....##.#....
// ............
// ....#####...
// ...#........
// ...#........
// ....#####...
// ............
// ...######...
// ......#.....
// ......#.....
// ...######...
// ............
