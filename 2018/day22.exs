# --- Day 22: Mode Maze ---

defmodule Cave do
  alias Cave.State

  def build(target, depth, dimensions \\ nil) do
    calculate_geologic_indexes(target, depth, dimensions)
    |> calculate_types()
  end

  # Risk level of each individual region: 0 for rocky regions, 1 for wet regions, and 2 for narrow regions.
  def risk(cave), do: Map.values(cave) |> Enum.sum()

  def shortest_path(cave, source, target), do: dijkstra(cave, source, target)

  def print(cave, mx, my) do
    for y <- 0..my do
      Enum.map(0..mx, fn x -> rep(cave[{x, y}]) end)
      |> Enum.join()
      |> IO.puts()
    end
    :ok
  end

  # rocky as ., wet as =, narrow as |
  defp rep(0), do: "."
  defp rep(1), do: "="
  defp rep(2), do: "|"
  defp rep(nil), do: "?"

  defp calculate_geologic_indexes(target, depth, dimensions) do
    {mx, my} = dimensions || target
    (for x <- (0..mx), y <- (0..my), do: {x, y})
    |> Enum.sort()
    |> Enum.reduce(%{}, fn region, acc -> Map.put(acc, region, erosion(acc, target, region, depth)) end)
  end

  defp calculate_types(cave) do
    Enum.reduce(cave, %{}, fn {k, gi}, acc -> Map.put(acc, k, rem(gi, 3)) end)
  end

  # The region at 0,0 (the mouth of the cave) has a geologic index of 0.
  defp gi(_cave, _target, {0, 0}, _depth), do: 0
  # The region at the coordinates of the target has a geologic index of 0.
  defp gi(_cave, target, region, _depth) when target == region, do: 0
  # If the region's Y coordinate is 0, the geologic index is its X coordinate times 16807.
  defp gi(_cave, _target, {x, 0}, _depth), do: x * 16807
  # If the region's X coordinate is 0, the geologic index is its Y coordinate times 48271.
  defp gi(_cave, _target, {0, y}, _depth), do: y * 48271
  # Otherwise, the region's geologic index is the result of multiplying the erosion levels of the regions at X-1,Y and X,Y-1.
  defp gi(cave, target, {x, y}, depth), do: erosion(cave, target, {x-1, y}, depth) * erosion(cave, target, {x, y-1}, depth)
  # A region's erosion level is its geologic index plus the cave system's depth, all modulo 20183
  defp erosion(cave, target, region, depth), do: cave[region] || (gi(cave, target, region, depth) + depth |> rem(20183))


  def dijkstra(cave, source, target), do: dijkstra(cave, target, MapSet.new(), %{source => 0}, %{})
  def dijkstra(cave, target, visited, distances, previous) do
    candidates = Enum.filter(distances, fn {state, _} -> state not in visited end)
    {u, _} = Enum.min_by(candidates, fn {_, distance} -> distance end)

    if u == target do
      {distances[u], build_path(target, previous)}
    else
      neighbours = State.neighbours(u, cave) |> Enum.filter(fn v -> v not in visited end)
      {updated_distances, updated_previous} = update_distances_and_previous({distances, previous}, u, neighbours)

      dijkstra(cave, target, MapSet.put(visited, u), updated_distances, updated_previous)
    end
  end
  
  def update_distances_and_previous(result, _u, []), do: result
  def update_distances_and_previous(result = {distances, previous}, u, [v | neighbours]) do
    alt = distances[u] + State.distance(u, v)
    if is_nil(distances[v]) || alt < distances[v] do
      {Map.put(distances, v, alt), Map.put(previous, v, u)} |> update_distances_and_previous(u, neighbours)
    else
      update_distances_and_previous(result, u, neighbours)
    end
  end

  defp build_path(target, prev), do: build_path(target, prev, [])
  defp build_path(nil, _prev, path), do: path
  defp build_path(target, prev, path), do: build_path(prev[target], prev, [target | path])  
end

defmodule Cave.State do
  defstruct(
    tool: :neither, # or :climbing, or :torch
    position: nil
  )

  def new(tool, position) do
    %Cave.State{
      tool: tool,
      position: position
    }
  end

  def neighbours(state, cave) do
    # Move or change tool to change state
    moving(state, cave) ++ changing_tool(state, cave)
  end

  # Switching to using the climbing gear, torch, or neither always takes seven minutes, regardless of which tools you start with.
  # Moving to an adjacent region takes one minute.
  def distance(state, neighbour) do
    cond do
      state == neighbour -> 0
      state.position == neighbour.position -> 7
      state.tool == neighbour.tool -> 1
    end
  end

  def moving(%{tool: tool, position: position}, cave) do
    # Can only move to wet or narrow (1 or 2)
    moves(position, cave)
    |> Enum.filter(fn destination -> cave[destination] in allowed_in(tool) end)
    |> Enum.reduce([], fn destination, acc -> [new(tool, destination) | acc] end)
  end

  # In rocky regions, you can use the climbing gear or the torch. You cannot use neither (you'll likely slip and fall).
  # In wet regions, you can use the climbing gear or neither tool. You cannot use the torch (if it gets wet, you won't have a light source).
  # In narrow regions, you can use the torch or neither tool. You cannot use the climbing gear (it's too bulky to fit).
  def allowed_in(tool) do
    case tool do
      :neither -> [1, 2]
      :climbing -> [0, 1]
      :torch -> [0, 2]
    end
  end

  def moves({x, y}, cave) do
    [{-1, 0}, {0, -1}, {1, 0}, {0, 1}]
    |> Enum.map(fn {xi, yi} -> {x + xi, y + yi} end)
    |> Enum.reject(fn {xd, yd} -> xd < 0 || yd < 0 || is_nil(cave[{xd, yd}]) end)
  end

  # You can change your currently equipped tool or put both away if your new equipment would be valid for your current region.
  def changing_tool(%{tool: :neither, position: position}, cave) do
    case cave[position] do 
      1 -> [new(:climbing, position)]
      2 -> [new(:torch, position)]
    end
  end
  def changing_tool(%{tool: :climbing, position: position}, cave) do
    case cave[position] do 
      0 -> [new(:torch, position)]
      1 -> [new(:neither, position)]
    end
  end
  def changing_tool(%{tool: :torch, position: position}, cave) do
    case cave[position] do 
      0 -> [new(:climbing, position)]
      2 -> [new(:neither, position)]
    end
  end
end

# Puzzle input
# depth: 8112
# target: 13,743
Cave.build({13, 743}, 8112)
|> Cave.risk()
|> IO.puts()

# --- Part Two ---
# You start at 0,0 (the mouth of the cave) with the torch equipped
# Finally, once you reach the target, you need the torch equipped before you can find him in the dark.
Cave.build({13, 743}, 8112, {100, 1000})
|> Cave.shortest_path(Cave.State.new(:torch, {0, 0}), Cave.State.new(:torch, {13, 743}))
|> elem(0)
|> IO.puts()
