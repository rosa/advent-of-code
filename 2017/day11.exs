# --- Day 11: Hex Ed ---

#   \ n  /
# nw +--+ ne
#   /    \
# -+      +-
#   \    /
# sw +--+ se
#   / s  \

defmodule HexGrid do

  def steps(file) do
    path(file)
    |> go({0,0})
    |> distance({0,0})
  end

  def furthest(file) do
    path(file)
    |> go({0,0}, {0,0}, 0)
  end

  def distance({x, y}, {p, q}) do
    max(abs(x-p), abs(y-q)) |> round
  end

  def go([], current), do: current
  def go([move|path], current), do: go(path, next(current, move))

  def go([], _, _, max), do: max
  def go([move|path], current, start, max) do
    distance = distance(current, start)
    if distance > max do
      go(path, next(current, move), start, distance)
    else
      go(path, next(current, move), start, max)
    end
  end

  def next({x, y}, move) do
    # n: (+0, +1), s: (+0, -1)
    # ne: (+1, +0.5), nw: (-1, +0.5)
    # se: (+1, -0.5), sw: (-1, -0.5)
    case move do
      "n"  -> {x, y+1}
      "s"  -> {x, y-1}
      "ne" -> {x+1, y+0.5}
      "nw" -> {x-1, y+0.5}
      "se" -> {x+1, y-0.5}
      "sw" -> {x-1, y-0.5}
    end
  end

  defp path(file) do
    File.read!(file)
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)
  end
end

HexGrid.steps("./inputs/input11.txt") |> IO.puts

# --- Part Two ---

HexGrid.furthest("./inputs/input11.txt") |> IO.puts
