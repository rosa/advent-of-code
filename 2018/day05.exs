# --- Day 5: Alchemical Reduction ---

# dabAcCaCBAcCcaDA  The first 'cC' is removed.
# dabAaCBAcCcaDA    This creates 'Aa', which is removed.
# dabCBAcCcaDA      Either 'cC' or 'Cc' are removed (the result is the same).
# dabCBAcaDA        No further actions can be taken.
# After all possible reactions, the resulting polymer contains 10 units.

defmodule Polymer do
  def reaction(polymer) do
    polymer
    |> units()
    |> apply_reactions([])
  end

  def read(file) do
    File.read!(file)
    |> String.trim()
  end

  def reaction_with_removal(polymer) do
    polymer
    |> units()
    |> apply_all_reactions()
    |> Enum.min_by(&Enum.count/1)
  end

  defp apply_all_reactions(units) do
    symbols(units)
    |> Enum.map(fn symbol -> remove(units, symbol) end)
    |> Enum.map(fn simplified_units -> apply_reactions(simplified_units, []) end)
  end

  defp symbols(units), do: Enum.map(units, &String.downcase/1) |> Enum.uniq()

  defp remove(units, symbol), do: Enum.filter(units, fn u -> String.downcase(u) != symbol end)

  defp apply_reactions(units, reacted), do: apply_reactions(units, reacted, length(units))

  defp apply_reactions([], reacted, l) when length(reacted) == l, do: reacted
  defp apply_reactions([], reacted, _) do
    apply_reactions(reacted, [], length(reacted))
  end
  defp apply_reactions([u], reacted, l), do: apply_reactions([], reacted ++ [u], l)
  defp apply_reactions([u1, u2 | units], reacted, l) do
    {result, remainder, delete_at} = react(u1, u2, List.last(reacted), l)
    apply_reactions(remainder ++ units, List.delete_at(reacted, delete_at) ++ result, l)
  end

  defp react(u1, u2, nil, l), do: react(u1, u2, [], l)
  defp react(u1, u2, v, l) when is_list(v) do
    if react?(u1, u2) do
      {[], v, -1}
    else
      {[u1], [u2], l+1}
    end
  end
  defp react(u1, u2, v, l), do: react(u1, u2, [v], l)

  defp react?(u1, u2), do: u1 != u2 && (String.downcase(u1) == u2 || u1 == String.downcase(u2))

  defp units(line), do: String.graphemes(line)
end

Polymer.read("./inputs/input05.txt") |> Polymer.reaction() |> Enum.count() |> IO.puts()

# --- Part Two ---
Polymer.read("./inputs/input05.txt") |> Polymer.reaction_with_removal() |> Enum.count() |> IO.puts()
