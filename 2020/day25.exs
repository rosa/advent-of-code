# --- Day 25: Combo Breaker ---

defmodule ComboBreaker do

  # Transform a subject number.
  # To transform a subject number, start with the value 1.
  # Then, a number of times called the loop size, perform the following steps:
  # - Set the value to itself multiplied by the subject number.
  # - Set the value to the remainder after dividing the value by 20201227.
  def transform_subject_number(number, loop_size), do: transform_subject_number(1, number, loop_size)
  def transform_subject_number(value, _, 0), do: value
  def transform_subject_number(value, number, loop_size) do
    transform_subject_step(value, number)
    |> transform_subject_number(number, loop_size - 1)
  end

  def transform_subject_step(value, number), do: value * number |> rem(20201227)

  # The cryptographic handshake works like this:
  # - The card transforms the subject number of 7 according to the card's secret loop size. The result is called the card's public key.
  # - The door transforms the subject number of 7 according to the door's secret loop size. The result is called the door's public key.
  # - The card and door use the wireless RFID signal to transmit the two public keys (your puzzle input) to the other device.
  #   Now, the card has the door's public key, and the door has the card's public key. 
  # - Because you can eavesdrop on the signal, you have both public keys, but neither device's loop size.
  # - The card transforms the subject number of the door's public key according to the card's loop size. The result is the encryption key.
  # - The door transforms the subject number of the card's public key according to the door's loop size. The result is the same encryption key as the card calculated.
  def workout_loop_size(public_key), do: workout_loop_size(7, 1, public_key)
  def workout_loop_size(public_key, loop_size, public_key), do: loop_size
  def workout_loop_size(value, loop_size, public_key) do
    transform_subject_step(value, 7)
    |> workout_loop_size(loop_size + 1, public_key)
  end
end

# Input
# 17773298
# 15530095
#
card_public_key = 17773298
door_public_key = 15530095
card_loop_size = ComboBreaker.workout_loop_size(card_public_key)
door_loop_size = ComboBreaker.workout_loop_size(door_public_key)

ComboBreaker.transform_subject_number(door_public_key, card_loop_size) |> IO.puts
ComboBreaker.transform_subject_number(card_public_key, door_loop_size) |> IO.puts
