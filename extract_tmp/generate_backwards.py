import random
from collections import deque

def solve(start_state, blocks_info):
    def get_neighbors(state):
        grid = [[-1]*6 for _ in range(6)]
        for i, (x, y) in enumerate(state):
            isH, length = blocks_info[i]
            for j in range(length):
                if isH: grid[y][x+j] = i
                else:   grid[y+j][x] = i
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

    queue = deque([(start_state, 0)])
    visited = set([start_state])
    while queue:
        state, depth = queue.popleft()
        if state[0][0] == 4: return depth
        for n in get_neighbors(state):
            if n not in visited:
                visited.add(n)
                queue.append((n, depth+1))
    return -1

def get_neighbors(state, blocks_info):
    grid = [[-1]*6 for _ in range(6)]
    for i, (x, y) in enumerate(state):
        isH, length = blocks_info[i]
        for j in range(length):
            if isH: grid[y][x+j] = i
            else:   grid[y+j][x] = i
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

def generate_from_template(blocks_info, target_depth):
    # Create a valid solved state by putting Target at (4,2)
    # and placing other blocks randomly
    for _ in range(1000):
        grid = [[-1]*6 for _ in range(6)]
        grid[2][4] = 0
        grid[2][5] = 0
        state = [(4, 2)]
        valid = True
        for i in range(1, len(blocks_info)):
            isH, length = blocks_info[i]
            placed = False
            for _ in range(50):
                x = random.randint(0, 6 - (length if isH else 1))
                y = random.randint(0, 6 - (1 if isH else length))
                overlap = False
                for j in range(length):
                    if isH and grid[y][x+j] != -1: overlap = True
                    if not isH and grid[y+j][x] != -1: overlap = True
                if not overlap:
                    for j in range(length):
                        if isH: grid[y][x+j] = i
                        else: grid[y+j][x] = i
                    state.append((x, y))
                    placed = True
                    break
            if not placed:
                valid = False
                break
        if valid:
            # Random walk backwards
            current = tuple(state)
            visited = set([current])
            best_state = current
            max_depth = 0
            
            for _ in range(5000):
                ns = get_neighbors(current, blocks_info)
                valid_ns = [n for n in ns if n not in visited and n[0][0] < 4]
                if not valid_ns:
                    break
                current = random.choice(valid_ns)
                visited.add(current)
                
            # Sample 20 states to find hardest
            sample = random.sample(list(visited), min(20, len(visited)))
            for s in sample:
                d = solve(s, blocks_info)
                if d > max_depth:
                    max_depth = d
                    best_state = s
                    
            if max_depth >= target_depth:
                return best_state, max_depth
                
    return None, 0

templates = [
    [(True, 2), (False, 3), (True, 2), (False, 2), (False, 2), (True, 2), (False, 2)],
    [(True, 2), (False, 3), (False, 2), (True, 2), (True, 2), (False, 2), (True, 2), (False, 2)],
    [(True, 2), (False, 2), (False, 2), (True, 2), (True, 3), (False, 3), (False, 2), (True, 2)],
    [(True, 2), (False, 3), (True, 3), (False, 2), (False, 2), (True, 2), (True, 2), (False, 2)],
    [(True, 2), (False, 2), (False, 3), (True, 2), (False, 3), (True, 2), (False, 2), (True, 2)],
]

levels = []
targets = []
for i in range(15):
    t = random.choice(templates)
    print(f"Generating level {i+1}...")
    s, d = generate_from_template(t, 20)
    if s:
        levels.append((s, t, d))
        targets.append(str(d))
        print(f"Found! Depth: {d}")
    else:
        print("Failed to find hard level for template.")

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
  static int getTargetMoves(int index) {
    List<int> targets = [''' + ', '.join(targets) + '''];
    return targets[index % targets.length];
  }
  static List<PuzzleBlock> getLevel(int index) {
    List<List<PuzzleBlock>> levels = [\n''')
    f.write('\n'.join(dart_code))
    f.write('''\n    ];
    return levels[index % levels.length].map((b) => b.copy()).toList();
  }
}''')
