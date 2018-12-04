# --- Day 4: Repose Record ---

# Strategy 1: Find the guard that has the most minutes asleep.
# What minute does that guard spend asleep the most?
defmodule Guards do

  # Strategy 1: Find the guard that has the most minutes asleep.
  # What minute does that guard spend asleep the most?
  # What is the ID of the guard you chose multiplied by the minute you chose?
  def strategy1(file) do
    {guard, times} = lines(file)
    |> log()
    |> guards()
    |> most_often_asleep()

    {minute, _} = most_common_minute(times)
    minute * String.to_integer(guard)
  end

  # Strategy 2: Of all guards, which guard is most frequently asleep on the same minute?
  # What is the ID of the guard you chose multiplied by the minute you chose?
  def strategy2(file) do
    {guard, {minute, _}} = lines(file)
    |> log()
    |> guards()
    |> Enum.map(fn {guard, times} -> {guard, most_common_minute(times)} end)
    |> Enum.max_by(fn {_, {_, count}} -> count end)

    minute * String.to_integer(guard)
  end

  defp most_common_minute(times) do
    ranges = Enum.chunk_every(times, 2)
    |> Enum.map(fn [{:wake_up, wake_up}, {:fall_asleep, fall_asleep}] -> fall_asleep..wake_up-1 end)

    count = fn m -> Enum.count(ranges, fn r -> Enum.member?(r, m) end) end
    minute = Enum.max_by(0..60, fn m -> count.(m) end)

    {minute, count.(minute)}
  end

  defp most_often_asleep(guards), do: Enum.max_by(guards, fn {_, times} -> time_asleep(times) end)

  defp time_asleep(times) do
    Enum.chunk_every(times, 2)
    |> Enum.map(fn [{:wake_up, wake_up}, {:fall_asleep, fall_asleep}] -> wake_up - fall_asleep end)
    |> Enum.sum()
  end

  defp guards(log), do: guards(log, %{}, %{})
  defp guards([], guards, _current), do: guards
  defp guards([line = %{"type" => :begin_shift} | log], guards, current) do
    guards(log, flush(current, guards), %{ guard: line["guard"], times: [] })
  end
  defp guards([line | log], guards, current) do
    guards(log, guards, log_time(current, line["time"], line["type"]))
  end

  defp flush(current, guards) when map_size(current) == 0, do: guards
  defp flush(current, guards) do
    guards
    |> Map.update(current[:guard], current[:times], fn time_asleep -> current[:times] ++ time_asleep end)
  end

  defp log_time(current, time, action) do
    times = current[:times]
    Map.put(current, :times, [{action, time} | times])
  end

  defp log(lines) do
    Enum.map(lines, &parse/1)
    |> Enum.sort(&(&1["full_time"] <= &2["full_time"]))
  end

  # [1518-11-01 00:00] Guard #10 begins shift
  # [1518-11-01 00:05] falls asleep
  # [1518-11-01 00:25] wakes up
  defp parse(line) do
    cond do
      String.match?(line, ~r/begins/) -> begin_shift(line)
      String.match?(line, ~r/asleep/) -> action(line, :fall_asleep)
      String.match?(line, ~r/wakes/) -> action(line, :wake_up)
    end
  end

  @date_regex "\\[(?<full_time>(?<day>\\d{4}-\\d{2}-\\d{2}) \\d{2}:(?<time>\\d{2}))\\]"

  # [1518-11-01 00:00] Guard #10 begins shift
  defp begin_shift(line) do
    Regex.named_captures(~r/#{@date_regex} Guard #(?<guard>\d+) begins shift/, line)
    |> Map.update("time", 0, &String.to_integer/1)
    |> Map.put("type", :begin_shift)
  end

  # [1518-11-01 00:05] falls asleep
  # [1518-11-01 00:25] wakes up
  defp action(line, type) do
    Regex.named_captures(~r/#{@date_regex}/, line)
    |> Map.update("time", 0, &String.to_integer/1)
    |> Map.put("type", type)
  end

  defp lines(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
  end
end

Guards.strategy1("./inputs/input04.txt") |> IO.puts

# --- Part Two ---

Guards.strategy2("./inputs/input04.txt") |> IO.puts
