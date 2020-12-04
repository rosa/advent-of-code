# --- Day 4: Passport Processing ---

defmodule Passports do
  @required_fields ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]

  def read_passports(file) do
    File.read!(file)
    |> String.split(~r{\n\n}, trim: true)
    |> Enum.map(fn x -> String.split(x, ~r{\s}, trim: true) end)
    |> Enum.map(fn x -> parse_passport(x) end)
  end

  def present?(passport) do
    Enum.all?(@required_fields, fn field -> Map.has_key?(passport, field) end)
  end

  def valid?(passport) do
    Enum.all?(@required_fields, fn field -> valid?(field, passport[field]) end)
  end

  defp valid?(_, nil), do: false
  # byr (Birth Year) - four digits; at least 1920 and at most 2002.
  defp valid?("byr", value), do: four_digits?(value) && in_range?(1920..2002, value)
  # iyr (Issue Year) - four digits; at least 2010 and at most 2020.
  defp valid?("iyr", value), do: four_digits?(value) && in_range?(2010..2020, value)
  # eyr (Expiration Year) - four digits; at least 2020 and at most 2030.
  defp valid?("eyr", value), do: four_digits?(value) && in_range?(2020..2030, value)
  # hgt (Height) - a number followed by either cm or in:
  # If cm, the number must be at least 150 and at most 193.
  # If in, the number must be at least 59 and at most 76.
  defp valid?("hgt", value) do
    matches = Regex.run(~r{(\d+)(in|cm)}, value)
    if matches do
      [_, number, unit] = matches
      case unit do
        "cm" -> in_range?(150..193, number)
        "in" -> in_range?(59..76, number)
        _ -> false
      end
    end
  end
  # hcl (Hair Color) - a # followed by exactly six characters 0-9 or a-f.
  defp valid?("hcl", value), do: String.match?(value, ~r/^#[0-9a-f]{6}$/)
  # ecl (Eye Color) - exactly one of: amb blu brn gry grn hzl oth.
  defp valid?("ecl", value), do: Enum.member?(["amb", "blu", "brn", "gry", "grn", "hzl", "oth"], value)
  # pid (Passport ID) - a nine-digit number, including leading zeroes.
  defp valid?("pid", value), do: String.match?(value, ~r/^\d{9}$/)

  defp four_digits?(value), do: String.length(value) == 4
  defp in_range?(range, value), do: Enum.member?(range, String.to_integer(value))

  defp parse_passport(passport) do
    Enum.map(passport, &String.split(&1, ":"))
    |> Enum.map(&List.to_tuple/1)
    |> Enum.into(%{})
  end
end

Passports.read_passports("inputs/input04.txt") |> Enum.count(&Passports.present?/1) |> IO.puts

# --- Part Two ---
Passports.read_passports("inputs/input04.txt") |> Enum.count(&Passports.valid?/1) |> IO.puts
