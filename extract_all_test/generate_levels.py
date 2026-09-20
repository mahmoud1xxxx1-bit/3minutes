import random
from collections import deque

def is_solved(state):
    # Target is block 0, horizontal, length 2, y=2. Exit is x=4 (so it occupies 4,5).
    # state is a tuple of ((x, y), ...) for each block.
    return state[0][0] == 4

def get_grid(state, blocks_info):
    grid = [[-1]*6 for _ in range(6)]
    for i, (x, y) in enumerate(state):
        isHorizontal, length = blocks_info[i]
        for j in range(length):
            if isHorizontal:
                grid[y][x+j] = i
            else:
                grid[y+j][x] = i
    return grid

def get_neighbors(state, blocks_info):
    grid = get_grid(state, blocks_info)
    neighbors = []
    for i, (x, y) in enumerate(state):
        isHorizontal, length = blocks_info[i]
        if isHorizontal:
            # move left
            if x > 0 and grid[y][x-1] == -1:
                n_state = list(state)
                n_state[i] = (x-1, y)
                neighbors.append(tuple(n_state))
            # move right
            if x + length < 6 and grid[y][x+length] == -1:
                n_state = list(state)
                n_state[i] = (x+1, y)
                neighbors.append(tuple(n_state))
        else:
            # move up
            if y > 0 and grid[y-1][x] == -1:
                n_state = list(state)
                n_state[i] = (x, y-1)
                neighbors.append(tuple(n_state))
            # move down
            if y + length < 6 and grid[y+length][x] == -1:
                n_state = list(state)
                n_state[i] = (x, y+1)
                neighbors.append(tuple(n_state))
    return neighbors

def solve(start_state, blocks_info):
    queue = deque([(start_state, 0)])
    visited = set([start_state])
    while queue:
        state, depth = queue.popleft()
        if is_solved(state):
            return depth
        for n in get_neighbors(state, blocks_info):
            if n not in visited:
                visited.add(n)
                queue.append((n, depth+1))
    return -1

# Let's define 6 known solvable boards manually to be safe and fast.
# Typical Rush Hour board notation:
# 0: Target (H2), 1-N: other blocks.
boards = [
    # Level 1 (Difficulty: 5-8 moves)
    { 'blocks_info': [(True, 2), (False, 3), (True, 2), (False, 2), (False, 2), (True, 2)],
      'state': ((0,2), (2,1), (2,5), (4,4), (0,4), (3,0)) },
    
    # Level 2 (Difficulty: ~15 moves)
    { 'blocks_info': [(True, 2), (False, 3), (False, 2), (True, 2), (True, 2), (False, 2), (True, 2), (True, 2), (True, 2)],
      'state': ((0,2), (3,1), (4,1), (1,3), (1,4), (0,3), (2,5), (4,4), (3,0)) },
    
    # Level 3 (Difficulty: ~20 moves)
    { 'blocks_info': [(True, 2), (False, 3), (True, 2), (True, 2), (True, 2), (False, 2), (True, 2)],
      'state': ((0,2), (4,0), (4,3), (3,4), (4,5), (2,2), (1,0)) },
      
    # Level 4 (Difficulty: ~35 moves) - Classic Expert Level
    { 'blocks_info': [(True, 2), (False, 3), (False, 3), (True, 2), (False, 2), (False, 2), (True, 2), (False, 2), (False, 2), (True, 2), (True, 2)],
      'state': ((1,2), (0,0), (3,1), (1,4), (1,5), (2,0), (4,4), (4,0), (5,1), (4,5), (0,5)) },
      
    # Level 5 (Difficulty: ~40 moves)
    { 'blocks_info': [(True,2), (False,3), (False,2), (False,2), (True,2), (True,2), (False,2), (False,2), (True,2), (False,2), (True,2)],
      'state': ((0,2), (5,0), (0,0), (0,3), (1,3), (1,4), (3,1), (3,3), (4,3), (4,4), (2,5)) },

    # Level 6 (Difficulty: ~50 moves) - The hardest Rush Hour
    { 'blocks_info': [(True,2), (False,2), (False,2), (True,2), (False,2), (False,3), (True,2), (False,3), (True,2), (True,2), (False,2), (True,2), (True,2)],
      'state': ((1,2), (0,0), (0,3), (1,0), (1,4), (2,1), (3,0), (3,1), (4,4), (4,5), (5,0), (1,3), (1,5)) }
]

dart_code = []
for i, board in enumerate(boards):
    # Verify solvability
    depth = solve(board['state'], board['blocks_info'])
    print(f'Level {i+1} requires {depth} moves.')
    
    dart_code.append(f"      // Level {i+1} (Min Moves: {depth})")
    dart_code.append("      [")
    for j, ((x, y), (isH, length)) in enumerate(zip(board['state'], board['blocks_info'])):
        isTarget = 'true' if j == 0 else 'false'
        dart_code.append(f"        PuzzleBlock(id: {j}, x: {x}, y: {y}, length: {length}, isHorizontal: {'true' if isH else 'false'}, isTarget: {isTarget}),")
    dart_code.append("      ],")

print('\n'.join(dart_code))
