# --- Day 20: Jurassic Jigsaw ---

defmodule Jigsaw do
  def arrange_tiles(arranged, current, tiles), do: arrange_tiles(arranged, current, tiles, size(tiles))
  def arrange_tiles(arranged, {i, i}, _, size) when i == size - 1, do: arranged
  def arrange_tiles(arranged, {i, j}, tiles, size) when j == size - 1 do
    match = bottom_match(arranged[{i, 0}], tiles)
    Map.put(arranged, {i + 1, 0}, match)
    |> arrange_tiles({i + 1, 0}, Map.delete(tiles, elem(match, 0)), size)
  end
  def arrange_tiles(arranged, {i, j}, tiles, size) do
    match = right_match(arranged[{i, j}], tiles)
    Map.put(arranged, {i, j + 1}, match)
    |> arrange_tiles({i, j + 1}, Map.delete(tiles, elem(match, 0)), size)
  end

  def all_matches(tiles, in_tiles) do
    Enum.map(tiles, fn tile = {id, _} -> {id, matching_tiles(tile, in_tiles)} end)
    |> Enum.each(&print_tile_and_matches/1)
  end

  # Corners only match 2 tiles
  def corners(tiles) do
    Enum.map(tiles, fn tile = {id, _} -> {id, matching_tiles(tile, tiles) |> Enum.count(&(!is_nil(&1))) } end)
    |> Enum.filter(fn {_, matches} -> matches == 2 end)
    |> Enum.map(&(elem(&1, 0)))
  end

  def read_tiles(file) do
    File.read!(file)
    |> String.split(~r{\n\n}, trim: true)
    |> Enum.map(fn tile -> String.split(tile, ~r{\n}, trim: true) end)
    |> Enum.map(&parse_tile/1)
    |> Enum.into(%{})
  end


  def remove_borders(tiles) when is_map(tiles) do
    Enum.map(tiles, fn {coord, {id, rows}} -> {coord, {id, remove_borders(rows)}} end)
    |> Enum.into(%{})
  end
  def remove_borders([_|rows]) do
    List.delete_at(rows, -1)
    |> Enum.map(fn [_|row] -> List.delete_at(row, -1) end)
  end

  def merge_tiles(tiles), do: merge_tiles(tiles, size(tiles))
  def merge_tiles(tiles, size) do
    (0..size - 1)
    |> Enum.map(fn i -> merge_tiles(tiles, size, i) end)
    |> concatenate
  end
  def merge_tiles(tiles, size, i) do
    (0..size - 1)
    |> Enum.map(fn j -> tiles[{i, j}] |> elem(1) end)
    |> merge_rows
  end

  def water_roughness(waters) do
    sea_monsters =
      waters
      |> find_sea_monsters
      |> Map.values
      |> List.flatten
      |> Enum.count

    Enum.count(List.flatten(waters), &(&1 == "#")) - sea_monsters * 15
  end


  defp concatenate([m]), do: m
  defp concatenate([m, n|lists]), do: [m ++ n|lists] |> concatenate

  defp merge_rows([m]), do: m
  defp merge_rows([m, n|rest]), do: [merge_rows(m, n)|rest] |> merge_rows

  defp merge_rows(m, n), do: merge_rows(m, n, [])
  defp merge_rows([], [], merged), do: merged
  defp merge_rows([m1|m], [n1|n], merged), do: merge_rows(m, n, merged ++ [m1 ++ n1])


  defp matching_tiles(tile = {_, _}, tiles) do
    borders(tile)
    |> elem(1)
    |> Enum.map(fn border -> matching_tile(border, Map.to_list(tiles) -- [tile]) end)
    |> Enum.map(&id/1)
  end

  defp id(nil), do: nil
  defp id({id, _}), do: id

  defp right_match(tile, tiles) do
    {_, [_, border, _, _]} = borders(tile)
    matching_tile(border, tiles)
    |> transform_to_left(border)
  end

  defp bottom_match(tile, tiles) do
    {_, [_, _, border, _]} = borders(tile)
    matching_tile(border, tiles)
    |> transform_to_top(border)
  end

  defp matching_tile(border, tiles) do
    Enum.find(tiles, fn tile -> match_tile?(border, tile) end)
  end

  defp match_tile?(border, tile) do
    {_, borders} = borders(tile)
    border in borders || Enum.reverse(border) in borders
  end

  defp transform_to_left(tile, border) do
    {_, [top, right, bottom, left]} = borders(tile)
    cond do
      top == border -> rotate(tile) |> rotate |> rotate |> flip_horizontally
      right == border -> flip_vertically(tile)
      bottom == border -> rotate(tile)
      left == border -> tile

      Enum.reverse(top) == border -> rotate(tile) |> rotate |> rotate
      Enum.reverse(right) == border -> flip_vertically(tile) |> flip_horizontally
      Enum.reverse(bottom) == border -> rotate(tile) |> flip_horizontally
      Enum.reverse(left) == border -> flip_horizontally(tile)
    end
  end

  defp transform_to_top(tile, border) do
    {_, [top, right, bottom, left]} = borders(tile)
    cond do
      top == border -> tile
      right == border -> rotate(tile) |> rotate |> rotate
      bottom == border -> flip_horizontally(tile)
      left == border -> rotate(tile) |> flip_vertically

      Enum.reverse(top) == border -> flip_vertically(tile)
      Enum.reverse(right) == border -> rotate(tile) |> rotate |> rotate |> flip_vertically
      Enum.reverse(bottom) == border -> flip_horizontally(tile) |> flip_vertically
      Enum.reverse(left) == border -> rotate(tile)
    end
  end

  # Rotate clock-wise
  defp rotate({id, rows}), do: {id, rotate(rows)}
  defp rotate(rows), do: Enum.reverse(rows) |> transpose()

  defp transpose([row|rows]), do: Enum.map(0..Enum.count(row)-1, fn i -> column([row|rows], i) end)

  defp column(rows, i), do: Enum.map(rows, fn row -> Enum.at(row, i) end)

  defp flip_horizontally({id, rows}), do: {id, Enum.reverse(rows)}
  defp flip_vertically({id, rows}), do: {id, Enum.map(rows, &Enum.reverse/1)}

  # Top, right, bottom, left
  defp borders({id, rows}) do
    {id, [List.first(rows), Enum.map(rows, &List.last/1), List.last(rows), Enum.map(rows, &List.first/1)]}
  end
  defp borders(tiles), do: Enum.map(tiles, &borders/1)


  defp find_sea_monsters(image) do
    1..Enum.count(image) - 2
    |> Enum.map(fn i -> {i, find_sea_monsters(image, i)} end)
    |> Enum.reject(fn {_, m} -> m == [] end)
    |> Enum.into(%{})
  end

  defp find_sea_monsters(image, i) do
    0..Enum.count(Enum.at(image, i))
    |> Enum.filter(fn j -> sea_monster?(image, i, j) end)
  end

  defp sea_monster?(image, i, j) do
    #                      #
    #    #    ##    ##    ###
    #     #  #  #  #  #  #
    [{0, 0}, {1, 1}, {1, 4}, {0, 5}, {0, 6}, {1, 7}, {1, 10}, {0, 11}, {0, 12}, {1, 13},
     {1, 16}, {0, 17}, {0, 18}, {-1, 18}, {0, 19}]
    |> Enum.all?(fn {x, y} -> at(image, i + x, j + y) == "#" end)
  end

  defp at(image, i, j), do: Enum.at(image, i) |> Enum.at(j)


  defp parse_tile([title|rows]) do
    [_, id] = Regex.run(~r{Tile (\d+):}, title)
    {String.to_integer(id), Enum.map(rows, &String.graphemes/1)}
  end

  defp print_tile_and_matches({id, [top, right, bottom, left]}) do
    IO.puts("      #{top}")
    IO.puts("#{left || "    "}  #{id}  #{right}")
    IO.puts("      #{bottom}")
    IO.puts("\n")
  end

  def print_arranged_tiles(tiles), do: print_arranged_tiles(tiles, size(tiles))
  def print_arranged_tiles(tiles, size) do
    Enum.each(0..size - 1, fn i -> print_arranged_tiles(tiles, size, i) end)
  end
  def print_arranged_tiles(tiles, size, i) do
    0..size - 1
    |> Enum.map(fn j -> tiles[{i, j}] |> elem(0) end)
    |> Enum.join(" ")
    |> IO.puts
  end

  def print_image(rows) do
    Enum.each(rows, fn row -> Enum.join(row, "") |> IO.puts end)
  end

  defp size(tiles), do: map_size(tiles) |> :math.sqrt |> round
end

tiles = Jigsaw.read_tiles("inputs/input20.txt")
Jigsaw.corners(tiles) |> Enum.reduce(&(&1 * &2)) |> IO.inspect

# --- Part Two ---

# corners = Jigsaw.corners(tiles) |> Enum.map(fn id -> {id, tiles[id]} end)
# Jigsaw.all_matches(corners, tiles)

#       1499
#       1663  2713

#       2671
# 1619  2659

#       1151  2341
#       1303

#       3079  3167
#       1019

# We start with this corner:
#       1151  2341
#       1303

arranged = Jigsaw.arrange_tiles(%{{0, 0} => {1151, tiles[1151]}}, {0, 0}, Map.delete(tiles, 1151))
# Jigsaw.print_arranged_tiles(arranged)
Jigsaw.remove_borders(arranged) |> Jigsaw.merge_tiles |> Enum.reverse |> Jigsaw.water_roughness |> IO.inspect
