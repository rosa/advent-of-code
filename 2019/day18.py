# --- Day 18: Many-Worlds Interpretation ---

from collections import deque
import sys

_explored_paths = {}
def reset():
    _explored_paths = {}

def neighbours(position, tunnels):
    # Up, right, down, left
    moves = [(-1, 0), (0, 1), (1, 0), (0, -1)]
    neighbours = map(lambda x: (position[0] + x[0], position[1] + x[1]), moves)
    valid = filter(lambda x: tunnels[x[0]][x[1]] != '#', list(neighbours))
    return list(valid)

def reachable_keys(tunnels, current_position, current_keys):
    distances = {current_position: 0}
    keys = {}
    queue = deque([current_position])

    while queue:
        position = queue.popleft()
        for neighbour in neighbours(position, tunnels):
            if not neighbour in distances:
                distances[neighbour] = distances[position] + 1
                elem = tunnels[neighbour[0]][neighbour[1]]
                if elem.islower() and elem not in current_keys:
                    keys[elem] = neighbour
                elif elem.lower() in current_keys + ['.', '@']:
                    queue.append(neighbour)
    return (keys, distances)

def min_steps(tunnels, current_position, current_keys=[]):
    args = (current_position, ''.join(sorted(current_keys)))
    if args in _explored_paths:
        return _explored_paths[args]

    steps = sys.maxsize
    possible_keys, distances = reachable_keys(tunnels, current_position, current_keys)
    if possible_keys:
        for key, position in possible_keys.items():
            distance = distances[position] + min_steps(tunnels, position, current_keys + [key])
            if distance < steps:
                steps = distance
    else:
        steps = 0

    _explored_paths[args] = steps
    return steps

def min_steps_with_robots(tunnels, current_positions, current_keys=[]):
    args = (tuple(sorted(current_positions)), ''.join(sorted(current_keys)))
    if args in _explored_paths:
        return _explored_paths[args]

    steps = sys.maxsize
    possible_keys_by_robot, distances_by_robot = {}, {}
    for i, position in enumerate(current_positions):
        possible_keys_by_robot[i], distances_by_robot[i] = reachable_keys(tunnels, position, current_keys)

    if any(possible_keys_by_robot.values()):
        for i, possible_keys in possible_keys_by_robot.items():
            for key, position in possible_keys.items():
                new_positions = list(current_positions)
                new_positions[i] = position
                distance = distances_by_robot[i][position] + min_steps_with_robots(tunnels, new_positions, current_keys + [key])
                if distance < steps:
                    steps = distance

    else:
        steps = 0

    _explored_paths[args] = steps
    return steps


def read_tunnels(filename):
    with open(filename) as file:
        tunnels = [line.strip('\n') for line in file]
    return tunnels

def initial_positions(tunnels):
    initial_positions = []
    for i in range(len(tunnels)):
        initial_positions += [(i, j) for j, c in enumerate(tunnels[i]) if c == '@']

    return initial_positions

def main():
    # --- Part One ---
    tunnels = read_tunnels("inputs/input18-1.txt")
    current_position = initial_positions(tunnels)[0]
    print(min_steps(tunnels, current_position))

    # --- Part Two ---
    reset()
    tunnels = read_tunnels("inputs/input18-2.txt")
    robot_positions = initial_positions(tunnels)
    print(min_steps_with_robots(tunnels, robot_positions))

main()

# python3 day18.py
# 2946
# 1222
