# --- Day 24: Crossed Wires ---

defmodule Wired do
  def swaps({inputs, gates}) do
    Enum.map(gates, fn {key, {op, t1, t2}} -> {key, {op_to_string(op), t1, t2}} end)
    |> Enum.into(%{})
    |> reverse_engineer(inputs)
  end

  def run({inputs, gates}) do
    targets = number(inputs, gates, "z")

    run(inputs, targets, gates)
    |> compile_number(targets)
  end

  def run(inputs, [], _), do: inputs
  def run(inputs, [t|targets], gates) do
    calculate(inputs, t, gates) |> run(targets, gates)
  end

  # Multi-bit adder https://en.wikipedia.org/wiki/Adder_(electronics)#Full_adder
  # z00 = x00 XOR y00
  # c01 = x00 AND y00
  defp reverse_engineer(gates, inputs) do
    if gate_match?(Map.get(gates, "z00"), {"XOR", "x00", "y00"}) do
      cin = find_gate(gates, {"AND", "x00", "y00"})
      reverse_engineer(gates, cin, inputs)
    else
      ["z00"]
    end
  end

  defp check_gates(_, _, i) when i >= 45, do: true
  defp check_gates(gates, cin, i) do
    suffix = Integer.to_string(i) |> String.pad_leading(2, "0")
    di = find_gate(gates, {"XOR", "x#{suffix}", "y#{suffix}"})
    zi = find_gate(gates, {"XOR", di, cin})
    fi = find_gate(gates, {"AND", "x#{suffix}", "y#{suffix}"})
    gi = find_gate(gates, {"AND", di, cin})
    cout = find_gate(gates, {"OR", fi, gi})

    IO.inspect("z#{suffix} -> #{zi}; d#{suffix} -> #{di}; f#{suffix} -> #{fi}; cout -> #{cout};")
    !is_nil(di) and !is_nil(zi) and !is_nil(fi) and !is_nil(gi) and !is_nil(cout) and check_gates(gates, cout, i+1)
  end

  # z01 = (x01 XOR y01) XOR c01 = d01 XOR c01
  # d01 = x01 XOR y01
  # c02 = ((x01 XOR y01) AND c01) OR (x01 AND y01) = (d01 AND c01) OR (f01) = g01 OR f01
  # f01 = x01 AND y01
  # g01 = d01 AND c01
  defp reverse_engineer(gates, cin, inputs) do
    suffixes = for i <- 1..44, do: Integer.to_string(i) |> String.pad_leading(2, "0")
    ds = Enum.map(suffixes, fn suffix -> {"d#{suffix}", find_gate(gates, {"XOR", "x#{suffix}", "y#{suffix}"})} end) |> Enum.into(%{})

    # z01 = (x01 XOR y01) XOR c01 = d01 XOR c01
    zgates = Enum.map(suffixes, fn suffix -> {"z#{suffix}", Map.get(gates, "z#{suffix}")} end)
    |> Enum.reject(fn {_, {op, _, _}} -> op != "XOR" end)
    |> Enum.into(%{})
    # [
    #   {"z10", {"AND", "mvs", "jvj"}},
    #   {"z14", {"OR", "vjh", "fhq"}},
    #   {"z34", {"AND", "y34", "x34"}}
    # ]
    # found = [ "z10", "z14" ]

    z10 = find_partial_matches(gates, {"XOR", Map.get(ds, "d10")})
    # [{"mkk", {"XOR", "jvj", "mvs"}}]
    z14 = find_partial_matches(gates, {"XOR", Map.get(ds, "d14")})
    # [{"qbw", {"XOR", "ndm", "tsp"}}]
    # found = [ {"z10", "mkk"}, {"z14", "qbw"} ]
    z34 = find_partial_matches(gates, {"XOR", Map.get(ds, "d34")})
    # [{"wcb", {"XOR", "jmq", "mdh"}}]
    # f = x01 AND y01
    #   {"z34", {"AND", "y34", "x34"}}
    # z34 has been swapped with f34
    # z34 = d34 XOR c34
    # g01 = d01 AND c01

    g34 = find_partial_matches(gates, {"AND", Map.get(ds, "d34")})
    # [{"cgh", {"AND", "mdh", "jmq"}}]
    c34 = find_partial_matches(gates, {"OR", g34})
    # {"mpd", {"OR", "cgh", "wcb"}}
    # f34 = wcb, exchanged with z34
    # found = [ {"z10", "mkk"}, {"z14", "qbw"}, {"z34", "wcb"}, "wjb"]
    # z01 = (x01 XOR y01) XOR c01 = d01 XOR c01
    cs = Enum.map(suffixes, fn suffix -> {suffix, Map.get(gates, "z#{suffix}")} end)
    |> Enum.map(fn {suffix, gate} -> {"c#{suffix}", Tuple.to_list(gate) -- ["XOR", Map.get(ds, "d#{suffix}")]} end)
    |> Enum.into(%{})

    wrong_cs = Enum.filter(cs, fn {c, v} -> length(v) != 1 end)
    # [{"c25", ["cvp", "fqv"]}]
    find_gate(gates, {"XOR", "cvp", "fqv"})
    # z25 = cvp XOR fqv = d25 XOR c25
    Map.get(gates, "wjb")
    # {"XOR", "x25", "y25"}
    # d25 = wjb
    Map.get(gates, "cvp")
    # {"AND", "x25", "y25"}
    # f25 = cvp
    Map.get(gates, "fqv")
    # {"OR", "jfm", "mcr"}
    Map.get(gates, "jfm")
    Map.get(gates, "mcr")
    # {"AND", "x24", "y24"} => f24 = jfm
    # {"AND", "qmn", "fvt"} => g24 = mcr
    Map.get(gates, "qmn")
    # {"XOR", "y24", "x24"} => d24 = qmn

    updated_gates = Map.put(gates, "z10", Map.get(gates, "mkk"))
    |> Map.put("mkk", Map.get(gates, "z10"))
    |> Map.put("z14", Map.get(gates, "qbw"))
    |> Map.put("qbw", Map.get(gates, "z14"))
    |> Map.put("z34", Map.get(gates, "wcb"))
    |> Map.put("wcb", Map.get(gates, "z34"))
    |> Map.put("wjb", Map.get(gates, "cvp"))
    |> Map.put("cvp", Map.get(gates, "wjb"))

    unless check_gates(updated_gates, cin, 1) do
      IO.puts("invalid")
    end

    updated_gates = Enum.map(updated_gates, fn {res, {op, t1, t2}} -> {res, {parse_op(op), t1, t2}} end) |> Enum.into(%{})

    run({inputs, updated_gates})

    [ {"z10", "mkk"}, {"z14", "qbw"}, {"z34", "wcb"}, {"wjb", "cvp"}] |> Enum.flat_map(&Tuple.to_list/1) |> Enum.sort() |> Enum.join(",")
  end

  defp gate_match?({op, t1, t2}, {op, t1, t2}), do: true
  defp gate_match?({op, t1, t2}, {op, t2, t1}), do: true
  defp gate_match?(_, _), do: false

  defp partial_gate_match?({op, t}, {op, q1, q2}), do: t in [q1, q2]
  defp partial_gate_match?(_, _), do: false

  def find_gate(gates, gate) do
    found = Enum.find(gates, fn {_, v} -> gate_match?(gate, v) end)
    if found do
      elem(found, 0)
    end
  end

  def find_partial_matches(gates, gate) do
    Enum.filter(gates, fn {_, v} -> partial_gate_match?(gate, v) end)
  end

  defp compile_number(inputs, targets) do
    Enum.map(targets, fn t -> Map.get(inputs, t) end)
    |> Enum.map(&Integer.to_string/1)
    |> Enum.join()
    |> String.to_integer(2)
  end

  defp number(inputs, gates, key) do
    Map.keys(gates) ++ Map.keys(inputs)
    |> Enum.filter(&(String.starts_with?(&1, key)))
    |> Enum.sort()
    |> Enum.reverse()
  end

  defp calculate(inputs, t, gates) do
    if Map.has_key?(inputs, t) do
      inputs
    else
      {op, t1, t2} = Map.get(gates, t)
      updated_inputs = calculate(inputs, t1, gates) |> calculate(t2, gates)
      res = op.(Map.get(updated_inputs, t1), Map.get(updated_inputs, t2))
      Map.put(updated_inputs, t, res)
    end
  end

  defp parse_inputs(inputs), do: Enum.map(inputs, &parse_input/1) |> Enum.into(%{})
  defp parse_input(input) do
    [gate, ins] = String.split(input, ": ")
    {gate, String.to_integer(ins)}
  end

  defp parse_gates(gates), do: Enum.map(gates, &parse_gate/1) |> Enum.into(%{})
  defp parse_gate(gate) do
    [_, g1, op, g2, res] = Regex.run(~r/(\w+) (XOR|AND|OR) (\w+) -> (\w+)/, gate)
    {res, {parse_op(op), g1, g2}}
  end

  defp op_to_string(op) do
    cond do
      op == &:erlang.band/2 -> "AND"
      op == &:erlang.bor/2 -> "OR"
      op == &:erlang.bxor/2 -> "XOR"
    end
  end

  defp parse_op("OR"), do: &Bitwise.bor/2
  defp parse_op("AND"), do: &Bitwise.band/2
  defp parse_op("XOR"), do: &Bitwise.bxor/2

  def read_circuit(path) do
    [inputs, gates] = File.read!(path)
    |> String.split(~r{\n\n}, trim: true)
    |> Enum.map(fn lines -> String.split(lines, ~r{\n}, trim: true) end)

    {parse_inputs(inputs), parse_gates(gates)}
  end
end

Wired.read_circuit("inputs/input24.txt") |> Wired.run() |> IO.puts

# --- Part Two ---

Wired.read_circuit("inputs/input24.txt") |> Wired.swaps() |> IO.puts
