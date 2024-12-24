# --- Day 23: LAN Party ---

defmodule LAN do
  def maximal_clique(graph), do: maximal_clique(graph, Map.keys(graph), [], MapSet.new(), MapSet.new())
  def maximal_clique(_, [], [], _, maximal), do: maximal
  def maximal_clique(graph, [v|starters], [], current, maximal) do
    if MapSet.size(current) > MapSet.size(maximal) do
      maximal_clique(graph, starters, Map.keys(graph), MapSet.new([v]), current)
    else
      maximal_clique(graph, starters, Map.keys(graph), MapSet.new([v]), maximal)
    end
  end
  def maximal_clique(graph, starters, [v|nodes], current, maximal) do
    if connected_to_all?(graph, v, current) do
      maximal_clique(graph, starters, nodes, MapSet.put(current, v), maximal)
    else
      maximal_clique(graph, starters, nodes, current, maximal)
    end
  end

  defp connected_to_all?(graph, v, nodes), do: Enum.all?(nodes, fn u -> connected?(graph, u, v) end)

  defp connected?(graph, u, v), do: u in Map.get(graph, v)

  defp groups_of_three(graph), do: groups_of_three(graph, Map.keys(graph), MapSet.new())
  defp groups_of_three(_, [], groups), do: groups
  defp groups_of_three(graph, [v|nodes], groups) do
    updated_groups = MapSet.union(groups, interconnected(graph, v, Map.get(graph, v)))
    groups_of_three(graph, nodes, updated_groups)
  end

  defp interconnected(graph, v, cons), do: interconnected(graph, v, cons, MapSet.new())
  defp interconnected(_, _, [], groups), do: groups
  defp interconnected(graph, v, [c|cons], groups) do
    new_group = Map.get(graph, c) |> Enum.filter(fn d -> v in Map.get(graph, d) end)
    |> Enum.map(fn d -> Enum.sort([v, c, d]) end)
    |> MapSet.new()
    interconnected(graph, v, cons, MapSet.union(groups, new_group))
  end

  def one_with_t(graph) do
    groups_of_three(graph)
    |> Enum.filter(fn c -> Enum.any?(c, fn x -> String.starts_with?(x, "t") end) end)
  end

  defp build_graph(edges), do: build_graph(edges, %{})
  defp build_graph([], graph), do: graph
  defp build_graph([[v1, v2]|edges], graph) do
    updated_graph = Map.update(graph, v1, [v2], fn ns -> ns ++ [v2] end)
    |> Map.update(v2, [v1], fn ns -> ns ++ [v1] end)

    build_graph(edges, updated_graph)
  end

  def read_connections(path) do
    File.read!(path)
    |> String.split(~r{\n}, trim: true)
    |> Enum.map(&(String.split(&1, "-")))
    |> build_graph()
  end
end

LAN.read_connections("inputs/input23.txt") |> LAN.one_with_t() |> Enum.count() |> IO.puts()

# --- Part Two ---

LAN.read_connections("inputs/input23.txt") |> LAN.maximal_clique() |> Enum.sort() |> Enum.join(",") |> IO.puts()
