# --- Day 9: Stream Processing ---

# Here are some self-contained pieces of garbage:

# <>, empty garbage.
# <random characters>, garbage containing random characters.
# <<<<>, because the extra < are ignored.
# <{!>}>, because the first > is canceled.
# <!!>, because the second ! is canceled, allowing the > to terminate the garbage.
# <!!!>>, because the second ! and the first > are canceled.
# <{o"i!a,<{i<a>, which ends at the first >.

# Here are some examples of whole streams and the number of groups they contain:

# {}, 1 group.
# {{{}}}, 3 groups.
# {{},{}}, also 3 groups.
# {{{},{},{{}}}}, 6 groups.
# {<{},{},{{}}>}, 1 group (which itself contains garbage).
# {<a>,<a>,<a>,<a>}, 1 group.
# {{<a>},{<a>},{<a>},{<a>}}, 5 groups.
# {{<!>},{<!>},{<!>},{<a>}}, 2 groups (since all but the last > are canceled).

# {}, score of 1.
# {{{}}}, score of 1 + 2 + 3 = 6.
# {{},{}}, score of 1 + 2 + 2 = 5.
# {{{},{},{{}}}}, score of 1 + 2 + 3 + 3 + 3 + 4 = 16.
# {<a>,<a>,<a>,<a>}, score of 1.
# {{<ab>},{<ab>},{<ab>},{<ab>}}, score of 1 + 2 + 2 + 2 + 2 = 9.
# {{<!!>},{<!!>},{<!!>},{<!!>}}, score of 1 + 2 + 2 + 2 + 2 = 9.
# {{<a!>},{<a!>},{<a!>},{<ab>}}, score of 1 + 2 = 3.

defmodule Stream do

  def total_score(filename) do
    read_stream(filename) |> String.graphemes() |> calculate_scores() |> Enum.sum
  end

  def total_garbage(filename) do
    read_stream(filename) |> String.graphemes() |> count_garbage()
  end

  defp calculate_scores(stream), do: calculate_scores(stream, [], 0, nil)
  # calculate_scores(stream, scores, score, scope)
  # scope: 
  # - "<" garbage, ignoring everything
  # - "{" group, not ignoring
  defp calculate_scores([], scores, _, _), do: scores
  # ! Cancels next character
  defp calculate_scores(["!"|[_|stream]], scores, score, scope), do: calculate_scores(stream, scores, score, scope)
  # While in garbage
  defp calculate_scores([next|stream], scores, score, "<") do
    case next do
      ">" -> calculate_scores(stream, scores, score, "{")
      _ -> calculate_scores(stream, scores, score, "<")
    end
  end
  # While in group
  defp calculate_scores([next|stream], scores, score, _) do
    case next do
      "}" -> calculate_scores(stream, scores ++ [score], score - 1, "{")
      "{" -> calculate_scores(stream, scores, score + 1, "{")
      "<" -> calculate_scores(stream, scores, score, "<")
      _ -> calculate_scores(stream, scores, score, "{")
    end
  end

  defp count_garbage(stream), do: count_garbage(stream, 0, nil)
  defp count_garbage([], count, _), do: count
  # ! Cancels next character, doesn't count
  defp count_garbage(["!"|[_|stream]], count, scope), do: count_garbage(stream, count, scope)
  # While in garbage
  defp count_garbage([next|stream], count, "<") do
    case next do
      ">" -> count_garbage(stream, count, "{")
      _ -> count_garbage(stream, count + 1, "<")
    end
  end
  # While in group
  defp count_garbage([next|stream], count, _) do
    case next do
      "<" -> count_garbage(stream, count, "<")
      _ -> count_garbage(stream, count, "{")
    end
  end


  defp read_stream(filename) do
    File.read!(filename)
  end
end

Stream.total_score("input09.txt") |> IO.puts

# --- Part Two ---

Stream.total_garbage("input09.txt") |> IO.puts
