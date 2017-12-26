# --- Day 7: Recursive Circus ---

# pbga (66)
# xhth (57)
# ebii (61)
# havc (66)
# ktlj (57)
# fwft (72) -> ktlj, cntj, xhth
# qoyq (66)
# padx (45) -> pbga, havc, qoyq
# tknk (41) -> ugml, padx, fwft
# jptl (61)
# ugml (68) -> gyxo, ebii, jptl
# gyxo (61)
# cntj (57)

defmodule Tower do
  def bottom_program(filename) do
    build_tree(lines(filename))
    |> Enum.find(fn {_, v} -> v == nil end)
    |> elem(0)
  end

  def right_weight(filename, root) do
    {tree, weights} = build_tree_with_weights(lines(filename), %{}, %{})
    find_intruder(tree, weights, root, nil)
  end

  defp find_intruder(_, _, _, bad) when not is_nil(bad), do: bad
  defp find_intruder(tree, weights, root, nil) do
    weight_branches(tree, weights, root)
  end

  defp weight_branches(tree, weights, root) do
    if Map.has_key?(tree, root) do
      branches = Enum.map(tree[root], fn(x) -> weight_branches(tree, weights, x) end)
      if length(Enum.uniq(branches)) > 1 do
        intruder_index = find_different_index(branches)
        right_weight = Enum.at(branches, rem(intruder_index + 1, length(branches)))
        correction = Enum.at(branches, intruder_index) - right_weight
        bad = weights[Enum.at(tree[root], intruder_index)] - correction
        IO.puts(bad)
        find_intruder(tree, weights, root, bad)
      else
        weights[root] + Enum.sum(branches)
      end
    else
      weights[root]
    end
  end

  defp find_different_index(list) do
    Enum.find_index(list, fn(x) -> length(Enum.uniq(list -- [x])) == 1 end)
  end

  defp build_tree_with_weights([], tree, weights), do: {tree, weights}
  defp build_tree_with_weights([line|lines], tree, weights) do
    line_parts = parts(line)
    build_tree_with_weights(lines, add_to_tree(line_parts, tree), insert_in_weights(line_parts, weights))
  end

  defp add_to_tree([{_, _}], tree), do: tree
  defp add_to_tree([{node, _}|children], tree), do: Map.put(tree, node, children)

  defp build_tree(lines) do
    build_tree(lines, %{})
  end

  defp build_tree([], tree), do: tree
  defp build_tree([line | lines], tree) do
    line_parts = parts(line)
    build_tree(lines, insert_in_tree(line_parts, tree))
  end

  defp insert_in_tree({node, _}, tree) do
    if Map.has_key?(tree, node) do
      tree
    else
      Map.put(tree, node, nil)
    end
  end
  defp insert_in_tree([{node, weight}|children], tree), do: insert_in_tree(node, children, insert_in_tree({node, weight}, tree))
  defp insert_in_tree(_, [], tree), do: tree
  defp insert_in_tree(node, [child|children], tree), do: insert_in_tree(node, children, Map.put(tree, child, node))
  
  defp insert_in_weights({node, weight}, weights), do: Map.put(weights, node, weight)
  defp insert_in_weights([{node, weight}|_], weights), do: insert_in_weights({node, weight}, weights)

  # ["fwft (72)", "ktlj, cntj, xhth"]
  # -> [{"fwft", 72}, ["ktlj", "cntj", "xhth"]]
  defp parts([parent, children]) do
    parts([parent]) ++ String.split(children, ", ", trim: true)
  end
  # ["ktlj (57)"]
  # -> {"ktlj", 57}
  defp parts([parent]) do
    [_, name, weight] = Regex.run(~r{(\w+)\s\((\d+)\)}, parent)
    [{name, String.to_integer(weight)}]
  end
  # ktlj (57)
  # fwft (72) -> ktlj, cntj, xhth
  defp parts(line), do: line |> String.split(" -> ", trim: true) |> parts

  defp lines(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
  end
end

root = Tower.bottom_program("./inputs/input07.txt")
IO.puts(root)

# --- Part Two ---

Tower.right_weight("./inputs/input07.txt", root) |> IO.puts
