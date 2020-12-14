# --- Day 14: Docking Data ---

defmodule Docking do
  def initialize(instructions, type), do: initialize(instructions, {%{}, nil}, type)
  def initialize([], {memory, _}, _), do: memory
  def initialize([instruction|instructions], {memory, mask}, type), do: initialize(instructions, execute(instruction, memory, mask, type), type)

  def read_instructions(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
    |> Enum.map(&parse_instruction/1)
  end

  defp execute({:mask, mask}, memory, _, _), do: {memory, mask}
  defp execute({:mem, address, value}, memory, mask, :mask_value), do: {Map.put(memory, address, mask_value(value, Enum.reverse(mask))), mask}
  defp execute({:mem, address, value}, memory, mask, :mask_addresses), do: {mask_addresses(address, value, memory, Enum.reverse(mask)), mask}

  defp mask_addresses(address, value, memory, mask) do
    addresses_from_mask(address, mask)
    |> Enum.reduce(memory, fn (address, acc) -> Map.put(acc, address, value) end)
  end

  defp addresses_from_mask(address, mask) do
    to_padded_binary(address)
    |> addresses_from_mask(mask, [])
    |> Enum.map(&to_integer_from_binary/1)
  end
  defp addresses_from_mask([], [], result), do: [result]
  defp addresses_from_mask([a|address], ["0"|mask], result), do: addresses_from_mask(address, mask, [a|result])
  defp addresses_from_mask([_|address], ["1"|mask], result), do: addresses_from_mask(address, mask, ["1"|result])
  defp addresses_from_mask([_|address], ["X"|mask], result) do
    addresses_from_mask(address, mask, ["0"|result]) ++ addresses_from_mask(address, mask, ["1"|result])
  end

  defp mask_value(value, mask) do
    to_padded_binary(value)
    |> mask_value(mask, [])
  end
  defp mask_value([], [], result), do: to_integer_from_binary(result)
  defp mask_value([v|value], ["X"|mask], result), do: mask_value(value, mask, [v|result])
  defp mask_value([_|value], ["0"|mask], result), do: mask_value(value, mask, ["0"|result])
  defp mask_value([_|value], ["1"|mask], result), do: mask_value(value, mask, ["1"|result])

  defp to_padded_binary(value) do
    Integer.to_string(value, 2)
    |> String.graphemes
    |> pad(36)
    |> Enum.reverse
  end

  defp to_integer_from_binary(string), do: Enum.join(string) |> String.to_integer(2)

  defp pad(list, size), do: List.duplicate("0", size - Enum.count(list)) ++ list

  # mask = 0X10110X1001000X10X00X01000X01X01101
  # mem[49559] = 97
  defp parse_instruction(["mask", mask]), do: {:mask, String.graphemes(mask)}
  defp parse_instruction([mem, value]) do
    [_, address] = Regex.run(~r{mem\[(\d+)\]}, mem)
    {:mem, String.to_integer(address), String.to_integer(value)}
  end
  defp parse_instruction(instruction), do: String.split(instruction, " = ", trim: true) |> parse_instruction()
end

instructions = Docking.read_instructions("inputs/input14.txt")
Docking.initialize(instructions, :mask_value) |> Map.values |> Enum.sum |> IO.puts

# --- Part Two ---

Docking.initialize(instructions, :mask_addresses) |> Map.values |> Enum.sum |> IO.puts
