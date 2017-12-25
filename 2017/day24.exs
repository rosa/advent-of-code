# --- Day 24: Electromagnetic Moat ---

# For example, suppose you had the following components:

# 0/2
# 2/2
# 2/3
# 3/4
# 3/5
# 0/1
# 10/1
# 9/10
# With them, you could make the following valid bridges:

# 0/1
# 0/1--10/1
# 0/1--10/1--9/10
# 0/2
# 0/2--2/3
# 0/2--2/3--3/4
# 0/2--2/3--3/5
# 0/2--2/2
# 0/2--2/2--2/3
# 0/2--2/2--2/3--3/4
# 0/2--2/2--2/3--3/5

defmodule MagneticBridge do

  def strongest(file) do
    {components, symmetric_components} = components(file)
    
    build_graph(components)
    |> find_strongest_path(symmetric_components)
    |> elem(1)
  end

  def longest(file) do
    {components, symmetric_components} = components(file)
    
    build_graph(components)
    |> find_longest_path(symmetric_components)
    |> strength
  end

  defp components(file) do
    lines(file)
    |> Enum.map(&parse/1)
    |> extract_symmetric_components()
  end

  defp find_strongest_path(graph, symmetric_components) do
    {from, c} = root(graph)
    find_strongest_path({from, c}, Map.put(%{}, from, true), strength(from), [from], graph, symmetric_components)
  end
  defp find_strongest_path({from, c}, visited, total, path, graph, symmetric_components) do
    candidates = Enum.filter(graph[from], fn(x) -> !visited[x] end)
    |> Enum.filter(fn({p1, p2}) -> p1 == c || p2 == c end)
    |> Enum.map(fn({p1, p2}) -> {{p1, p2}, if(p1 == c, do: p2, else: p1)} end)

    if Enum.empty?(candidates) do
      {path, total + bonus(path, symmetric_components)}
    else
      candidates
      |> Enum.map(fn({x, y}) -> find_strongest_path({x, y}, Map.put(visited, x, true), total + strength(x), path ++ [x], graph, symmetric_components) end)
      |> Enum.max_by(fn({_, strength}) -> strength end)
    end
  end

  defp find_longest_path(graph, symmetric_components) do
    {from, c} = root(graph)
    find_longest_path({from, c}, Map.put(%{}, from, true), [from], graph, symmetric_components)    
  end
  defp find_longest_path({from, c}, visited, path, graph, symmetric_components) do
    candidates = Enum.filter(graph[from], fn(x) -> !visited[x] end)
    |> Enum.filter(fn({p1, p2}) -> p1 == c || p2 == c end)
    |> Enum.map(fn({p1, p2}) -> {{p1, p2}, if(p1 == c, do: p2, else: p1)} end)

    if Enum.empty?(candidates) do
      path ++ bonus_path(path, symmetric_components)
    else
      candidates
      |> Enum.map(fn({x, y}) -> find_longest_path({x, y}, Map.put(visited, x, true), path ++ [x], graph, symmetric_components) end)
      |> Enum.sort(&(strength(&1) > strength(&2)))
      |> Enum.max_by(fn(p) -> length(p) end)
    end
  end

  defp bonus(path, symmetric_components), do: bonus_path(path, symmetric_components) |> strength

  defp bonus_path(path, symmetric_components) do
    Enum.filter(symmetric_components, fn(s) -> Enum.any?(path, fn(p) -> compatible?(p, s) end) end)
  end

  # Our input just has one possible root, so this
  # simplification is possible. Otherwise we'd need
  # to calculate the strongest path for each root and
  # choose the strongest among them
  defp root(graph) do
    {r1, r2} = Map.keys(graph) |> Enum.find(fn {p1, p2} -> p1 == 0 || p2 == 0 end)
    {{r1, r2}, if(r1 == 0, do: r2, else: r1)}
  end

  defp build_graph(components), do: build_graph(%{}, components)
  defp build_graph(graph, []), do: graph
  defp build_graph(graph, [component|components]) do
    compatible = Map.keys(graph)
    |> Enum.filter(fn port -> compatible?(port, component) end)
    
    Map.put_new(graph, component, compatible)
    |> add_to_graph(component, compatible)
    |> build_graph(components)
  end

  defp add_to_graph(graph, port, []), do: Map.put_new(graph, port, [])
  defp add_to_graph(graph, port, [component|components]) do
    Map.put(graph, component, graph[component] ++ [port])
    |> add_to_graph(port, components)
  end

  defp extract_symmetric_components(components) do
    {Enum.filter(components, fn {p1, p2} -> p1 != p2 end), Enum.filter(components, fn {p1, p2} -> p1 == p2 end)}
  end

  defp strength({{p1, p2}, _}), do: p1 + p2
  defp strength({p1, p2}), do: p1 + p2
  defp strength(path) when is_list(path), do: Enum.map(path, &strength/1) |> Enum.sum

  defp compatible?(c1, c2), do: MapSet.intersection(MapSet.new(Tuple.to_list(c1)), MapSet.new(Tuple.to_list(c2))) |> Enum.any?

  defp parse(line) do
    # 0/2
    String.split(line, "/", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  defp lines(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
  end
end

MagneticBridge.strongest("input24.txt") |> IO.puts

# --- Part Two ---

MagneticBridge.longest("input24.txt") |> IO.inspect
