# --- Day 16: Ticket Translation ---

defmodule TicketScanning do
  def error_rate({rules, _, nearby_tickets}) do
    Enum.map(nearby_tickets, fn ticket -> error_rate(rules, ticket) end)
    |> Enum.sum
  end
  def error_rate(rules, ticket) do
    Enum.filter(ticket, fn value -> invalid?(rules, value) end)
    |> Enum.sum
  end

  def find_departure({rules, ticket, nearby_tickets}) do
    Enum.filter(nearby_tickets, fn ticket -> error_rate(rules, ticket) == 0 end)
    |> sort_fields(rules)
    |> find_departure(ticket)
  end
  def find_departure(order, ticket) do
    departure_fields(order)
    |> Enum.map(fn name -> order[name] end)
    |> Enum.map(fn position -> Enum.at(ticket, position) end)
    |> Enum.reduce(&(&1 * &2))
  end

  def read_rules_and_tickets(file) do
    [rules, ticket, nearby_tickets ] = File.read!(file) |> String.split(~r{\n\n}, trim: true)
    {parse_rules(rules), List.first(parse_tickets(ticket)), parse_tickets(nearby_tickets)}
  end

  defp departure_fields(order) do
    Map.keys(order)
    |> Enum.filter(fn name -> String.starts_with?(name, "departure") end)
  end

  defp sort_fields(tickets, rules) do
    Enum.map(rules, fn rule -> {elem(rule, 0), valid_positions(rule, tickets)} end)
    |> Enum.into(%{})
    |> deduce_order()
  end

  defp deduce_order(valid_positions), do: deduce_order(valid_positions, %{})
  defp deduce_order(valid_positions, order) when map_size(valid_positions) == 0, do: order
  defp deduce_order(valid_positions, order) do
    {name, [position]} = Enum.find(valid_positions, fn {_, positions} -> Enum.count(positions) == 1 end)
    Map.delete(valid_positions, name)
    |> Enum.reduce(%{}, fn ({name, positions}, acc) -> Map.put(acc, name, positions -- [position]) end)
    |> Enum.reject(fn {_, positions} -> Enum.count(positions) == 0 end)
    |> Enum.into(%{})
    |> deduce_order(Map.put(order, name, position))
  end

  defp valid_positions(rule, tickets) do
    0..Enum.count(List.first(tickets)) - 1
    |> Enum.filter(fn i -> Enum.all?(tickets, fn ticket -> valid?(rule, Enum.at(ticket, i)) end) end)
  end

  defp invalid?(rules, value), do: Enum.all?(rules, fn rule -> !valid?(rule, value) end)

  defp valid?({_, {range1, range2}}, value), do: value in range1 || value in range2

  defp parse_rules(rules) do
    String.split(rules, ~r{\n}, trim: true)
    |> Enum.map(&parse_rule/1)
  end

  defp parse_rule(rule) do
    # departure location: 47-874 or 885-960
    [_, name|ranges] = Regex.run(~r{([a-z ]+): (\d+)-(\d+) or (\d+)-(\d+)}, rule)
    {name, to_ranges(Enum.map(ranges, &String.to_integer/1))}
  end

  defp to_ranges([r1, r2, s1, s2]), do: {r1..r2, s1..s2}

  defp parse_tickets(tickets) do
    String.split(tickets, ~r{\n}, trim: true)
    |> Enum.drop(1)
    |> Enum.map(&parse_ticket/1)
  end

  defp parse_ticket(ticket), do: String.split(ticket, ",") |> Enum.map(&String.to_integer/1)
end

TicketScanning.read_rules_and_tickets("inputs/input16.txt") |> TicketScanning.error_rate |> IO.puts

# --- Part Two ---

TicketScanning.read_rules_and_tickets("inputs/input16.txt") |> TicketScanning.find_departure |> IO.puts
