# --- Day 11: Dumbo Octopus ---

import file as F

fun string-to-number-value(s :: String) -> Number:
  cases(Option) string-to-number(s):
    | some(a) => a
    | none => 0
  end
end

fun octopus-grid(path :: String) -> List<List<Number>>:
  lines = for filter(line from string-split-all(F.file-to-string(path), "\n")):
    string-length(line) > 0
  end

  for map(line from lines):
    for map(c from string-explode(line)):
      string-to-number-value(c)
    end
  end
end

fun flash(grid :: List<List<Number>>, i :: Number, j :: Number) -> List<List<Number>> block:
  incrs = [list: -1, 0, 1]
  var flashed-grid = grid
  incrs.each(lam(x):
    incrs.each(lam(y):
      when (((i + x) >= 0) and ((i + x) < grid.length()) and ((j + y) >= 0) and ((j + y) < grid.get(i + x).length()) and (grid.get(i + x).get(j + y) <> 0)) block:
        var row = flashed-grid.get(i + x)
        row := if (x == 0) and (y == 0):
          row.set(j + y, 0)
        else:
          row.set(j + y, row.get(j + y) + 1)
        end
        flashed-grid := flashed-grid.set(i + x, row)
      end
    end)
  end)

  flashed-grid
end

fun step-increment(grid :: List<List<Number>>) -> List<List<Number>>:
  for map(row from grid):
    for map(octopus from row):
      octopus + 1
    end
  end
end

fun step-flash(grid :: List<List<Number>>) -> List<List<Number>> block:
  var flashed = false
  var flashed-grid = grid

  each_n(lam(i, row):
    each_n(lam(j, v):
      when (v > 9) block:
        flashed-grid := flash(flashed-grid, i, j)
        flashed := true
      end
    end, 0, row)
  end, 0, flashed-grid)

  if (flashed):
    step-flash(flashed-grid)
  else:
    flashed-grid
  end
end

fun step(grid :: List<List<Number>>) -> List<List<Number>>:
  step-flash(step-increment(grid))
end

fun simulate(grid :: List<List<Number>>, steps :: Number) -> Number block:
  var simulated-grid = grid
  var flashes = 0

  range(0, steps).each(lam(s) block:
    simulated-grid := step(simulated-grid)

    flashes := simulated-grid.map(lam(row):
      row.filter(lam(x): x == 0 end).length()
    end).foldr(lam(elt, acc): elt + acc end, flashes)
  end)

  flashes
end

fun simulate-until-sync(grid :: List<List<Number>>, steps :: Number) -> Number:
  if (grid.all(lam(row): row.all(lam(x): x == 0 end) end)):
    steps
  else:
    simulate-until-sync(step(grid), steps + 1)
  end
end

grid = octopus-grid("inputs/input11.txt")
print(num-to-string(simulate(grid, 100)) + "\n")
print(num-to-string(simulate-until-sync(grid, 0)) + "\n")

# pyret day11.arr
# 1659
# 227
