// --- Day 2: Cube Conundrum ---

package main

import (
  "bufio"
  "fmt"
  "os"
  "strconv"
  "strings"
  "regexp"
)

type Game struct {
  Subsets []GameSubset
  Id      int
}

// red, green, blue
var Colours = []string{"red", "green", "blue"}
type GameSubset [3]int

type Subset interface {
  IsPossible() bool
  MinSet() GameSubset
}

// 12 red cubes, 13 green cubes, and 14 blue cubes?
var Limits = []int{12, 13, 14}

func (subset GameSubset) IsPossible() bool {
  for i, v := range subset {
    if v > Limits[i] {
      return false
    }
  }

  return true
}

func (game Game) IsPossible() bool {
  for _, subset := range game.Subsets {
    for i, v := range subset {
      if v > Limits[i] {
        return false
      }
    }
  }

  return true
}

func (game Game) MinSet() GameSubset {
  maxs := GameSubset{0, 0, 0}

  for _, subset := range game.Subsets {
    for i, v := range subset {
      if v > maxs[i] {
        maxs[i] = v
      }
    }
  }

  return maxs
}

func readInput() []string {
  lines := []string{}
  scanner := bufio.NewScanner(os.Stdin)
  for scanner.Scan() {
    line := scanner.Text()
    lines = append(lines, line)
  }

  return lines
}

func parseGameId(line string) int {
  var id int
  fmt.Sscanf(line, "Game %d:", &id)
  return id
}

func parseGameSubsets(line string) []GameSubset {
  subsets := []GameSubset{}

  pattern := regexp.MustCompile(`Game \d+: (.+)`)
  matches := pattern.FindStringSubmatch(line)

  for _, match := range strings.Split(matches[1], ";") {
    subset := parseGameSubset(match)
    subsets = append(subsets, subset)
  }

  return subsets
}

func parseGameSubset(line string) GameSubset {
  subset := GameSubset{0, 0, 0}

  for i, colour := range Colours {
    pattern := regexp.MustCompile(`(\d+) ` + colour)
    matches := pattern.FindStringSubmatch(line)
    if len(matches) >= 2 {
      subset[i], _ = strconv.Atoi(matches[1])
    }
  }

  return subset
}

func parseGame(line string) Game {
  var game Game

  game.Id = parseGameId(line)
  game.Subsets = parseGameSubsets(line)

  return game
}

func parseGames(lines []string) []Game {
  games := []Game{}

  for _, line := range lines {
    game := parseGame(line)
    games = append(games, game)
  }

  return games
}

func possibleGameScore(games []Game) int {
  sum := 0

  for _, game := range games {
    if game.IsPossible() {
      sum += game.Id
    }
  }

  return sum
}

func powerMinGameScore(games []Game) int {
  sum := 0

  for _, game := range games {
    minset := game.MinSet()
    sum += minset[0] * minset[1] * minset[2]
  }

  return sum
}

func main() {
  input := readInput()
  games := parseGames(input)

  // Part One
  fmt.Println(possibleGameScore(games))

  // Part Two
  fmt.Println(powerMinGameScore(games))
}
