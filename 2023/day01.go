// --- Day 1: Trebuchet?! ---

package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

var Numbers = map[string]int{
  "one": 1,
  "two": 2,
  "three": 3,
  "four": 4,
  "five": 5,
  "six": 6,
  "seven": 7,
  "eight": 8,
  "nine": 9,
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

func calibrationValueFromLine(line string, all bool) int {
	x, y := numbersFromLine(line, all)
	return x * 10 + y
}

func calibrationValue(lines []string, all bool) int {
	sum := 0

	for _, line := range lines {
		sum += calibrationValueFromLine(line, all)
	}

	return sum
}

func firstAndLastIndices(line string, substring string) (int, int) {
	return strings.Index(line, substring), strings.LastIndex(line, substring)
}


func numbersFromLine(line string, all bool) (int, int) {
	x, y := 0, 0
	min := len(line)
	max := -1

	for n, i := range Numbers {
		c := strconv.Itoa(i)
		first1, last1 := firstAndLastIndices(line, c)
		first2, last2 := first1, last1

		if all {
			first2, last2 = firstAndLastIndices(line, n)
		}

		first := first1
		if first < 0 || first2 >= 0 && first2 < first {
			first = first2
		}

		last := last1
		if last < 0 || last2 > last {
			last = last2
		}

		if first >= 0 && first < min {
			min = first
			x = i
		}
		if last >= 0 && last > max {
			max = last
			y = i
		}
	}

	return x, y
}

func main() {
	input := readInput()

	// Part One
	fmt.Println(calibrationValue(input, false))

	// Part Two
	fmt.Println(calibrationValue(input, true))
}
