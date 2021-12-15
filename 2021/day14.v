// --- Day 14: Extended Polymerization ---

import os
import regex
import math

fn input(path string) (string, map[string]string) {
  lines := os.read_lines(path) or { panic('error reading $path') }

  mut reactions := map[string]string{}
  // Format of rules: CH -> B
  query := r'([A-Z][A-Z]) -> ([A-Z])'
  mut re := regex.regex_opt(query) or { panic(err) }

  for line in lines[2..] {
    re.match_string(line)
    group_list := re.get_group_list()
    if group_list.len == 2 {
      pair := line[group_list[0].start..group_list[0].end]
      element := line[group_list[1].start..group_list[1].end]
      reactions[pair] = element
    }
  }

  return lines[0], reactions
}

fn count_pairs(template string) map[string]i64 {
  mut counts := map[string]i64{}
  for i in 0 .. template.len - 1 {
    pair := template[i .. i + 2]
    counts[pair] += 1
  }

  return counts
}

fn count_elements(template string, pairs_count map[string]i64) map[string]i64 {
  mut counts := map[string]i64{}

  for pair, count in pairs_count {
    counts[pair[0].ascii_str()] += count
    counts[pair[1].ascii_str()] += count
  }

  // Each element except the first and last are always counted twice as they belong in two pairs
  // The first and last are counted twice except for one time
  for element, count in counts {
    counts[element] = count / 2
  }

  counts[template[0].ascii_str()] += 1
  counts[template[template.len - 1].ascii_str()] += 1

  return counts
}

fn step(pairs_count map[string]i64, reactions map[string]string) map[string]i64 {
  mut new_counts := map[string]i64{}

  for pair, count in pairs_count {
    result := reactions[pair]
    new_counts[pair[0].ascii_str() + result] += count
    new_counts[result + pair[1].ascii_str()] += count
  }

  return new_counts
}

fn react(template string, reactions map[string]string, steps int) map[string]i64 {
  mut pairs_count := count_pairs(template)
  for _ in 0 .. steps {
    pairs_count = step(pairs_count, reactions)
  }

  return count_elements(template, pairs_count)
}

fn most_and_least_difference(counts map[string]i64) i64 {
  mut max := i64(0)
  mut min := math.max_i64
  for _, v in counts {
    if v > max { max = v }
    if v < min { min = v }
  }
  return max - min
}

fn main() {
  template, reactions := input('inputs/input14.txt')
  // Part 1
  println(most_and_least_difference(react(template, reactions, 10)))

  // Part 2
  println(most_and_least_difference(react(template, reactions, 40)))
}

// v run day14.v
// 3213
// 3711743744429
