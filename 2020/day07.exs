# --- Day 7: Handy Haversacks ---

defmodule Luggage do
  def required_bags(rules, colour), do: required_bags(Enum.into(rules, %{}), colour, 0)
  def required_bags(rules, colour, number) do
    rules[colour]
    |> Enum.map(fn {n, bag} -> n + n * required_bags(rules, bag, number) end)
    |> Enum.reduce(0, &(&1 + &2))
    |> Kernel.+(number)
  end

  def suitable_containers(rules, colour) do
    build_graph(rules)
    |> reachable_nodes(colour)
  end

  def reachable_nodes(graph, colour), do: reachable_nodes(graph, colour, MapSet.new)
  def reachable_nodes(graph, colour, nodes) do
    if Map.has_key?(graph, colour) do
      children = MapSet.new(Enum.map(graph[colour], &elem(&1, 1)))
      Enum.map(children, fn child -> reachable_nodes(graph, child, MapSet.put(nodes, child)) end)
      |> Enum.reduce(&(MapSet.union(&1, &2)))
    else
      nodes
    end
  end

  def build_graph(rules), do: build_graph(rules, %{})
  def build_graph([], graph), do: graph
  def build_graph([rule|rules], graph), do: build_graph(rules, insert_rule(rule, graph))

  def insert_rule({_, []}, graph), do: graph
  def insert_rule({container, [{quantity, colour}|contents]}, graph) do
    parents = graph[colour] || []
    insert_rule({container, contents}, graph)
    |> Map.put(colour, [{quantity, container} | parents])
  end

  def read_rules(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
    |> Enum.map(&parse_rule/1)
  end

  defp parse_rule(rule) do
    # light red bags contain 1 bright white bag, 2 muted yellow bags.
    # dotted orange bags contain 3 clear cyan bags, 5 shiny silver bags, 2 muted gold bags, 2 dim tomato bags.
    [_, container, contents] = Regex.run(~r{([\s\w]+) bags contain ([^.]+).}, rule)
    {container, parse_contents(contents)}
  end

  defp parse_contents("no other bags"), do: []
  defp parse_contents(contents) do
    String.split(contents, ",", trim: true)
    |> Enum.map(&parse_content/1)
  end

  defp parse_content(content) do
    [_, quantity, colour] = Regex.run(~r{(\d+) ([\s\w]+) bags?}, content)
    {String.to_integer(quantity), colour}
  end
end

Luggage.read_rules("inputs/input07.txt") |> Luggage.suitable_containers("shiny gold") |> MapSet.size |> IO.puts

# --- Part Two ---

Luggage.read_rules("inputs/input07.txt") |> Luggage.required_bags("shiny gold") |> IO.puts
