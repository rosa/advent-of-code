// --- Day 5: Hydrothermal Venture ---

import std.stdio, std.array, std.regex, std.algorithm, std.conv, std.range, std.container;

struct Segment {
  int x1, y1, x2, y2;

  void init(int[] coords) {
    assert(coords.length == 4);
    x1 = coords[0];
    y1 = coords[1];
    x2 = coords[2];
    y2 = coords[3];
  }

  bool isVertical() {
    return x1 == x2;
  }

  bool isHorizontal() {
    return y1 == y2;
  }

  auto verticalRange() {
    int step = (y1 <= y2) ? 1 : -1;
    return iota(y1, y2 + step, step);
  }

  auto horizontalRange() {
    int step = (x1 <= x2) ? 1 : -1;
    return iota(x1, x2 + step, step);
  }
}

struct Floor {
  int[][] grid = new int[][](1000, 1000);
  bool diagonals = false;

  void addSegment(Segment s) {
    if (s.isHorizontal()) {
      foreach (i; s.horizontalRange()) {
        grid[s.y1][i]++;
      }
    } else if (s.isVertical()) {
      foreach (i; s.verticalRange()) {
        grid[i][s.x1]++;
      }
    } else if (diagonals) {
      foreach (i, j; zip(s.verticalRange(), s.horizontalRange())) {
        grid[i][j]++;
      }
    }
  }

  ulong overlaps() {
    return grid.map!(r => overlaps(r)).array.reduce!("a + b");
  }

  ulong overlaps(int[] row) {
    return row.count!("a > 1");
  }
}

void main(string[] args) {
  Floor floor1, floor2 = { diagonals:true };

  foreach (line; args[1].File.byLine) {
    // Line of vents: 0,9 -> 5,9
    auto vents = line.matchFirst(`(\d+),(\d+) -> (\d+),(\d+)`);
    vents.popFront();

    Segment s;
    s.init(vents.map!(s => s.to!int).array);

    floor1.addSegment(s);
    floor2.addSegment(s);
  }

  writeln(floor1.overlaps());
  writeln(floor2.overlaps());
}

// dmd day05.d
// ./day05 inputs/input05.txt
// 7085
// 20271
