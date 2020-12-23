# --- Day 22: Crab Combat ---

defmodule Combat do
  def score({_, deck}), do: score(deck)
  def score(deck) do
    Enum.with_index(deck)
    |> Enum.map(fn {card, i} -> card * (Enum.count(deck) - i) end)
    |> Enum.sum
  end

  def play_regular({deck1, []}), do: {:player1, deck1}
  def play_regular({[], deck2}), do: {:player2, deck2}
  def play_regular(decks), do: play_regular_round(decks) |> play_regular

  def play_recursive({deck1, deck2}), do: play_recursive({deck1, deck2}, MapSet.new)
  def play_recursive({deck1, []}, _), do: {:player1, deck1}
  def play_recursive({[], deck2}, _), do: {:player2, deck2}
  def play_recursive({deck1, deck2}, configurations) do
    if MapSet.member?(configurations, identifier(deck1, deck2)) do
      {:player1, deck1}
    else
      play_recursive_round({deck1, deck2})
      |> play_recursive(MapSet.put(configurations, identifier(deck1, deck2)))
    end
  end

  def play_recursive_round(decks = {[card1|cards1], [card2|cards2]}) do
    if Enum.count(cards1) >= card1 && Enum.count(cards2) >= card2 do
      {winner, _} = play_recursive({Enum.take(cards1, card1), Enum.take(cards2, card2)})
      case winner do
        :player1 -> {cards1 ++ [card1, card2], cards2}
        :player2 -> {cards1, cards2 ++ [card2, card1]}
      end
    else
      play_regular_round(decks)
    end
  end

  def play_regular_round({[card1|cards1], [card2|cards2]}) when card1 > card2, do: {cards1 ++ [card1, card2], cards2}
  def play_regular_round({[card1|cards1], [card2|cards2]}), do: {cards1, cards2 ++ [card2, card1]}

  def identifier(deck1, deck2), do: Enum.join(deck1, ",") <> "|" <> Enum.join(deck2, ",")

  def read_decks(file) do
    File.read!(file)
    |> String.split(~r{\n\n}, trim: true)
    |> Enum.map(fn deck -> String.split(deck, ~r{\n}, trim: true) end)
    |> Enum.map(&parse_deck/1)
    |> List.to_tuple
  end

  defp parse_deck([_|cards]), do: Enum.map(cards, &String.to_integer/1)
end

Combat.read_decks("inputs/input22.txt") |> Combat.play_regular |> Combat.score |> IO.puts

# --- Part Two ---

Combat.read_decks("inputs/input22.txt") |> Combat.play_recursive |> Combat.score |> IO.inspect

