from collections import deque

def parse_board(board_str):
    board_str = board_str.replace('\n', '').replace(' ', '')
    grid = [list(board_str[i*6:(i+1)*6]) for i in range(6)]
    blocks = {}
    for y in range(6):
        for x in range(6):
            c = grid[y][x]
            if c != '.':
                if c not in blocks: blocks[c] = []
                blocks[c].append((x, y))
    
    blocks_info = []
    state = []
    
    target = blocks.pop('X')
    state.append((target[0][0], target[0][1]))
    blocks_info.append((True, len(target)))
    
    for c, coords in blocks.items():
        x, y = coords[0]
        length = len(coords)
        is_horizontal = True
        if length > 1:
            is_horizontal = (coords[0][1] == coords[1][1])
        state.append((x, y))
        blocks_info.append((is_horizontal, length))
        
    return tuple(state), blocks_info

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

boards_strs = [
    # Level 1 (Beginner)
    '''
    AA.O..
    ...O..
    XX.O..
    .PQQ..
    .P..B.
    ....B.
    ''',
    # Level 2 
    '''
    ...AA.
    ..B...
    XXB...
    .CC...
    ......
    ......
    ''',
    # Level 3 
    '''
    O.AA..
    O.B...
    XXB...
    PPC...
    ..C...
    ......
    ''',
    # Level 4 
    '''
    .AAB..
    .C.B..
    .CXX..
    .CDD..
    .E....
    .E....
    ''',
    # Level 5
    '''
    .AABBC
    .D.E.C
    .D.E.C
    .XXE..
    ..F...
    ..F...
    ''',
    # Level 6
    '''
    A.BBC.
    A...C.
    XX..C.
    .DDE..
    .F.E..
    .F....
    '''
]

dart_code = []
for i, b_str in enumerate(boards_strs):
    state, blocks_info = parse_board(b_str)
    depth = solve(state, blocks_info)
    print(f'Level {i+1} requires {depth} moves.')
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
