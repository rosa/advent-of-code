# --- Day 21: Fractal Art ---

# .#.
# ..#
# ###

# Then, the program repeats the following process:

# If the size is evenly divisible by 2, break the pixels up into 2x2 squares,
# and convert each 2x2 square into a 3x3 square by following the corresponding enhancement rule.
# Otherwise, the size is evenly divisible by 3; break the pixels up into 3x3 squares,
# and convert each 3x3 square into a 4x4 square by following the corresponding enhancement rule.

# sometimes, one must rotate or flip the input pattern to find a match.

# ../.#  =  ..
#           .#

#                 .#.
# .#./..#/###  =  ..#
#                 ###

#                         #..#
# #..#/..../#..#/.##.  =  ....
#                         #..#
#                         .##.

# Match the same rule
# .#.   .#.   #..   ###
# ..#   #..   #.#   ..#
# ###   ###   ##.   .#.
defmodule ArtGrid do

  def on_after_play(file, iterations) do
    play(file, iterations)
    |> Enum.map(&on_count/1)
    |> Enum.sum()
  end

  def play(file, iterations) do
    rules(file)
    |> iterate(start(), 0, iterations)
  end

  def iterate(_, position, iterations, iterations), do: merge(position)
  def iterate(rules, position, iteration, iterations) do
    # A position is made of squares. Divide each square in several squares
    # and enhance each square
    squares = merge(position)
    |> divide()
    |> Enum.map(fn(square) -> enhance(rules, square) end)
    iterate(rules, squares, iteration + 1, iterations)
  end

  def divide(square) when length(square) <= 3, do: [square]
  def divide(square) do
    size = if rem(length(square), 2) == 0, do: 2, else: 3
    # divide rows
    Enum.chunk_every(square, size)
    |> Enum.flat_map(fn(rows) -> divide_vertical(rows, size) end)
  end
  def divide_vertical([row|rows], size), do: divide_vertical([row|rows], size, 0, length(row), [])
  def divide_vertical(_, _, total, total, squares), do: squares
  def divide_vertical(rows, size, offset, total, squares) do
    square = Enum.map(rows, fn(row) -> Enum.slice(row, offset, size) end)
    divide_vertical(rows, size, offset + size, total, squares ++ [square])
  end

  def merge(squares) when length(squares) <= 1, do: squares |> Enum.at(0)
  def merge(squares) do
    size = :math.sqrt(length(squares)) |> round
    Enum.chunk_every(squares, size)
    |> Enum.flat_map(fn(row_of_squares) -> merge_row(row_of_squares) end)
  end
  def merge_row([square|squares]), do: merge_row([square|squares], 0, length(square), [])
  def merge_row(_, total, total, merged), do: merged
  def merge_row(squares, offset, total, merged) do
    new_row = Enum.map(squares, fn(sq) -> Enum.at(sq, offset) end) |> Enum.concat
    merge_row(squares, offset + 1, total, merged ++ [new_row])
  end

  def enhance(rules, square) do
    Enum.find(rules, fn([input, _]) -> applicable?(input, square) end)
    |> apply_rule()
  end

  def applicable?(input, square) do
    square == input || flip(input) == square ||
    Enum.any?([&flip/1, &(&1)], fn(f) -> Enum.any?([1, 2, 3], fn(x) -> rotate(f.(input), x) == square end) end)
  end

  def flip(square), do: Enum.map(square, &Enum.reverse/1)

  # a1 a2 a3  1   c1 b1 a1   2  c3 c2 c1   3  a3 b3 c3
  # b1 b2 b3 -->  c2 b2 a2  --> b3 b2 b1  --> a2 b2 c2
  # c1 c2 c3      c3 b3 a3      a3 a2 a1      a1 b1 c1
  def rotate([[a1, a2, a3], [b1, b2, b3], [c1, c2, c3]], count) do
    case count do
      1 -> [[c1, b1, a1], [c2, b2, a2], [c3, b3, a3]]
      2 -> [[c3, c2, c1], [b3, b2, b1], [a3, a2, a1]]
      3 -> [[a3, b3, c3], [a2, b2, c2], [a1, b1, c1]]
    end
  end

  # a1 a2  1   b1 a1  2   b2 b1  3   a1 b2
  # b1 b2 -->  b2 a2 -->  a2 a1 -->  a2 b1
  def rotate([[a1, a2], [b1, b2]], count) do
    case count do
      1 -> [[b1, a1], [b2, a2]]
      2 -> [[b2, b1], [a2, a1]]
      3 -> [[a1, b2], [a2, b1]]
    end
  end

  def apply_rule([_, output]), do: output

  def on_count(square), do: List.flatten(square) |> Enum.count(fn(x) -> x == "#" end)

  def start(), do: parse(".#./..#/###")

  def rules(file), do: lines(file) |> Enum.map(&parse/1)

  # ../.# => ##./#../...
  # .#./..#/### => #..#/..../..../#..#
  def parse(line) do
    String.split(line, " => ")
    |> Enum.map(&pixels/1)
  end

  def pixels(line) do
    String.split(line, "/")
    |> Enum.map(&String.graphemes/1)
  end

  defp lines(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
  end
end

ArtGrid.on_after_play("./inputs/input21.txt", 5) |> IO.puts

# --- Part Two ---

ArtGrid.on_after_play("./inputs/input21.txt", 18) |> IO.puts
