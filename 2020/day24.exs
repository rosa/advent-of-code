# --- Day 24: Lobby Layout ---

defmodule Layout do
  def simulate(layout, 0), do: layout
  def simulate(layout, days) do
    next_layout =
      layout
      |> limits
      |> all_tiles
      |> Enum.map(fn tile -> {tile, next_state(tile, layout)} end)
      |> Enum.into(%{})

    Map.merge(layout, next_layout)
    |> simulate(days - 1)
  end

  def init(tiles), do: init(%{}, tiles)
  def init(layout, []), do: layout
  def init(layout, [tile|tiles]) do
    Map.update(layout, identify(tile), :black, &opposite/1)
    |> init(tiles)
  end

  def read_tiles(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
    |> Enum.map(&parse_directions/1)
  end

  defp limits(layout) do
    Map.keys(layout)
    |> Enum.map(&Tuple.to_list/1)
    |> List.flatten
    |> Enum.min_max
  end

  defp next_state(tile, layout) do
    black_neighbours =
      tile
      |> neighbours
      |> Enum.map(fn neighbour -> Map.get(layout, neighbour, :white) end)
      |> Enum.count(&(&1 == :black))

    current = Map.get(layout, tile, :white)

    cond do
      # Any white tile with exactly 2 black tiles immediately adjacent to it is flipped to black.
      current == :white && black_neighbours == 2 -> :black
      # Any black tile with zero or more than 2 black tiles immediately adjacent to it is flipped to white.
      current == :black && (black_neighbours == 0 || black_neighbours > 2) -> :white
      true -> current
    end
  end

  defp neighbours(tile) do
    ~w[e se sw w nw ne]
    |> Enum.map(fn direction -> move(direction, tile) end)
  end

  defp all_tiles({from, to}) do
    (from - 1)..(to + 1)
    |> Enum.map(fn y -> horizontal_tiles(y, from, to) end)
    |> List.flatten
  end

  defp horizontal_tiles(y, from, to) do
    horizontal_start(y, from)..horizontal_end(y, to)
    |> Enum.take_every(2)
    |> Enum.map(fn x -> {x, y} end)
  end

  defp horizontal_start(a, b), do: if abs(rem(a, 2)) == abs(rem(b, 2)), do: b, else: b - 1
  defp horizontal_end(a, b), do: if abs(rem(a, 2)) == abs(rem(b, 2)), do: b, else: b + 1

  defp opposite(:black), do: :white
  defp opposite(:white), do: :black

  defp identify(tile), do: identify(tile, {0,0})
  defp identify([], location), do: location
  defp identify([direction|directions], location), do: identify(directions, move(direction, location))

  defp move(direction, {x, y}) do
    case direction do
      "e"  -> {x + 2, y}
      "se" -> {x + 1, y - 1}
      "sw" -> {x - 1, y - 1}
      "w"  -> {x - 2, y}
      "nw" -> {x - 1, y + 1}
      "ne" -> {x + 1, y + 1}
    end
  end

  defp parse_directions(line) do
    Regex.scan(~r{(e|se|sw|w|nw|ne)}, line, capture: :all_but_first)
    |> List.flatten
  end
end

layout = Layout.read_tiles("inputs/input24.txt") |> Layout.init
Map.values(layout) |> Enum.count(&(&1 == :black)) |> IO.puts

# --- Part Two ---

Layout.simulate(layout, 100) |> Map.values |> Enum.count(&(&1 == :black)) |> IO.puts
