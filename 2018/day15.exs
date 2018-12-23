# --- Day 15: Beverage Bandits ---

defmodule Battle do
  alias Battle.Unit

  def read_and_parse_field(file) do
    read(file)
    |> parse_field_and_units()
  end

  def print_field(field, n, m) do
    for i <- 0..n-1 do
      Enum.map(0..m-1, fn j -> field[{i, j}] || "#" end)
      |> Enum.join()
      |> IO.puts()
    end
  end

  def run_test(test_mode = {field, units}, power) do
    IO.puts("Running test with power = #{power}")
    fight(field, Unit.add_power(units, power), 0, test_mode)
  end

  defp halt_test(test_mode = {field, units}, power) do
    run_test(test_mode, power + 1)
  end

  def fight(field, units, n, test_mode \\ nil) do
    Enum.sort(units, &(Unit.leqt(&1, &2)))
    |> turn(field, n + 1, test_mode)
  end

  defp turn(units, field, n, test_mode), do: turn(Unit.ids(units), field, Unit.map(units), n, test_mode)
  defp turn([], field, units_map, n, test_mode), do: fight(field, Map.values(units_map), n, test_mode)
  defp turn([unit_id | waiting], field, units_map, n, test_mode) do
    turn(units_map[unit_id], waiting, field, units_map, n, test_mode)
  end
  # unit has died over this turn
  defp turn(nil, waiting, field, units_map, n, test_mode), do: turn(waiting, field, units_map, n, test_mode)
  defp turn(unit, waiting, field, units_map, n, test_mode) do
    # Each unit begins its turn by identifying all possible targets (enemy units). If no targets remain, combat ends.
    targets = find_targets(unit, units_map)
    if Enum.empty?(targets) do
      end_battle(units_map, n-1, test_mode)
    else
      # If the unit is already in range of a target, it does not move, but continues its turn with an attack.
      # Otherwise, since it is not in range of a target, it moves, and then attacks if it can.
      to_attack = attackable(unit, targets)
      {updated_field, updated_units_map} = if to_attack do
        attack(field, unit, to_attack, units_map, test_mode)
      else
        move(unit, field, targets, units_map)
        |> try_to_attack(targets, test_mode)
      end

      turn(waiting, updated_field, updated_units_map, n, test_mode)
    end
  end

  defp try_to_attack({field, units_map, unit}, targets, test_mode) do
    to_attack = attackable(unit, targets)
    if to_attack do
      attack(field, unit, to_attack, units_map, test_mode)
    else
      {field, units_map}
    end
  end

  defp end_battle(units_map, rounds, test_mode) do
    result = rounds * (Enum.map(units_map, fn {_, unit} -> unit.hp end) |> Enum.sum())

    if test_mode do
      IO.puts(result)
      exit(:normal)
    else
      result
    end
  end

  # To move, the unit first considers the squares that are in range and determines which of those squares
  # it could reach in the fewest steps. 
  # If the unit cannot reach (find an open path to) any of the squares that are in range, it ends its turn.
  # If multiple squares are in range and tied for being reachable in the fewest steps, the square
  # which is first in reading order is chosen.
  defp move(unit, field, targets, units_map) do
    in_range = in_range(field, unit, targets)
    paths = Enum.reduce(in_range, %{}, fn p, acc -> Map.put(acc, p, bfs(field, unit.position, p)) end)
    candidates = Enum.filter(in_range, &(paths[&1]))
    if Enum.empty?(candidates) do
      {field, units_map, unit}
    else
      chosen = Enum.sort(candidates, fn c1, c2 -> length(paths[c1]) < length(paths[c2]) || (length(paths[c1]) == length(paths[c2]) && c1 <= c2) end) |> hd()
      move_to = paths[chosen] |> hd()
      {%{ field | unit.position => ".", move_to => unit.type }, move(units_map, unit, move_to), Unit.move(unit, move_to)}
    end
  end

  defp move(units_map, unit, move_to) do
    Map.put(units_map, unit.id, Unit.move(unit, move_to))
  end

  defp attackable(%{position: {i, j}}, units) do
    adjacents = [{i, j+1}, {i+1, j}, {i-1, j}, {i, j-1}]
    # To attack, the unit first determines all of the targets that are in range of it
    # by being immediately adjacent to it. If there are no such targets, the unit ends its turn.
    # Otherwise, the adjacent target with the fewest hit points is selected; in a tie,
    # the adjacent target with the fewest hit points which is first in reading order is selected.    
    candidates = Enum.filter(units, fn unit -> unit.position in adjacents end)
    Enum.sort(candidates, fn c1, c2 -> c1.hp < c2.hp || c1.hp == c2.hp && c1 <= c2 end) |> Enum.at(0)
  end

  defp attack(field, unit, to_attack, units_map, test_mode) do
    attacked = Unit.take_hit(to_attack, unit.power)
    cond do
      Unit.dead?(attacked) && test_mode && attacked.type == "E" -> halt_test(test_mode, attacked.power)
      Unit.dead?(attacked) -> {Map.put(field, attacked.position, "."), Map.delete(units_map, to_attack.id)}
      true -> {field, Map.put(units_map, to_attack.id, attacked)}
    end
  end

  defp find_targets(source, units) do
    Enum.filter(Map.values(units), fn u -> u.type != source.type end)
  end

  defp in_range(field, source, units), do: in_range(field, source, units, [])
  defp in_range(_field, _source, [], in_range), do: in_range
  defp in_range(field, source = %{type: source_type}, [ %{type: target_type} | units], in_range) when source_type == target_type, do: in_range(field, source, units, in_range)
  defp in_range(field, source, [ unit | units], in_range) do
    in_range(field, source, units, Enum.uniq(in_range ++ neighbours(unit.position, field)))
  end

  defp bfs(field, source, target), do: bfs(field, source, [source], target, MapSet.new(), {%{source => 0}, %{}})
  defp bfs(_field, source, [], target, _visited, {_distances, previous}), do: build_path(source, target, previous)
  defp bfs(field, source, [root | queue], target, visited, {distances, previous}) do
    neighbours = neighbours(root, field)
    |> Enum.reject(fn n -> n in visited end)
    |> Enum.reject(fn n -> n in queue end)

    bfs(field, source, queue ++ neighbours, target, MapSet.put(visited, root), update_distances_and_previous(root, neighbours, distances, previous))
  end

  defp update_distances_and_previous(_u, [], distances, previous), do: {distances, previous}
  defp update_distances_and_previous(u, [v | neighbours], distances, previous) do
    alt = distances[u] + 1
    if is_nil(distances[v]) || alt < distances[v] || (alt == distances[v] && u < previous[v]) do
      update_distances_and_previous(u, neighbours, Map.put(distances, v, alt), Map.put(previous, v, u))
    else
      update_distances_and_previous(u, neighbours, distances, previous)
    end
  end

  defp build_path(source, target, prev), do: build_path(source, target, prev, [])
  defp build_path(_source, nil, _prev, _path), do: nil
  defp build_path(source, target, _prev, path) when source == target, do: path
  defp build_path(source, target, prev, path), do: build_path(source, prev[target], prev, [target | path])

  defp neighbours({i, j}, field) do
    [{i-1, j}, {i, j-1}, {i, j+1}, {i+1, j}]
    |> Enum.filter(fn v -> field[v] == "." end)
  end


  defp parse_field_and_units(lines), do: parse_field_and_units(lines, %{}, [], 0)
  defp parse_field_and_units([], field, units, _i), do: {field, units}
  defp parse_field_and_units([row | rows], field, units, i) do
    {updated_field, updated_units} = parse_field_and_units(row, field, units, i, 0)
    parse_field_and_units(rows, updated_field, updated_units, i + 1)
  end

  defp parse_field_and_units([], field, units, _i, _j), do: {field, units}
  defp parse_field_and_units(["." | row], field, units, i, j) do
    parse_field_and_units(row, Map.put(field, {i, j}, "."), units, i, j + 1)
  end
  defp parse_field_and_units([type | row], field, units, i, j) when type in ["G", "E"] do
    parse_field_and_units(row, Map.put(field, {i, j}, type), units ++ [Unit.new(length(units) + 1, type, {i, j})], i, j + 1)
  end
  defp parse_field_and_units([_ | row], field, units, i, j), do: parse_field_and_units(row, field, units, i, j + 1)

  defp read(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
    |> Enum.map(&String.graphemes/1)
  end
end

defmodule Battle.Unit do
  defstruct(
    id: nil,
    type: nil,
    position: nil,
    power: 3,
    hp: 200
  )

  def new(id, type, position) do
    %Battle.Unit{
      id: id,
      type: type,
      position: position
    }
  end

  def ids(units), do: Enum.map(units, &(&1.id))

  def map(units), do: Enum.reduce(units, %{}, fn unit, acc -> Map.put(acc, unit.id, unit) end)

  def leqt(unit1, unit2), do: unit1.position <= unit2.position

  def move(unit, position), do: %{unit | position: position}

  def take_hit(unit, power), do: %{unit | hp: unit.hp - power}

  def dead?(unit), do: unit.hp <= 0

  def add_power(units, power) do
    Enum.map(units, fn unit -> if unit.type == "E", do: %{unit | power: power}, else: unit end)
  end
end


{field, units} = Battle.read_and_parse_field("./inputs/input15.txt")
Battle.fight(field, units, 0)

# --- Part Two ---
Battle.run_test({field, units}, 10)
