# --- Day 12: Garden Groups ---

defmodule Robots do
  def simulate_until_tree(robots, m, n), do: simulate_until_tree(robots, m, n, 0)
  def simulate_until_tree(robots, m, n, seconds) do
    if line?(robots, m, n) do
      print(robots, m, n)
      seconds
    else
      move(robots, m, n, 1)
      |> simulate_until_tree(m, n, seconds + 1)
    end
  end

  def simulate(robots, m, n, seconds) do
    move(robots, m, n, seconds)
    |> distribute(m, n)
    |> Enum.reduce(fn x, acc -> x * acc end)
  end

  defp line?(robots, _, n) do
    (0..n-1) |> Enum.any?(fn i -> line?(robots, i) end)
  end

  defp line?(robots, i) do
    counts = in_line(robots, i)
    |> Enum.sort()
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [p1, p2] -> elem(p2, 0) - elem(p1, 0) end)
    |> Enum.count(&(&1 == 1))

    counts >= 20
  end

  defp in_line(robots, i) do
    Enum.filter(robots, fn [{_, y}, _] -> y == i end)
    |> Enum.map(&hd/1)
  end

  defp print(robots, m, n) do
    (for x <- 0..m-1, y <- 0..n-1, do: representation(robots, y, x))
    |> Enum.chunk_every(n)
    |> Enum.map(&Enum.join/1)
    |> Enum.join("\n")
    |> IO.puts()

    robots
  end

  defp representation(robots, x, y) do
    if Enum.find(robots, fn [p, _] -> p == {x, y} end) do
      "#"
    else
      "."
    end
  end

  defp move(robots, _, _, 0), do: robots
  defp move(robots, m, n, seconds) do
    Enum.map(robots, fn robot -> move(robot, m, n) end)
    |> move(m, n, seconds - 1)
  end

  defp move([{x, y}, v={vx, vy}], m, n), do: [{step(x, vx, m), step(y, vy, n)}, v]

  defp step(x, vx, m) do
    cond do
      x + vx < 0 -> x + vx + m
      x + vx >= m -> Integer.mod(x + vx, m)
      true -> x + vx
    end
  end

  def distribute(robots, m, n) do
    quadrants(m, n)
    |> Enum.map(fn quadrant -> count_robots(quadrant, robots) end)
  end

  defp count_robots(quadrant, robots), do: Enum.count(robots, fn robot -> in_quadrant?(quadrant, robot) end)

  defp in_quadrant?({{lx1, lx2}, {ly1, ly2}}, [{x, y}, _]), do: x >= lx1 and x <= lx2 and y >= ly1 and y <= ly2

  defp quadrants(m, n) do
    hm = Integer.floor_div(m, 2)
    hn = Integer.floor_div(n, 2)

    [{{0, hm-1}, {0, hn-1}},
     {{hm+1, m-1}, {0, hn-1}},
     {{0, hm-1}, {hn+1, n-1}},
     {{hm+1, m-1}, {hn+1, n-1}}]
  end

  def read_robots(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
    |> Enum.map(&parse_robot/1)
  end

  defp parse_robot(line) do
    [_|r] = Regex.run(~r/p=(.+) v=(.+)/, line)
    Enum.map(r, &to_integer_tuple/1)
  end

  defp to_integer_tuple(line) do
    String.split(line, ",")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end
end

Robots.read_robots("inputs/input14.txt") |> Robots.simulate(101, 103, 100) |> IO.puts()

# --- Part Two ---

Robots.read_robots("inputs/input14.txt") |> Robots.simulate_until_tree(101, 103) |> IO.puts()
