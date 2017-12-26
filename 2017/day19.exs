# --- Day 19: A Series of Tubes ---

#     |          
#     |  +--+    
#     A  |  C    
# F---|----E|--+ 
#     |  |  |  D 
#     +B-+  +--+ 

defmodule Network do

  def path(file) do
    network = network(file)
    travel(network, start(network), [])
  end

  def steps(file) do
    network = network(file)
    travel(network, start(network), 0)
  end

  defp travel(_, nil, result), do: result
  defp travel(network, {position, direction}, path) when is_list(path) do
    travel(network, next(network, position, direction), add_to_path(network, position, path))
  end
  defp travel(network, {position, direction}, count) when is_integer(count) do
    travel(network, next(network, position, direction), count + 1)
  end

  defp next(network, position, direction) do
    next = advance(network, position, direction)
    cond do
      next -> next
      vertical?(direction) -> advance(network, position, :right) || advance(network, position, :left)
      horizontal?(direction) -> advance(network, position, :up) || advance(network, position, :down)
    end
  end

  defp vertical?(direction), do: direction == :down || direction == :up
  defp horizontal?(direction), do: direction == :right || direction == :left

  defp advance(network, {i, j}, direction) do
    next = case direction do
      :down -> {i+1, j}
      :up -> {i-1, j}
      :left -> {i, j-1}
      :right -> {i, j+1}
    end
    if get(network, next), do: {next, direction}, else: nil
  end

  defp start(network) do
    [line|_] = network
    {{0, Enum.find_index(line, fn(x) -> x == 1 end)}, :down}
  end

  defp network(file) do
    lines(file)
    |> Enum.map(&parse_line/1)
  end

  defp add_to_path(network, position, path) do
    cell = get(network, position)
    if is_binary(cell), do: path ++ [cell], else: path
  end

  defp get(network, {i, j}) do
    [line|_] = network
    if i < 0 || i >= length(network) || j < 0 || j >= length(line) do
      nil
    else
      Enum.at(network, i) |> Enum.at(j)
    end
  end

  defp parse_line(line) do
    String.graphemes(line)
    |> Enum.map(&standardize/1)
  end

  defp standardize(character) do
    cond do
      character == " " -> nil
      String.match?(character, ~r/[\|\+\-]/) -> 1
      true -> character
    end
  end

  defp lines(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
  end
end

Network.path("./inputs/input19.txt") |> IO.puts

# --- Part Two ---

Network.steps("./inputs/input19.txt") |> IO.puts
