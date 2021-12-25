package day21

import "core:fmt"

play_deterministic :: proc(start: [2]i64, goal: i64) -> ([2]i64, i64) {
  current: [2]i64 = start - {1, 1}
  scores := [2]i64{0, 0}
  count, die: i64 = 0, 0

  for scores[0] < (goal - 1) && scores[1] < (goal - 1) {
    for _, i in current {
      current[i] += die * 3 + 6
      current[i] %= 10
      die += 3
      die %= 100
      count += 3

      scores[i] += current[i] + 1

      if scores[i] >= (goal - 1) {
        break
      }
    }
  }

  return scores, count
}

// Rolling the Dirac dice 3 times can only yield numbers from
// 3 to 9 in total, and not all of them with the same probability
// These are the times each number is yield:
// 3 - 1 time (1 + 1 + 1)
// 4 - 3 times (1 + 1 + 2, 1 + 2 + 1...)
// 5 - 6 times (1 + 2 + 2, 1 + 3 + 1...)
// 6 - 7 times (1 + 2 + 3, 2 + 2 + 2...)
// 7 - 6 times (1 + 3 + 3, 2 + 2 + 3...)
// 8 - 3 times (2 + 3 + 3, 3 + 2 + 3...)
// 9 - 1 time (3 + 3 + 3)
// For a total of 27 (3^2) results
branches := map[i64]i64{3 = 1, 4 = 3, 5 = 6, 6 = 7, 7 = 6, 8 = 3, 9 = 1,}

play_dirac :: proc(start: [2]i64, goal: i64) -> [2]i64 {
  current := start - {1, 1}
  return play_dirac_turn(current, goal, 0, {0, 0}, {0, 0})
}

play_dirac_turn :: proc(current_position: [2]i64, goal: i64, turn: i64, scores: [2]i64, universes: [2]i64) -> [2]i64 {
  next_universes := universes
  next_turn := (turn + 1) % 2

  for die, multiplier in branches {
    next_position := current_position
    next_position[turn] += die
    next_position[turn] %= 10

    next_scores := scores
    next_scores[turn] += next_position[turn] + 1
    if next_scores[turn] >= goal {
      next_universes[turn] += multiplier
    } else {
      continue_playing := play_dirac_turn(next_position, goal, next_turn, next_scores, universes)
      next_universes += {multiplier, multiplier} * continue_playing
    }
  }

  return next_universes
}

main :: proc() {
  scores, count := play_deterministic({5, 9}, 1000)
  fmt.println(count * min(scores[0], scores[1]))

  universes := play_dirac({5, 9}, 21)
  fmt.println(max(universes[0], universes[1]))
}

// odin run day21.odin
// 989352
// 430229563871565
