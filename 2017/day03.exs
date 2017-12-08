# --- Day 3: Spiral Memory ---

# 17  16  15  14  13
# 18   5   4   3  12
# 19   6   1   2  11
# 20   7   8   9  10
# 21  22  23---> ...

defmodule Memory do

  defp size(location) do
    closest(location) |> make_odd
  end

  defp base(size) do
    div(size, 2)
  end

  defp offset(size, location) do
    start = (size - 2)*(size - 2) + 1
    finish = size*size - 1
    perimeter = finish - start + 2
    segment_size = div(perimeter, 4)
    n_segment = div((location - start), segment_size)
    middle_segment = n_segment * segment_size + start + div(segment_size, 2)
  end

  defp closest(location) do
    :math.sqrt(location) |> :math.ceil |> round
  end

  defp make_odd(n) when rem(n, 2) == 0, do: n + 1
  defp make_odd(n), do: n

  # iex(7)> Memory.size(location)
  # 527
  # First segment: 
  # 275626 to 276152
  # Second segment:
  # 276152 to 276678
  # Third segment:
  # 276678 to 277204
  # Fourth segment:
  # 277204 to 277730
  # middle point = 277467
  # Distance = 211
  # Total = 211 + base = 211 + 263 + 1 = 475

  # --- Part Two ---
  # 147  142  133  122   59
  # 304    5    4    2   57
  # 330   10    1    1   54
  # 351   11   23   25   26
  # 362  747  806--->   ...
end

# Part two
# https://oeis.org/A141481
# https://oeis.org/A141481/b141481.txt