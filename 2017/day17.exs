# --- Day 17: Spinlock ---

# It starts with a circular buffer containing only the value 0, which it marks as the current position.
# It then steps forward through the circular buffer some number of steps (your puzzle input) before
# inserting the first new value, 1, after the value it stopped on.
# The inserted value becomes the current position.
# It repeats this process of stepping forward, inserting a new value, and using the location of the
# inserted value as the new current position a total of 2017 times, inserting 2017 as its final operation,
# and ending with a total of 2018 values (including 0) in the circular buffer.

# Example with 3 steps:
# (0), the initial state before any insertions.
# 0 (1): the spinlock steps forward three times (0, 0, 0), and then inserts the first value, 1, after it. 1 becomes the current position.
# 0 (2) 1: the spinlock steps forward three times (0, 1, 0), and then inserts the second value, 2, after it. 2 becomes the current position.
# 0  2 (3) 1: the spinlock steps forward three times (1, 0, 2), and then inserts the third value, 3, after it. 3 becomes the current position.
# And so on:

# 0  2 (4) 3  1
# 0 (5) 2  4  3  1
# 0  5  2  4  3 (6) 1
# 0  5 (7) 2  4  3  6  1
# 0  5  7  2  4  3 (8) 6  1
# 0 (9) 5  7  2  4  3  8  6  1

defmodule SpinLock do

  def after_last(steps, insertions), do: complete_circular_buffer([0], 0, 1, steps, insertions)

  def after_zero(steps, insertions), do: run(steps, 0, 0, 1, nil, insertions)

  def run(_, _, _, insertions, value_after_zero, insertions), do: value_after_zero
  def run(steps, position, position_of_zero, next, value_after_zero, insertions) do
    new_position = rem(position + steps, next) + 1
    cond do
      new_position <= position_of_zero -> run(steps, new_position, position_of_zero + 1, next + 1, value_after_zero, insertions)
      new_position == position_of_zero + 1 -> run(steps, new_position, position_of_zero, next + 1, next, insertions)
      new_position > position_of_zero + 1 -> run(steps, new_position, position_of_zero, next + 1, value_after_zero, insertions)
    end
  end

  def complete_circular_buffer(buffer, position, insertions, _, insertions), do: Enum.at(buffer, circular_index(buffer, position + 1))
  def complete_circular_buffer(buffer, position, value, steps, insertions) do
    new_position = circular_index(buffer, position + steps) + 1
    List.insert_at(buffer, new_position, value)
    |> complete_circular_buffer(new_position, value + 1, steps, insertions)
  end

  defp circular_index(enumerable, index), do: rem(index, length(enumerable))
end

steps = 335
SpinLock.after_last(steps, 2018) |> IO.puts

# --- Part Two ---

# What is the value after 0 the moment 50000000 is inserted?
SpinLock.after_zero(steps, 50_000_001) |> IO.puts
