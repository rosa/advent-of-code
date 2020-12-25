# --- Day 23: Crab Cups ---

defmodule Cups do
  def cups_after(circle, n), do: cups_after(circle, n, circle[n], [])
  def cups_after(_, n, n, cups), do: cups
  def cups_after(circle, n, next, cups), do: cups_after(circle, n, circle[next], cups ++ [next])

  # Each move, the crab does the following actions:
  # - The crab picks up the three cups that are immediately clockwise of the current cup.
  #   They are removed from the circle; cup spacing is adjusted as necessary to maintain the circle.
  # - The crab selects a destination cup: the cup with a label equal to the current cup's label minus one.
  #   If this would select one of the cups that was just picked up, the crab will keep subtracting one until
  #   it finds a cup that wasn't just picked up. If at any point in this process the value goes below the
  #   lowest value on any cup's label, it wraps around to the highest value on any cup's label instead.
  # - The crab places the cups it just picked up so that they are immediately clockwise of the destination cup.
  #   They keep the same order as when they were picked up.
  # - The crab selects a new current cup: the cup which is immediately clockwise of the current cup.
  def simulate(circle, _, 0), do: circle
  def simulate(circle, current, moves) do
    {updated_circle, picked_cups} = pick_3_cups(circle, current)

    select_destination_cup(updated_circle, current - 1, picked_cups)
    |> insert_picked_cups(updated_circle, picked_cups)
    |> simulate(get(updated_circle, current), moves - 1)
  end

  def init(cups) do
    Enum.with_index(cups)
    |> Enum.map(fn {cup, index} -> {cup, Enum.at(cups, incr(index, cups))} end)
    |> Enum.into(%{})
  end

  def pick_3_cups(circle, current), do: pick_3_cups(circle, current, get(circle, current), [])
  def pick_3_cups(circle, current, next, picked_cups) do
    if Enum.count(picked_cups) == 3 do
      {circle, picked_cups}
    else
      Map.delete(circle, next)
      |> Map.put(current, get(circle, next))
      |> pick_3_cups(current, get(circle, next), picked_cups ++ [next])
    end
  end

  def select_destination_cup(circle, candidate, picked_cups) do
    cond do
      candidate in picked_cups -> select_destination_cup(circle, candidate - 1, picked_cups)
      candidate < 1 -> select_destination_cup(circle, Enum.max(Map.keys(circle)), picked_cups)
      true -> candidate
    end
  end

  def insert_picked_cups(destination, circle, [cup1, cup2, cup3]) do
    Map.put(circle, destination, cup1)
    |> Map.put(cup1, cup2)
    |> Map.put(cup2, cup3)
    |> Map.put(cup3, get(circle, destination))
  end

  def get(circle, key) do
    if Map.has_key?(circle, key) do
      Map.get(circle, key)
    else
      key + 1
    end
  end

  def incr(position, cups), do: rem(position + 1, Enum.count(cups))
end

cups = String.graphemes("653427918") |> Enum.map(&String.to_integer/1)
Cups.init(cups) |> Cups.simulate(List.first(cups), 100) |> Cups.cups_after(1) |> Enum.join |> IO.puts

# --- Part Two ---

cups = String.graphemes("653427918") |> Enum.map(&String.to_integer/1)
current = List.first(cups)
circle = Cups.init(cups) |> Map.put(List.last(cups), 10) |> Map.put(1_000_000, current) |> Cups.simulate(current, 10_000_000)
circle[1] * circle[circle[1]] |> IO.puts
