# --- Day 12: Rain Risk ---

defmodule Navigation do
  def follow_instructions({position, _}, []), do: position
  def follow_instructions(localization, [instruction|instructions]) do
    move(localization, instruction)
    |> follow_instructions(instructions)
  end
  def follow_instructions(position, _, []), do: position
  def follow_instructions(localization, waypoint, [instruction|instructions]) do
    move_ship(localization, waypoint, instruction)
    |> follow_instructions(move_waypoint(waypoint, instruction), instructions)
  end

  def manhattan_distance({east, north}), do: abs(north) + abs(east)


  defp move_waypoint(position, {action, value}) do
    cond do
      action in ["L", "R"] -> rotate_waypoint(position, {action, value})
      action == "F"        -> position
      true                 -> move({position, "E"}, {action, value}) |> elem(0)
    end
  end

  defp rotate_waypoint({east, north}, {"R", 90}), do: {north, -east}
  defp rotate_waypoint({east, north}, {"L", 90}), do: {-north, east}
  defp rotate_waypoint({east, north}, {_, 180}), do: {-east, -north}
  defp rotate_waypoint(position, {"R", 270}), do: rotate_waypoint(position, {"L", 90})
  defp rotate_waypoint(position, {"L", 270}), do: rotate_waypoint(position, {"R", 90})

  defp move_ship({east, north}, {waypoint_east, waypoint_nort}, {"F", times}), do: {east + times * waypoint_east, north + times * waypoint_nort}
  defp move_ship(position, _, _), do: position

  # Action N means to move north by the given value.
  # Action S means to move south by the given value.
  # Action E means to move east by the given value.
  # Action W means to move west by the given value.
  # Action L means to turn left the given number of degrees.
  # Action R means to turn right the given number of degrees.
  # Action F means to move forward by the given value in the direction the ship is currently facing.
  defp move({{east, north}, facing}, {"N", value}), do: {{east, north + value}, facing}
  defp move({{east, north}, facing}, {"S", value}), do: {{east, north - value}, facing}
  defp move({{east, north}, facing}, {"E", value}), do: {{east + value, north}, facing}
  defp move({{east, north}, facing}, {"W", value}), do: {{east - value, north}, facing}
  defp move({position, facing}, {"F", value}), do: move({position, facing}, {facing, value})
  defp move({position, facing}, instruction), do: {position, turn(instruction, facing)}

  defp turn({"L", 90}, facing) do
    case facing do
      "N" -> "W"
      "S" -> "E"
      "E" -> "N"
      "W" -> "S"
    end
  end
  defp turn({"R", 90}, facing) do
    case facing do
      "N" -> "E"
      "S" -> "W"
      "E" -> "S"
      "W" -> "N"
    end
  end
  defp turn({_, 180}, facing) do
    case facing do
      "N" -> "S"
      "S" -> "N"
      "E" -> "W"
      "W" -> "E"
    end
  end
  defp turn({"L", 270}, facing), do: turn({"R", 90}, facing)
  defp turn({"R", 270}, facing), do: turn({"L", 90}, facing)

  def read_instructions(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
    |> Enum.map(&parse_instruction/1)
  end

  defp parse_instruction(instruction) do
    [_, action, value] = Regex.run(~r{([NSEWLRF])(\d+)}, instruction)
    {action, String.to_integer(value)}
  end
end


instructions = Navigation.read_instructions("inputs/input12.txt")
Navigation.follow_instructions({{0, 0}, "E"}, instructions) |> Navigation.manhattan_distance() |> IO.puts

# --- Part Two ---

Navigation.follow_instructions({0, 0}, {10, 1}, instructions) |> Navigation.manhattan_distance() |> IO.puts
