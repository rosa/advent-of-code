# --- Day 20: Donut Maze ---

import tables, hashes

type
  Coord = tuple
    i: int
    j: int

type
  LeveledCoord = tuple
    coord: Coord
    level: int

type
  Portal = ref object
    name: string
    coord: Coord

type
  DonutMaze = object
    graph: Table[Coord, seq[Coord]]
    portals: Table[string, seq[Coord]]

proc hash(c: Coord): Hash =
  result = c.i.hash !& c.j.hash
  result = !$result
proc `==`(c1: Coord, c2: Coord): bool =
  c1.i == c2.i and c1.j == c2.j

proc hash(c: LeveledCoord): Hash =
  result = hash(c.coord) !& c.level.hash
  result = !$result
proc `==`(c1: LeveledCoord, c2: LeveledCoord): bool =
  c1.coord == c2.coord and c1.level == c2.level


proc isAlpha(c: char): bool =
  c >= 'A' and c <= 'z'


proc readLines(filename: string): seq[string] =
  result = @[]
  for line in filename.lines:
    result.add(line)


proc parsePortal(lines: seq[string], i: int, j: int): Portal =
  # A - i     . - i-1
  # B - i+1   A - i
  # . - i+2   B - i+1
  if i+1 < lines.len and isAlpha(lines[i+1][j]):
    new(result)
    result.name = $lines[i][j] & lines[i+1][j]
    if i-1 >= 0 and lines[i-1][j] == '.':
      result.coord = (i-1, j)
    elif i+2 < lines.len and lines[i+2][j] == '.':
      result.coord = (i+2, j)
  # .AB - (j-1, j, j+1)
  # AB. - (j, j+1, j+2)
  elif j+1 < lines[i].len and isAlpha(lines[i][j+1]):
    new(result)
    result.name = $lines[i][j] & lines[i][j+1]
    if j-1 >= 0 and lines[i][j-1] == '.':
      result.coord = (i, j-1)
    elif j+2 < lines[i].len and lines[i][j+2] == '.':
      result.coord = (i, j+2)

proc parseNeighbours(lines: seq[string], i: int, j: int): seq[Coord] =
  result = @[]
  if i-1 >= 0 and lines[i-1][j] == '.':
    result.add((i-1, j))
  if i+1 < lines.len and lines[i+1][j] == '.':
    result.add((i+1, j))
  if j-1 >= 0 and lines[i][j-1] == '.':
    result.add((i, j-1))
  if j+1 < lines[i].len and lines[i][j+1] == '.':
    result.add((i, j+1))


proc parseDonutMaze(lines: seq[string]): DonutMaze =
  var graph = initTable[Coord, seq[Coord]]()
  var portals = initTable[string, seq[Coord]]()

  for i in 0..<lines.len:
    let line = lines[i]
    for j in 0..<line.len:
      if isAlpha(line[j]):
        let portal = parsePortal(lines, i, j)
        if portal != nil:
          discard portals.hasKeyOrPut(portal.name, @[])
          portals[portal.name].add(portal.coord)
      elif line[j] == '.':
        graph[(i, j)] = parseNeighbours(lines, i, j)

  # Add portals to graph
  for name, coords in portals.pairs:
    if coords.len == 2:
      graph[coords[0]].add(coords[1])
      graph[coords[1]].add(coords[0])

  result = DonutMaze(graph: graph, portals: portals)

proc nextCandidate(nodes: seq[Coord], distances: Table[Coord, int]): int =
  var min = high(int)
  for index, node in nodes.pairs:
    if distances[node] < min:
      min = distances[node]
      result = index

# Dijkstra
proc findShortestPath(maze: DonutMaze, source: Coord, target: Coord): int =
  var q: seq[Coord] = @[]
  var dist = initTable[Coord, int]()
  var prev = initTable[Coord, Coord]()

  for coord in maze.graph.keys:
    q.add(coord)
    dist[coord] = high(int)
  dist[source] = 0

  while q.len > 0:
    let index = nextCandidate(q, dist)
    let u = q[index]
    q.delete(index)

    if u == target:
      result = dist[u]
      return

    for v in maze.graph[u].items:
      let alt = dist[u] + 1
      if alt < dist[v]:
        dist[v] = alt
        prev[v] = u

  result = dist[target]

# Levels
proc connectedPortals(coord1: Coord, coord2: Coord): bool =
  abs(coord1.i - coord2.i) > 1 or abs(coord1.j - coord2.j) > 1

proc levelDifference(coord: Coord): int =
  # Bounds for inner ring
  # if coord.i > 6 and coord.i < 32 and coord.j > 7 and coord.j < 40:
  if coord.i > 20 and coord.i < 90 and coord.j > 20 and coord.j < 100:
    # Entering in the inner portal
    result = 1
  else:
    # Entering in the outer portal
    result = -1

proc bfs(maze: DonutMaze, source: LeveledCoord, target: LeveledCoord): int =
  var queue: seq[(LeveledCoord, int)] = @[(source, 0)]
  var dist = initTable[LeveledCoord, int]()

  while queue.len > 0:
    let next: (LeveledCoord, int) = queue.pop()
    let u = next[0]
    if not dist.hasKey(u):
      dist[u] = next[1]
      if u == target:
        result = dist[target]
        return

      for v in maze.graph[u.coord].items:
        if connectedPortals(u.coord, v):
          if u.level + levelDifference(u.coord) >= 0: # Can't go outer than the outermost level
            let leveledv = (v, u.level + levelDifference(u.coord))
            queue.insert((leveledv, dist[u] + 1))
        else:
          queue.insert(((v, u.level), dist[u] + 1))

  result = dist[target]

var filename = "inputs/input20.txt"
let maze = parseDonutMaze(readLines(filename))

# --- Part One ---
echo findShortestPath(maze, maze.portals["AA"][0], maze.portals["ZZ"][0])

# --- Part Two ---
echo bfs(maze, (maze.portals["AA"][0], 0), (maze.portals["ZZ"][0], 0))

# nim compile --run day20.nim
# Hint: system [Processing]
# Hint: widestrs [Processing]
# Hint: io [Processing]
# Hint: day20 [Processing]
# Hint: tables [Processing]
# Hint: hashes [Processing]
# Hint: math [Processing]
# Hint: bitops [Processing]
# Hint: macros [Processing]
# Hint: algorithm [Processing]
# CC: stdlib_system.nim
# CC: stdlib_tables.nim
# CC: day20.nim
# Hint:  [Link]
# Hint: operation successful (22933 lines compiled; 1.464 sec total; 33.242MiB peakmem; Debug Build) [SuccessX]
# Hint: advent-of-code/2019/day20  [Exec]
# 522
# 6300
