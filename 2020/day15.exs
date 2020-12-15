# --- Day 15: Rambunctious Recitation ---

defmodule MemoryGame do
  def play(start, until) do
    spoken = Enum.zip(start, 1..Enum.count(start)) |> Enum.into(%{})
    play({spoken, List.last(start), %{}}, Enum.count(start) + 1, until)
  end

  def play({_, previous, _}, turn, until) when turn == until + 1, do: previous
  def play({spoken, previous, previously_spoken}, turn, until) do
    speak(spoken, previous, previously_spoken, turn)
    |> play(turn + 1, until)
  end

  # Each turn consists of considering the most recently spoken number:
  # - If that was the first time the number has been spoken, the current player says 0.
  # - Otherwise, the number had been spoken before; the current player announces how many 
  #   turns apart the number is from when it was previously spoken.
  defp speak(spoken, previous, previously_spoken, turn) do
    next = if previously_spoken[previous], do: turn - 1 - previously_spoken[previous], else: 0
    updated_previously_spoken = if spoken[next], do: Map.put(previously_spoken, next, spoken[next]), else: previously_spoken
    {Map.put(spoken, next, turn), next, updated_previously_spoken}
  end
end

MemoryGame.play([7,14,0,17,11,1,2], 2020) |> IO.puts

# --- Part Two ---

MemoryGame.play([7,14,0,17,11,1,2], 30000000) |> IO.puts
