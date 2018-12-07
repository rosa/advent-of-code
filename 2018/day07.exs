# --- Day 7: The Sum of Its Parts ---

# In what order should the steps in your instructions be completed?
defmodule Assembly do
  def sorted_steps(instructions) do
    instructions
    |> parse()
    |> sort()
    |> Enum.join()
  end

  def time_parallel_steps(instructions, n) do
    instructions
    |> parse()
    |> time(n)
  end

  def read(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
  end

  def parse(lines), do: parse(%{}, lines)
  def parse(graph, []), do: graph
  def parse(graph, [line | lines]) do
    {step, prerequisite} = parse_instruction(line)

    Map.update(graph, step, [prerequisite], &(&1 ++ [prerequisite]))
    |> Map.put_new(prerequisite, [])
    |> parse(lines)
  end

  # Step L must be finished before step A can begin.
  def parse_instruction(instruction) do
    parsed = Regex.named_captures(~r/Step (?<prerequisite>[A-Z]) must be finished before step (?<step>[A-Z]) can begin./, instruction)
    {parsed["step"], parsed["prerequisite"]}
  end

  def sort(graph), do: sort(graph, [])
  def sort(graph, steps) when map_size(graph) == 0, do: steps
  def sort(graph, steps) do
    next = next_steps(graph) |> hd
    complete_prerequisites(graph, [next])
    |> Map.delete(next)
    |> sort(steps ++ [next])
  end

  def time(graph, n), do: time(graph, List.duplicate(0, n), 0, 0, [])
  def time(graph, _workers, _current_time, total_time, _in_progress) when map_size(graph) == 0, do: total_time
  def time(graph, workers, current_time, _total_time, in_progress) do
    next = next_steps(graph) |> Enum.take(Enum.count(workers, &(&1 <= current_time)))
    times = Enum.map(next, &time/1)
    started = Enum.zip(next, times) |> Enum.map(fn {s, t} -> {s, t + current_time} end)

    updated_workers = assign_steps(workers, times, current_time)
    next_current_time = if length(next) == 0, do: Enum.min(Enum.map(in_progress ++ started, &last/1)), else: Enum.min(updated_workers)
    completed = (in_progress ++ started) |> Enum.filter(&(last(&1) <= next_current_time))

    complete_prerequisites(graph, Enum.map(completed, &first/1))
    |> Map.drop(next)
    |> time(updated_workers, next_current_time, Enum.max(updated_workers), (in_progress ++ started) -- completed)
  end

  def next_steps(graph) do
    Enum.filter(graph, &(last(&1) == []))
    |> Enum.map(&first/1)
    |> Enum.sort()
  end

  def assign_steps(workers, [], current_time), do: workers |> Enum.map(&(max(&1, current_time)))
  def assign_steps(workers, times, current_time) do
    workers |> Enum.map(&(max(&1, current_time)))
    |> Enum.sort()
    |> Enum.zip(Enum.sort(times, &(&1 >= &2)) ++ List.duplicate(0, length(workers) - length(times)))
    |> Enum.map(fn {v1, v2} -> v1 + v2 end)
    |> Enum.map(fn v -> max(v, current_time) end)
  end

  def complete_prerequisites(graph, prerequisite) do
    Enum.map(graph, fn {k, v} -> {k, v -- prerequisite} end)
    |> Enum.reduce(%{}, fn {k, v}, acc -> Map.put(acc, k, v) end)
  end

  def time(step) do
    hd(to_charlist(step)) - hd(to_charlist('A')) + 1 + 60
  end

  defp first({x, _}), do: x
  defp last({_, y}), do: y
end

Assembly.read("./inputs/input07.txt") |> Assembly.sorted_steps() |> IO.puts()

# --- Part Two ---

Assembly.read("./inputs/input07.txt") |> Assembly.time_parallel_steps(5) |> IO.puts()
