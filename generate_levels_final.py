import random
from collections import deque

def solve(state, blocks_info):
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

    queue = deque([(state, 0)])
    visited = set([state])
    while queue:
        s, depth = queue.popleft()
        if s[0][0] == 4: return depth
        for n in get_neighbors(s):
            if n not in visited:
                visited.add(n)
                queue.append((n, depth+1))
    return -1

def generate_level(target_depth_min, target_depth_max):
    while True:
        # random number of blocks
        num_blocks = random.randint(8, 12)
        blocks_info = [(True, 2)] # target
        state = [(random.randint(0, 2), 2)]
        
        grid = [[-1]*6 for _ in range(6)]
        grid[2][state[0][0]] = 0
        grid[2][state[0][0]+1] = 0
        
        for i in range(1, num_blocks):
            isH = random.choice([True, False])
            length = random.choice([2, 3])
            
            # find all valid positions
            valid_positions = []
            for y in range(6):
                for x in range(6):
                    if isH and x + length > 6: continue
                    if not isH and y + length > 6: continue
                    
                    overlap = False
                    for j in range(length):
                        if isH and grid[y][x+j] != -1: overlap = True
                        if not isH and grid[y+j][x] != -1: overlap = True
                    if not overlap:
                        # don't block the exit completely in an unsolvable way
                        valid_positions.append((x, y))
            
            if valid_positions:
                x, y = random.choice(valid_positions)
                blocks_info.append((isH, length))
                state.append((x, y))
                for j in range(length):
                    if isH: grid[y][x+j] = i
                    else: grid[y+j][x] = i
                    
        depth = solve(tuple(state), blocks_info)
        if target_depth_min <= depth <= target_depth_max:
            return state, blocks_info, depth

print("Generating 6 perfect levels...")
levels = []
ranges = [(5, 8), (10, 14), (15, 18), (19, 23), (24, 28), (29, 40)]
for r_min, r_max in ranges:
    state, b_info, depth = generate_level(r_min, r_max)
    print(f"Generated level with depth {depth}")
    levels.append((state, b_info, depth))

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
    List<List<PuzzleBlock>> levels = [\n''')
    f.write('\n'.join(dart_code))
    f.write('''\n    ];
    return levels[index % levels.length].map((b) => b.copy()).toList();
  }
}''')
