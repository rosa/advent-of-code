# --- Day 12: Digital Plumber ---

# 0 <-> 2
# 1 <-> 1
# 2 <-> 0, 3, 4
# 3 <-> 2, 4
# 4 <-> 2, 3, 6
# 5 <-> 6
# 6 <-> 4, 5

# In this example, the following programs are in the group that contains program ID 0:

# Program 0 by definition.
# Program 2, directly connected to program 0.
# Program 3 via program 2.
# Program 4 via program 2.
# Program 5 via programs 6, then 4, then 2.
# Program 6 via programs 4, then 2.

defmodule Pipes do

  def group_0_size(file) do
    lines(file)
    |> build_graph()
    |> bfs("0")
    |> Enum.count
  end

  def groups(file) do
    lines(file)
    |> build_graph()
    |> all_bfs()
  end

  defp all_bfs(graph), do: all_bfs(graph, Map.keys(graph), [])

  defp all_bfs(_, [], groups), do: groups
  defp all_bfs(graph, [next|nodes], groups) do
    group = bfs(graph, next)
    all_bfs(graph, list_difference(nodes, group), groups ++ [group])
  end

  defp bfs(graph, root), do: bfs(graph, [root], [])

  defp bfs(_, [], nodes), do: nodes
  defp bfs(graph, [next|stack], nodes) do
    bfs(graph, stack ++ list_difference(graph[next], nodes), Enum.uniq(nodes ++ [next]))
  end

  defp list_difference(list1, list2) do
    MapSet.difference(MapSet.new(list1), MapSet.new(list2))
    |> MapSet.to_list
  end

  defp build_graph(lines) do
    build_graph(%{}, lines)
  end

  defp build_graph(graph, []), do: graph
  defp build_graph(graph, [line|lines]) do
    extract_edges(line)
    |> add_edges(graph)
    |> build_graph(lines)
  end

  defp add_edges({_, []}, graph), do: graph
  defp add_edges({v1, [v2|nodes]}, graph) do
    new_graph = add_edges({v1, nodes}, graph)
    |> Map.put_new(v1, MapSet.new)
    |> Map.put_new(v2, MapSet.new)

    Map.put(new_graph, v1, MapSet.union(new_graph[v1], MapSet.new([v2])))
    |> Map.put(v2, MapSet.union(new_graph[v2], MapSet.new([v1])))
  end

  defp extract_edges(line) do
    [node|nodes] = String.split(line, " <-> ", trim: true)
    {node, String.split(hd(nodes), ", ", trim: true)}
  end

  defp lines(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
  end
end


Pipes.group_0_size("./inputs/input12.txt") |> IO.puts

# --- Part Two ---

Pipes.groups("./inputs/input12.txt") |> Enum.count |> IO.puts


