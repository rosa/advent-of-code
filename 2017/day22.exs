# --- Day 22: Sporifica Virus ---

# The virus carrier works in bursts; in each burst, it wakes up, does some work, and goes back to sleep.
# The following steps are all executed in order one time each burst:
# - If the current node is infected, it turns to its right. Otherwise, it turns to its left.
# (Turning is done in-place; the current node does not change.)
# - If the current node is clean, it becomes infected. Otherwise, it becomes cleaned.
# (This is done after the node is considered for the purposes of changing direction.)
# The virus carrier moves forward one node in the direction it is facing.

# The virus carrier begins in the middle of the map facing up.

defmodule InfectedCluster do

  def infection_bursts(file, bursts, simulation) do
    lines(file)
    |> cluster()
    |> run(bursts, simulation)
  end

  defp run(cluster, bursts, simulation), do: simulation.(map(cluster), {center(cluster), :up}, 0, 0, bursts)

  def simulate_simple(_, _, infections, bursts, bursts), do: infections
  def simulate_simple(cluster, state, infections, burst, bursts) do
    {current, _} = state
    case get(cluster, current) do
      "#" -> replace(cluster, current, ".") |> simulate_simple(move(state, :right), infections, burst + 1, bursts)
      "." -> replace(cluster, current, "#") |> simulate_simple(move(state, :left), infections + 1, burst + 1, bursts)
    end
  end

  def simulate_complex(_, _, infections, bursts, bursts), do: infections
  def simulate_complex(cluster, state, infections, burst, bursts) do
    {current, _} = state
    case get(cluster, current) do
      # Clean nodes become weakened.
      # Weakened nodes become infected.
      # Infected nodes become flagged.
      # Flagged nodes become clean.
      # Decide which way to turn based on the current node:
      # If it is clean, it turns left.
      # If it is weakened, it does not turn, and will continue moving in the same direction.
      # If it is infected, it turns right.
      # If it is flagged, it reverses direction, and will go back the way it came.
      "#" -> replace(cluster, current, "F") |> simulate_complex(move(state, :right), infections, burst + 1, bursts)
      "W" -> replace(cluster, current, "#") |> simulate_complex(move(state, :not_turn), infections + 1, burst + 1, bursts)
      "F" -> replace(cluster, current, ".") |> simulate_complex(move(state, :reverse), infections, burst + 1, bursts)
      "." -> replace(cluster, current, "W") |> simulate_complex(move(state, :left), infections, burst + 1, bursts)
    end
  end

  defp replace(cluster, cell, value) do
    Map.put(cluster, cell, value)
  end

  defp move({{i, j}, direction}, turn_to) do
    facing = get_in(turns(), [turn_to, direction])
    next = case facing do
      :down -> {i+1, j}
      :up -> {i-1, j}
      :left -> {i, j-1}
      :right -> {i, j+1}
    end
    {next, facing}
  end

  defp turns() do
    %{left: %{
        down: :right,
        up: :left,
        left: :down,
        right: :up
      },
      right: %{
        down: :left,
        up: :right,
        left: :up,
        right: :down
      },
      not_turn: %{
        down: :down,
        up: :up,
        left: :left,
        right: :right
      },
      reverse: %{
        down: :up,
        up: :down,
        left: :right,
        right: :left
      }
    }    
  end

  defp get(cluster, cell), do: cluster[cell] || "."

  defp center([[_|row]|cluster]), do: { round(length(cluster)/2), round(length(row)/2) }

  defp cluster(lines) do
    Enum.map(lines, &String.graphemes/1)
  end

  defp map(cluster), do: map(cluster, %{}, 0, length(cluster))
  defp map(_, cluster_as_map, n, n), do: cluster_as_map
  defp map(cluster, cluster_as_map, i, n) do
    row = Enum.at(cluster, i)
    infected = Enum.to_list(0..length(row)-1)
    |> Enum.filter(fn(j) -> Enum.at(row, j) == "#" end)
    |> Enum.map(fn(j) -> {i, j} end)
    |> Map.new(fn(cell) -> {cell, "#"} end)
    map(cluster, Map.merge(cluster_as_map, infected), i+1, n)
  end

  defp lines(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
  end
end

InfectedCluster.infection_bursts("input22.txt", 10_000, &InfectedCluster.simulate_simple/5) |> IO.puts

# --- Part Two ---

InfectedCluster.infection_bursts("input22.txt", 10_000_000, &InfectedCluster.simulate_complex/5) |> IO.puts
