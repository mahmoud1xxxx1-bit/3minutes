import random
from collections import deque

def get_grid(state, blocks_info):
    grid = [[-1]*6 for _ in range(6)]
    for i, (x, y) in enumerate(state):
        isH, length = blocks_info[i]
        for j in range(length):
            if isH: grid[y][x+j] = i
            else:   grid[y+j][x] = i
    return grid

def get_neighbors(state, blocks_info):
    grid = get_grid(state, blocks_info)
    neighbors = []
    for i, (x, y) in enumerate(state):
        isH, length = blocks_info[i]
        if isH:
            if x > 0 and grid[y][x-1] == -1:
                ns = list(state); ns[i] = (x-1, y); neighbors.append(tuple(ns))
            if x + length < 6 and grid[y][x+length] == -1:
                ns = list(state); ns[i] = (x+1, y); neighbors.append(tuple(ns))
        else:
            if y > 0 and grid[y-1][x] == -1:
                ns = list(state); ns[i] = (x, y-1); neighbors.append(tuple(ns))
            if y + length < 6 and grid[y+length][x] == -1:
                ns = list(state); ns[i] = (x, y+1); neighbors.append(tuple(ns))
    return neighbors

def is_solved(state): return state[0][0] == 4

def solve(start_state, blocks_info):
    queue = deque([(start_state, 0)])
    visited = set([start_state])
    while queue:
        state, depth = queue.popleft()
        if is_solved(state): return depth
        for n in get_neighbors(state, blocks_info):
            if n not in visited:
                visited.add(n)
                queue.append((n, depth+1))
    return -1

def random_walk_reverse(state, blocks_info, steps=1000):
    visited = set()
    current = state
    for _ in range(steps):
        neighbors = get_neighbors(current, blocks_info)
        # Avoid moving the target block to the exit
        valid_neighbors = [n for n in neighbors if n[0][0] < 4]
        if not valid_neighbors:
            valid_neighbors = neighbors
        current = random.choice(valid_neighbors)
        visited.add(current)
    # Find the state in visited with the highest solve depth
    max_depth = -1
    best_state = state
    
    # We evaluate a random sample to find a hard one
    sample = random.sample(list(visited), min(100, len(visited)))
    for s in sample:
        d = solve(s, blocks_info)
        if d > max_depth:
            max_depth = d
            best_state = s
    return best_state, max_depth

# Define templates (blocks_info)
templates = [
    [(True, 2), (False, 3), (True, 2), (False, 2), (False, 2), (True, 2)],
    [(True, 2), (False, 3), (False, 2), (True, 2), (True, 2), (False, 2), (True, 2)],
    [(True, 2), (False, 2), (False, 2), (True, 2), (True, 3), (False, 3), (False, 2), (True, 2)],
    [(True, 2), (False, 3), (True, 3), (False, 2), (False, 2), (True, 2), (True, 2), (False, 2), (False, 2)],
    [(True, 2), (False, 2), (False, 3), (True, 2), (False, 3), (True, 2), (False, 2), (True, 2), (False, 2), (True, 2)],
    [(True, 2), (False, 3), (False, 3), (True, 2), (False, 2), (False, 2), (True, 2), (False, 2), (False, 2), (True, 2), (True, 2)]
]

levels = []
for i, b_info in enumerate(templates):
    # Try to find a valid solved state to start from
    while True:
        # Place target at (4,2)
        state = [(4,2)]
        grid = [[-1]*6 for _ in range(6)]
        grid[2][4] = grid[2][5] = 0
        valid = True
        for j in range(1, len(b_info)):
            isH, length = b_info[j]
            placed = False
            for _ in range(100):
                x = random.randint(0, 6 - (length if isH else 1))
                y = random.randint(0, 6 - (1 if isH else length))
                # Check overlap
                overlap = False
                for k in range(length):
                    if isH and grid[y][x+k] != -1: overlap = True; break
                    if not isH and grid[y+k][x] != -1: overlap = True; break
                if not overlap:
                    state.append((x, y))
                    for k in range(length):
                        if isH: grid[y][x+k] = j
                        else: grid[y+k][x] = j
                    placed = True
                    break
            if not placed:
                valid = False
                break
        if valid:
            best_s, depth = random_walk_reverse(tuple(state), b_info, 1000)
            if depth >= (i+1)*4: # Ensure it has some minimum difficulty
                levels.append((best_s, b_info, depth))
                print(f"Level {i+1} generated with depth {depth}")
                break

dart_code = []
for i, (state, blocks_info, depth) in enumerate(levels):
    dart_code.append(f"      // Level {i+1} (Min Moves: {depth})")
    dart_code.append("      [")
    for j, ((x, y), (isH, length)) in enumerate(zip(state, blocks_info)):
        isTarget = 'true' if j == 0 else 'false'
        dart_code.append(f"        PuzzleBlock(id: {j}, x: {x}, y: {y}, length: {length}, isHorizontal: {'true' if isH else 'false'}, isTarget: {isTarget}),")
    dart_code.append("      ],")

with open('lib/features/minigames/presentation/key_escape/key_escape_levels.dart', 'w') as f:
    f.write('''class PuzzleBlock {
  final int id;
  int x;
  int y;
  final int length;
  final bool isHorizontal;
  final bool isTarget;
  double logicalX;
  double logicalY;
  
  PuzzleBlock({
    required this.id, required this.x, required this.y,
    required this.length, required this.isHorizontal, this.isTarget = false,
  }) : logicalX = x.toDouble(), logicalY = y.toDouble();

  PuzzleBlock copy() => PuzzleBlock(id: id, x: x, y: y, length: length, isHorizontal: isHorizontal, isTarget: isTarget);
}

class KeyEscapeLevels {
  static List<PuzzleBlock> getLevel(int index) {
    List<List<PuzzleBlock>> levels = [
''')
    f.write('\n'.join(dart_code))
    f.write('''
    ];
    return levels[index % levels.length].map((b) => b.copy()).toList();
  }
}
''')
