#!/bin/awk
# --- Day 1: The Tyranny of the Rocket Equation ---
# --- Part Two ---

BEGIN { 
  total = 0;
  total_plus_fuel = 0;
}
{
  fuel = int($0/3) - 2
  total = total + fuel

  while (fuel > 0) {
    total_plus_fuel = total_plus_fuel + fuel
    fuel = int(fuel/3) - 2
  }
}
END {
  printf("Part One: %d\n", total)
  printf("Part Two: %d\n", total_plus_fuel)
}

# awk -f day01.awk inputs/input01.txt
# Part One: 3372756
# Part Two: 5056279
