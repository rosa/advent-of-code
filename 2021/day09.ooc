// --- Day 9: Smoke Basin ---

import io/File
import text/StringTokenizer
import structs/ArrayList
import structs/HashMap

Location: cover {
  i, j, value: Int

  riskLevel: func -> Int {
    return value + 1
  }

  low?: func (heightMap: ArrayList<ArrayList<Int>>) -> Bool {
    isLow := true
    for (loc in neighbours(heightMap)) {
      if (value >= loc value) {
        isLow = false
        break
      }
    }
    return isLow
  }

  limit?: func -> Bool {
    return value == 9
  }

  neighbours: func (heightMap: ArrayList<ArrayList<Int>>) -> ArrayList<Location> {
    n := heightMap size
    m := heightMap[i] size
    neighbours := ArrayList<Location> new()

    if (i > 0) neighbours add((i-1, j, heightMap[i-1][j]) as Location)
    if (j > 0) neighbours add((i, j-1, heightMap[i][j-1]) as Location)
    if (i < n - 1) neighbours add((i+1, j, heightMap[i+1][j]) as Location)
    if (j < m - 1) neighbours add((i, j+1, heightMap[i][j+1]) as Location)

    return neighbours
  }

  toString: func -> String {
    return "(%d, %d) -> %d " format(i, j, value)
  }
}

parse: func(contents: String) -> ArrayList<ArrayList<Int>> {
  parsed := ArrayList<ArrayList<Int>> new()
  for (line in contents split('\n')) {
    s := line trim("\t ")
    if (s size > 0) parsed add(stringToInts(s))
  }
  return parsed
}

stringToInts: func (str: String) -> ArrayList<Int> {
  ints := ArrayList<Int> new()
  for (c in str) {
    ints add(c toInt())
  }

  return ints
}

findLows: func (heightMap: ArrayList<ArrayList<Int>>) -> ArrayList<Location> {
  lows := ArrayList<Location> new()
  for (i in 0..heightMap size) {
    row := heightMap[i]
    for (j in 0..row size) {
      loc := (i, j, heightMap[i][j]) as Location
      if (loc low?(heightMap)) lows add(loc)
    }
  }

  return lows
}

findBasin: func(low: Location, heightMap: ArrayList<ArrayList<Int>>, basin: HashMap<Location, Bool>) {
  for (loc in low neighbours(heightMap)) {
    if (!loc limit?() && !basin get(loc)) {
      basin put(loc, true)
      findBasin(loc, heightMap, basin)
    }
  }
}

max: func(list: ArrayList<Int>) -> Int {
  max := list[0]
  for (n in list) if (n > max) max = n
  return max
}

top3: func(list: ArrayList<Int>) -> (Int, Int, Int) {
  x := max(list)
  list remove(x)
  y := max(list)
  list remove(y)
  z := max(list)
  return (x, y, z)
}

main: func (args: String[]) {
  input := File new(args[1]) read()
  heightMap := parse(input)

  lows := findLows(heightMap)
  riskLevel := lows map(|loc| loc riskLevel()) reduce(|a, b| a + b)

  println(riskLevel toString())

  basinSizes := ArrayList<Int> new()

  for (loc in lows) {
    basin := HashMap<Location, Bool> new()
    findBasin(loc, heightMap, basin)
    basinSizes add(basin getKeys() size as Int)
  }

  (x, y, z) := top3(basinSizes)
  println((x * y * z) toString())
}

// rock -v day09.ooc
// ./day09 inputs/input09.txt
// 444
// 1168440
