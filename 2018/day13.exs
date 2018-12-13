# --- Day 13: Mine Cart Madness ---

defmodule Carts do
  alias Carts.Cart

  def read_and_parse_track(file) do
    read(file)
    |> parse_track_and_carts()
  end

  def run_ticks({tracks, carts}, mode \\ :first_collision), do: run_ticks(carts, tracks, mode)
  def run_ticks(carts, tracks, mode = :first_collision) do
    if collision?(carts) do
      carts
    else
      run_ticks_common(carts, tracks, mode)
    end
  end
  def run_ticks([cart], _tracks, :until_the_end), do: cart
  def run_ticks(carts, tracks, mode = :until_the_end), do: run_ticks_common(carts, tracks, mode)

  defp run_ticks_common(carts, tracks, mode) do
    sort(carts)
    |> run_tick(tracks, mode) |> IO.inspect()
    |> run_ticks(tracks, mode)
  end

  defp run_tick(carts, tracks, mode), do: run_tick(carts, tracks, [], mode)
  defp run_tick([], _tracks, results, _mode), do: results

  defp run_tick([cart | carts], tracks, results, mode = :first_collision) do
    updated_cart = Cart.move(cart)
    if collision?(results ++ [updated_cart] ++ carts) do
      results ++ [updated_cart] ++ carts
    else
      run_tick(carts, tracks, results ++ [Cart.adjust_direction(updated_cart, tracks[updated_cart.position])], mode)
    end
  end

  defp run_tick([cart | carts], tracks, results, mode = :until_the_end) do
    updated_cart = Cart.move(cart)
    collided? = fn c -> c.position == updated_cart.position end

    if collision?(results ++ [updated_cart] ++ carts) do
      run_tick(Enum.reject(carts, &(collided?.(&1))), tracks, Enum.reject(results, &(collided?.(&1))), mode)
    else
      run_tick(carts, tracks, results ++ [Cart.adjust_direction(updated_cart, tracks[updated_cart.position])], mode)
    end
  end

  defp sort(carts) do
    Enum.sort(carts, &Cart.compare/2)
  end

  defp parse_track_and_carts(rows), do: parse_track_and_carts(rows, %{}, [], 0)
  defp parse_track_and_carts([], track, carts, _y), do: {track, carts}
  defp parse_track_and_carts([row | rows], track, carts, y) do
    {updated_track, updated_carts} = parse_row(row, track, carts, y, 0)
    parse_track_and_carts(rows, updated_track, updated_carts, y + 1)
  end

  defp parse_row([], track, carts, _y, _x), do: {track, carts}
  defp parse_row([" " | row], track, carts, y, x), do: parse_row(row, track, carts, y, x + 1)
  defp parse_row([c | row], track, carts, y, x) when c in [">", "<", "^", "v"] do
    parse_row(row, Map.put(track, {x, y}, Cart.track_under(c)), carts ++ [Cart.new(c, {x, y})], y, x + 1)
  end
  defp parse_row([c | row], track, carts, y, x) do
    parse_row(row, Map.put(track, {x, y}, c), carts, y, x + 1)
  end

  defp read(file) do
    File.read!(file)
    |> String.split(~r{\n}, trim: true)
    |> Enum.map(&String.graphemes/1)
  end

  defp collision?([]), do: false
  defp collision?([cart | carts]), do: Enum.any?(carts, fn another_cart -> another_cart.position == cart.position end) || collision?(carts)
end

defmodule Carts.Cart do
  defstruct(
    direction: nil,
    position: nil,
    next_turn: nil
  )

  def new(direction, position, next_turn \\ :left) do
    %Carts.Cart{
      direction: direction,
      position: position,
      next_turn: next_turn
    }
  end

  def track_under(direction) do
    case direction do
      ">" -> "-"
      "<" -> "-"
      "^" -> "|"
      "v" -> "|"
    end
  end

  def compare(%{position: {x, y}}, %{position: {u, v}}), do: {y, x} <= {v, u}

  def move(cart = %{direction: "^", position: {x, y}}), do: new(cart.direction, {x, y-1}, cart.next_turn)
  def move(cart = %{direction: "v", position: {x, y}}), do: new(cart.direction, {x, y+1}, cart.next_turn)
  def move(cart = %{direction: ">", position: {x, y}}), do: new(cart.direction, {x+1, y}, cart.next_turn)
  def move(cart = %{direction: "<", position: {x, y}}), do: new(cart.direction, {x-1, y}, cart.next_turn)

  # Each time a cart has the option to turn (by arriving at any intersection), it turns left the first time,
  # goes straight the second time, turns right the third time, and then repeats those directions starting
  # again with left the fourth time, straight the fifth time, and so on.
  def adjust_direction(cart = %{next_turn: :left}, "+"), do: new(calculate_direction(cart.direction, :left), cart.position, :straight)
  def adjust_direction(cart = %{next_turn: :straight}, "+"), do: new(cart.direction, cart.position, :right)
  def adjust_direction(cart = %{next_turn: :right}, "+"), do: new(calculate_direction(cart.direction, :right), cart.position, :left)

  # Curves
  def adjust_direction(cart, "\\"), do: new(calculate_direction(cart.direction, :curve_1), cart.position, cart.next_turn)
  def adjust_direction(cart, "/"), do: new(calculate_direction(cart.direction, :curve_2), cart.position, cart.next_turn)
  def adjust_direction(cart, "-"), do: cart
  def adjust_direction(cart, "|"), do: cart

  @turns %{
    left: %{"^" => "<", "v" => ">", ">" => "^", "<" => "v"},
    right: %{"^" => ">", "v" => "<", ">" => "v", "<" => "^"},
    curve_1: %{"^" => "<", "v" => ">", ">" => "v", "<" => "^"},
    curve_2: %{"^" => ">", "v" => "<", ">" => "^", "<" => "v"}
  }
  defp calculate_direction(direction, turn) do
    @turns[turn][direction]
  end
end


Carts.read_and_parse_track("./inputs/input13.txt")
|> Carts.run_ticks()
|> IO.inspect()

# --- Part Two ---
Carts.read_and_parse_track("./inputs/input13.txt")
|> Carts.run_ticks(:until_the_end)
|> IO.inspect()
