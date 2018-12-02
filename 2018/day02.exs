# --- Day 2: Inventory Management System ---

# - abcdef contains no letters that appear exactly two or three times.
# - bababc contains two a and three b, so it counts for both.
# - abbcde contains two b, but no letter appears exactly three times.
# - abcccd contains three c, but no letter appears exactly two times.
# - aabcdd contains two a and two d, but it only counts once.
# - abcdee contains two e.
# - ababab contains three a and three b, but it only counts once.
# Of these box IDs, four of them contain a letter which appears exactly twice, and three of them contain
# a letter which appears exactly three times. Multiplying these together produces a checksum of 4 * 3 = 12.
defmodule Inventory do
  def checksum({two, three}), do: two * three
  def checksum(file) do
    file
    |> lines()
    |> ids()
    |> two_and_three()
    |> checksum()
  end

  def fabrics_common_letters(file) do
    file
    |> lines()
    |> find_boxes()
    |> common_letters()
  end

  defp common_letters({id1, id2}) do
    String.myers_difference(id1, id2)
    |> Keyword.get_values(:eq)
    |> Enum.join()
  end

  defp two_and_three(lines), do: two_and_three(lines, {0, 0})
  defp two_and_three([], result), do: result
  defp two_and_three([id | list], {two, three}), do: two_and_three(list, analyse(id, {two, three}))

  defp analyse(id, {two, three}) do
    {x, y} = id
    |> frequencies()
    |> analyse()

    {two + x, three + y}
  end
  defp analyse(list), do: { Enum.count(list, fn x -> x == 2 end), Enum.count(list, fn x -> x == 3 end) }

  defp frequencies(id) do
    id
    |> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
    |> Map.values()
    |> Enum.uniq()
  end

  defp find_boxes(lines) do
    lines
    |> Enum.find_value(fn x -> find_box(x, lines) end)
  end

  defp find_box(id, ids) do
    box = ids
    |> Enum.find(fn x -> valid_boxes?(id, x) end)

    if box, do: { id, box }, else: nil
  end

  defp valid_boxes?(id1, id2) do
    count = common_letters({id1, id2})
    |> String.length()

    count == String.length(id1) - 1 && count == String.length(id2) - 1
  end

  defp ids(lines), do: Enum.map(lines, &String.codepoints/1)

  defp lines(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
  end
end

Inventory.checksum("./inputs/input02.txt") |> IO.puts

# --- Part Two ---

Inventory.fabrics_common_letters("./inputs/input02.txt") |> IO.puts
