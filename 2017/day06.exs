# --- Day 6: Memory Reallocation ---

defmodule Memory do
  def reallocation_steps(banks) do
    steps(%{blocks(banks) => 0}, blocks(banks), 0)
  end

  defp steps(visited, current, n) do
    next = reallocate(current)
    if Map.has_key?(visited, next) do
      {n + 1, n - visited[next] + 1}
    else
      steps(Map.put(visited, next, n + 1), next, n + 1)
    end

  end

  defp reallocate(blocks) do
    max = Enum.max(blocks)
    start = Enum.find_index(blocks, fn(x) -> x == max end)
    reallocate(List.replace_at(blocks, start, 0), rem(start + 1, length(blocks)), max)
  end

  defp reallocate(blocks, _, nblocks) when nblocks == 0, do: blocks
  defp reallocate(blocks, i, nblocks) do 
    value = Enum.at(blocks, i)
    reallocate(List.replace_at(blocks, i, value + 1), rem(i + 1, length(blocks)), nblocks - 1)
  end

  defp blocks(banks) do
    String.split(banks, ~r{\s}, trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end

banks = "11  11  13  7 0 15  5 5 4 4 1 1 7 1 15  11"
Memory.reallocation_steps(banks) |> IO.inspect


