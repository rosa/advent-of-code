# --- Day 12: Garden Groups ---

defmodule Claw do
  alias Claw.Machine

  def all_prizes(machines), do: Enum.map(machines, &Machine.solve/1) |> Enum.sum()

  defp machine([button_a, button_b, prize], extra), do: Machine.new(button_a, button_b, prize, extra)

  def read_machines(file, extra \\ 0) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
    |> Enum.chunk_every(3)
    |> Enum.map(fn m -> machine(m, extra) end)
  end
end

defmodule Claw.Machine do
  defstruct(
    button_a: {0, 0},
    button_b: {0, 0},
    prize: {0, 0}
  )

  def new(button_a, button_b, prize, extra) do
    %Claw.Machine{
      button_a: parse_button(button_a),
      button_b: parse_button(button_b),
      prize: parse_prize(prize, extra)
    }
  end
  def solve(machine) do
    {a1, a2} = machine.button_a
    gcd = Integer.gcd(a1, a2)
    m1 = Integer.floor_div(a1, gcd)
    m2 = Integer.floor_div(a2, gcd)

    {b1, b2} = machine.button_b
    {c1, c2} = machine.prize

    y = (c1*m2 - c2*m1) / (b1*m2 - b2*m1)
    x = (c1 - b1*y) / a1
    if floor(y) == y and floor(x) == x and y > 0 and x > 0 do
      floor(3*x + y)
    else
      0
    end
  end

  defp parse_button(line) do
    [_, x, y] = Regex.run(~r/X\+(\d+), Y\+(\d+)/, line)
    tuple(x, y)
  end

  defp parse_prize(line, extra) do
    [_, x, y] = Regex.run(~r/X=(\d+), Y=(\d+)/, line)
    {p, q} = tuple(x, y)
    {p + extra, q + extra}
  end

  defp tuple(x, y), do: {String.to_integer(x), String.to_integer(y)}
end

Claw.read_machines("inputs/input13.txt") |> Claw.all_prizes() |> IO.puts

# --- Part Two ---

Claw.read_machines("inputs/input13.txt", 10000000000000) |> Claw.all_prizes() |> IO.puts
