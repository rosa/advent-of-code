#! /usr/local/bin/pike

// --- Day 17: Trick Shot ---

mapping(string:array(int)) parse_area(string data)
{
  array area = array_sscanf(data, "target area: x=%d..%d, y=%d..%d");
  return ([ "x":({area[0], area[1]}), "y":({area[2], area[3]}) ]);
}

bool in_area(mapping(string:array(int)) area, int x, int y)
{
  return area["x"][0] <= x && x <= area["x"][1] && area["y"][0] <= y && y <= area["y"][1];
}

bool passed_area(mapping(string:array(int)) area, int x, int y)
{
  return x > area["x"][1] || y < area["y"][0];
}

int highest_point_reached(int velocity, int steps)
{
  if (steps <= velocity)
    return (2 * velocity - steps + 1) * steps / 2;
  else
    return velocity * (velocity + 1) / 2;
}

int fire_probe(mapping(string:int) velocities, mapping(string:array(int)) area)
{
  int x, y, steps = 0;
  int velocity = velocities["y"];

  while (true) {
    x += velocities["x"];
    y += velocities["y"];
    steps++;

    if (velocities["x"] > 0)
      velocities["x"] = velocities["x"] - 1;
    velocities["y"] = velocities["y"] - 1;

    if (in_area(area, x, y))
      return highest_point_reached(velocity, steps);

    if (passed_area(area, x, y))
      return -1;
  }
}

int find_best_probe(mapping(string:array(int)) area)
{
  int highest, candidate = 0;

  for (int vx = 1; vx <= area["x"][1]; vx++)
    for (int vy = area["y"][0]; vy <= area["x"][1]*2; vy++)
    {
      candidate = fire_probe((["x": vx, "y": vy]), area);
      if (candidate > highest)
        highest = candidate;
    }

  return highest;
}

int count_all_probes(mapping(string:array(int)) area)
{
  int candidate, count = 0;

  for (int vx = 1; vx <= area["x"][1]; vx++)
    for (int vy = area["y"][0]; vy <= area["x"][1]*2; vy++)
    {
      candidate = fire_probe((["x": vx, "y": vy]), area);
      if (candidate >= 0)
        count++;
    }

  return count;
}

int main(int argc, array(string) argv)
{
  Stdio.File file = Stdio.File(argv[1], "r");
  string data = file.read();
  file.close();

  mapping(string:array(int)) area = parse_area(data);
  int highest = find_best_probe(area);
  write("%d\n", highest);

  int count = count_all_probes(area);
  write("%d\n", count);

  return 0;
}

// pike day17.pike inputs/input17.txt
// 13203
// 5644
