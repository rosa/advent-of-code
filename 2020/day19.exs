# --- Day 19: Monster Messages ---

defmodule CorruptedMessages do
  def full_matches(pattern, messages) do
    Enum.filter(messages, fn message -> String.match?(message, ~r{^#{pattern}$}) end)
  end

  def process_rules(rules), do: process_rules(rules, %{})
  def process_rules(rules, processed_rules) when map_size(rules) == 0, do: processed_rules
  def process_rules(rules, processed_rules) do
    leaves = find_leaves(rules)

    replace_leaves(leaves, rules)
    |> reduce_new_leaves
    |> process_rules(Map.merge(processed_rules, leaves))
  end

  def read_rules_and_messages(file) do
    [rules, messages] = File.read!(file)
    |> String.split(~r{\n\n}, trim: true)
    |> Enum.map(&(String.split(&1, ~r{\n}, trim: true)))

    {Enum.map(rules, &parse_rule/1) |> Enum.into(%{}), messages}
  end

  defp find_leaves(rules) do
    Enum.filter(rules, &leaf?/1)
    |> Enum.map(fn {id, [piece]} -> {id, piece} end)
    |> Enum.into(%{})
  end

  defp replace_leaves(leaves, rules) do
    Map.split(rules, Map.keys(leaves))
    |> elem(1)
    |> Enum.reduce(%{}, fn ({id, pattern}, acc) -> Map.put(acc, id, insert_leaves(leaves, pattern)) end)
  end

  defp insert_leaves(leaves, pattern), do: Enum.map(pattern, fn piece -> leaves[piece] || piece end)

  defp reduce_new_leaves(rules) do
    Enum.map(rules, fn {id, pattern} -> {id, reduce_to_leaf(pattern)} end)
    |> Enum.into(%{})
  end

  defp reduce_to_leaf(pattern) do
    if !Enum.any?(pattern, fn piece -> String.match?(piece, ~r{\d}) end) do
      ["(" <> Enum.join(pattern) <> ")"]
    else
      pattern
    end
  end

  defp leaf?({_, [piece]}), do: !String.match?(piece, ~r{\d})
  defp leaf?(_), do: false

  # 0: 4 1 5
  # 1: 2 3 | 3 2
  # 4: "a"
  defp parse_rule(rule) do
    [_, id, pattern] = Regex.run(~r{(\d+):\s(.+)}, rule)
    {id, String.replace(pattern, "\"", "") |> String.split(" ")}
  end
end

{rules, messages} = CorruptedMessages.read_rules_and_messages("inputs/input19.txt")
processed_rules = CorruptedMessages.process_rules(rules)
CorruptedMessages.full_matches(processed_rules["0"], messages) |> Enum.count |> IO.puts

# --- Part Two ---

# replace rules 8: 42 and 11: 42 31 with the following:
# 8: 42 | 42 8
# 11: 42 31 | 42 11 31

# Fortunately, many of the rules are unaffected by this change;
# it might help to start by looking at which rules always match
# the same set of values and how those rules (especially rules 42 and 31)
# are used by the new versions of rules 8 and 11.
# 
# 0: 8 11
# Applying the new changes to rule 8 and 11:
# 0: 42 (42)* 42 (42 42 ... 31 31)? 31 which is equivalent to:
# 0: (42)+ 42 (42 42 ... 31 31)? 31
# And we can use recursive patterns for the second part:
new_rule_zero = "(" <> processed_rules["42"] <> ")+" <> "(?<eleven>" <> processed_rules["42"] <> "(?&eleven)?" <> processed_rules["31"] <> ")"
CorruptedMessages.full_matches(new_rule_zero, messages) |> Enum.count |> IO.puts

