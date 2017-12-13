# --- Day 13: Packet Scanners ---

# 0: 3
# 1: 2
# 4: 4
# 6: 4

#  0   1   2   3   4   5   6
# [ ] [ ] ... ... [ ] ... [ ]
# [ ] [ ]         [ ]     [ ]
# [ ]             [ ]     [ ]
#                 [ ]     [ ]

# Picosecond 0:
#  0   1   2   3   4   5   6
# [S] [S] ... ... [S] ... [S]
# [ ] [ ]         [ ]     [ ]
# [ ]             [ ]     [ ]
#                 [ ]     [ ]

# Picosecond 1:
#  0   1   2   3   4   5   6
# [ ] [ ] ... ... [ ] ... [ ]
# [S] [S]         [S]     [S]
# [ ]             [ ]     [ ]
#                 [ ]     [ ]

# Picosecond 2:
#  0   1   2   3   4   5   6
# [ ] [S] ... ... [ ] ... [ ]
# [ ] [ ]         [ ]     [ ]
# [S]             [S]     [S]
#                 [ ]     [ ]

# Picosecond 3:
#  0   1   2   3   4   5   6
# [ ] [ ] ... ... [ ] ... [ ]
# [S] [S]         [ ]     [ ]
# [ ]             [ ]     [ ]
#                 [S]     [S]

# The severity of getting caught on a layer is equal to its depth multiplied by its range. 
# (Ignore layers in which you do not get caught.)
# The severity of the whole trip is the sum of these values. 
# In the example above, the trip severity is 0*3 + 6*4 = 24.

defmodule Firewall do

  def severity_of_trip(file) do
    lines(file)
    |> build_firewall()
    |> severity()
  end

  def delay(file) do
    lines(file)
    |> build_firewall()
    |> calculate_delay(1, nil)
  end

  defp calculate_delay(_, delay, :found), do: delay
  defp calculate_delay(firewall, delay, nil) do
    if Enum.any?(firewall, fn(layer) -> position_at_depth(layer, delay) == 0 end) do
      calculate_delay(firewall, delay + 1, nil)
    else
      calculate_delay(firewall, delay, :found)
    end
  end

  defp severity({depth, range}), do: depth * range
  defp severity(firewall) do
    Enum.filter(firewall, fn(layer) -> position_at_depth(layer) == 0 end)
    |> Enum.reduce(0, fn(layer, acc) -> severity(layer) + acc end)
  end

  defp position_at_depth({depth, range}, delay \\ 0), do: rem(depth + delay, 2*(range - 1))

  defp build_firewall(lines) do
    Enum.map(lines, &layer/1)
  end

  defp layer(line) do
    String.split(line, ~r{:\s+}, trim: true)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple
  end

  defp lines(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
  end
end


Firewall.severity_of_trip("input13.txt") |> IO.puts

# --- Part Two ---

# Not very efficient... ^_^U
Firewall.delay("input13.txt")

