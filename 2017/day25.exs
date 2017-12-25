# --- Day 25: The Halting Problem ---

defmodule TuringMachine do

  def diagnostic_checksum(steps) do
    run(init(), steps)
    |> Map.fetch!(:tape)
    |> Map.values
    |> Enum.count(fn(x) -> x == 1 end)
  end

  defp run(machine, 0), do: machine
  defp run(machine, steps) do
    execute(machine)
    |> run(steps - 1)
  end

  # Begin in state A.
  defp init() do
    %{state: 'A', tape: %{}, cursor: 0}
  end

  # In state A:
  #   If the current value is 0:
  #     - Write the value 1.
  #     - Move one slot to the right.
  #     - Continue with state B.
  #   If the current value is 1:
  #     - Write the value 0.
  #     - Move one slot to the left.
  #     - Continue with state C.
  defp execute(%{state: 'A', tape: tape, cursor: cursor}) do
    case value(tape, cursor) do
      0 -> %{state: 'B', tape: Map.put(tape, cursor, 1), cursor: cursor + 1}
      1 -> %{state: 'C', tape: Map.put(tape, cursor, 0), cursor: cursor - 1}
    end
  end

  # In state B:
  #   If the current value is 0:
  #     - Write the value 1.
  #     - Move one slot to the left.
  #     - Continue with state A.
  #   If the current value is 1:
  #     - Write the value 1.
  #     - Move one slot to the right.
  #     - Continue with state D.
  defp execute(%{state: 'B', tape: tape, cursor: cursor}) do
    case value(tape, cursor) do
      0 -> %{state: 'A', tape: Map.put(tape, cursor, 1), cursor: cursor - 1}
      1 -> %{state: 'D', tape: Map.put(tape, cursor, 1), cursor: cursor + 1}
    end
  end

  # In state C:
  #   If the current value is 0:
  #     - Write the value 1.
  #     - Move one slot to the right.
  #     - Continue with state A.
  #   If the current value is 1:
  #     - Write the value 0.
  #     - Move one slot to the left.
  #     - Continue with state E.
  defp execute(%{state: 'C', tape: tape, cursor: cursor}) do
    case value(tape, cursor) do
      0 -> %{state: 'A', tape: Map.put(tape, cursor, 1), cursor: cursor + 1}
      1 -> %{state: 'E', tape: Map.put(tape, cursor, 0), cursor: cursor - 1}
    end
  end

  # In state D:
  #   If the current value is 0:
  #     - Write the value 1.
  #     - Move one slot to the right.
  #     - Continue with state A.
  #   If the current value is 1:
  #     - Write the value 0.
  #     - Move one slot to the right.
  #     - Continue with state B.
  defp execute(%{state: 'D', tape: tape, cursor: cursor}) do
    case value(tape, cursor) do
      0 -> %{state: 'A', tape: Map.put(tape, cursor, 1), cursor: cursor + 1}
      1 -> %{state: 'B', tape: Map.put(tape, cursor, 0), cursor: cursor + 1}
    end
  end

  # In state E:
  #   If the current value is 0:
  #     - Write the value 1.
  #     - Move one slot to the left.
  #     - Continue with state F.
  #   If the current value is 1:
  #     - Write the value 1.
  #     - Move one slot to the left.
  #     - Continue with state C.
  defp execute(%{state: 'E', tape: tape, cursor: cursor}) do
    case value(tape, cursor) do
      0 -> %{state: 'F', tape: Map.put(tape, cursor, 1), cursor: cursor - 1}
      1 -> %{state: 'C', tape: Map.put(tape, cursor, 1), cursor: cursor - 1}
    end
  end

  # In state F:
  #   If the current value is 0:
  #     - Write the value 1.
  #     - Move one slot to the right.
  #     - Continue with state D.
  #   If the current value is 1:
  #     - Write the value 1.
  #     - Move one slot to the right.
  #     - Continue with state A.
  defp execute(%{state: 'F', tape: tape, cursor: cursor}) do
    case value(tape, cursor) do
      0 -> %{state: 'D', tape: Map.put(tape, cursor, 1), cursor: cursor + 1}
      1 -> %{state: 'A', tape: Map.put(tape, cursor, 1), cursor: cursor + 1}
    end
  end

  defp value(tape, cursor) do
    tape[cursor] || 0
  end
end

# Perform a diagnostic checksum after 12173597 steps.
TuringMachine.diagnostic_checksum(12173597) |> IO.puts

