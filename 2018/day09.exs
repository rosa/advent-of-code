# --- Day 9: Marble Mania ---

defmodule Marbles do
  def high_score(players), do: Enum.max(players)

  def play(nmarbles, nplayers), do: play(nmarbles + 1, 0, 0, [0], List.duplicate(0, nplayers), 0, 1)

  def play(0, _current, _current_position, _circle, players, _turn, _size), do: players
  def play(nmarbles, current, current_position, circle, players, turn, size) do
    if rem(current + 1, 23) == 0 do
      # First, the current player keeps the marble they would have placed, adding it to their score.
      # In addition, the marble 7 marbles counter-clockwise from the current marble is removed from
      # the circle and also added to the current player's score. The marble located immediately
      # clockwise of the marble that was removed becomes the new current marble.
      new_position = (current_position - 7) |> rem(size) |> normalize(size)
      score = current + 1 + Enum.at(circle, new_position) + Enum.at(players, turn)
      play(nmarbles - 1, current + 1, new_position, List.delete_at(circle, new_position), List.replace_at(players, turn, score), turn + 1, size - 1)
    else
      # Placing the lowest-numbered remaining marble into the circle between the marbles that are
      # 1 and 2 marbles clockwise of the current marble.
      # The marble that was just placed then becomes the current marble.
      new_position = rem((current_position + 1), size) + 1
      play(nmarbles - 1, current + 1, new_position, List.insert_at(circle, new_position, current + 1), players, rem(turn + 1, length(players)), size + 1)
    end
  end

  def play_with_deque(nmarbles, nplayers), do: play_with_deque(nmarbles + 1, 0, 1, Deque.new(), List.duplicate(0, nplayers), 0)

  def play_with_deque(0, _current, _next_marble, _deque, players, _turn), do: players
  def play_with_deque(nmarbles, current, next_marble, deque, players, turn) do
    if rem(next_marble, 23) == 0 do
      # First, the current player keeps the marble they would have placed, adding it to their score.
      # In addition, the marble 7 marbles counter-clockwise from the current marble is removed from
      # the circle and also added to the current player's score. The marble located immediately
      # clockwise of the marble that was removed becomes the new current marble.
      to_remove = Deque.get_counter_clockwise(deque, current, 7)
      score = current + 1 + to_remove.value + Enum.at(players, turn)
      play_with_deque(nmarbles - 1, to_remove.next, next_marble + 1, Deque.delete_at(deque, to_remove.value), List.replace_at(players, turn, score), turn + 1)
    else
      # Placing the lowest-numbered remaining marble into the circle between the marbles that are
      # 1 and 2 marbles clockwise of the current marble.
      # The marble that was just placed then becomes the current marble.
      insert_at_id = deque[current].next
      play_with_deque(nmarbles - 1, next_marble, next_marble + 1, Deque.insert_at(deque, insert_at_id, next_marble), players, rem(turn + 1, length(players)))
    end
  end

  defp normalize(position, len) do
    if position < 0, do: len + position, else: position
  end
end

defmodule Deque do
  alias Deque.Node

  def new() do
    %{ 0 => Node.new_node(0, 0, 0) }
  end

  def insert_at(nodes, node_id, value) do
    %{next: next} = nodes[node_id]
    new_node = Node.new_node(value, node_id, next)
    with_modified_next = Map.put(nodes, next, %{nodes[next] | previous: value})

    Map.put(with_modified_next, node_id, %{with_modified_next[node_id] | next: value})
    |> Map.put(value, new_node)
  end

  def delete_at(nodes, node_id) do
    %{next: next, previous: previous} = nodes[node_id]
    modified_previous = %{nodes[previous] | next: next}
    with_modified_previous = Map.put(nodes, modified_previous.value, modified_previous)
    modified_next = %{with_modified_previous[next] | previous: previous}

    Map.put(with_modified_previous, modified_next.value, modified_next)
    |> Map.delete(node_id)
  end

  def get_counter_clockwise(nodes, node_id, 0), do: nodes[node_id]
  def get_counter_clockwise(nodes, node_id, offset) do
    %{previous: previous} = nodes[node_id]
    get_counter_clockwise(nodes, previous, offset-1)
  end
end

defmodule Deque.Node do
  defstruct(
    previous: nil,
    next: nil,
    value: nil
  )

  def new_node(value, previous, next) do
    %Deque.Node{
      value: value,
      previous: previous,
      next: next
    }
  end
end


# 441 players; last marble is worth 71032 points
Marbles.play(71032, 441) |> Marbles.high_score() |> IO.puts()

# --- Part Two ---

# What would the new winning Elf's score be if the number of the last marble were 100 times larger?
Marbles.play_with_deque(7103200, 441) |> Marbles.high_score() |> IO.puts()
