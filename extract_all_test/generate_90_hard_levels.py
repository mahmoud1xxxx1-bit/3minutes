import random
from collections import deque
import multiprocessing

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

def worker(seed):
    random.seed(seed + 4000) # Ensure new unique boards
    while True:
        num_blocks = random.randint(11, 14)
        blocks_info = [(True, 2)]
        state = [(random.randint(0, 1), 2)]
        grid = [[-1]*6 for _ in range(6)]
        grid[2][state[0][0]] = 0
        grid[2][state[0][0]+1] = 0
        
        for i in range(1, num_blocks):
            isH = random.choice([True, False])
            length = random.choice([2, 3])
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
                        valid_positions.append((x, y))
            if valid_positions:
                x, y = random.choice(valid_positions)
                blocks_info.append((isH, length))
                state.append((x, y))
                for j in range(length):
                    if isH: grid[y][x+j] = i
                    else: grid[y+j][x] = i
                    
        depth = solve(tuple(state), blocks_info)
        # Ensure ultra-high difficulty
        if 25 <= depth <= 45:
            return state, blocks_info, depth

if __name__ == '__main__':
    # 90 levels for N1 to N30!
    with multiprocessing.Pool(10) as pool:
        results = pool.map(worker, range(90))
        
    dart_code = []
    targets = []
    for i, (state, blocks_info, depth) in enumerate(results):
        targets.append(str(depth))
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
        f.write('''\n        ];
        return levels[index % levels.length].map((b) => b.copy()).toList();
      }
    }''')
    print("Done generating 90 levels.")
