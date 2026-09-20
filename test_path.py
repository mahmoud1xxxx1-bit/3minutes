class Point:
    def __init__(self, r, c):
        self.r = r
        self.c = c
    def __eq__(self, other):
        return self.r == other.r and self.c == other.c
    def __repr__(self):
        return f"({self.r},{self.c})"

rows = 3
cols = 3
grid = [
    [0, 0, 0, 0, 0],
    [0, 1, 0, 1, 0],
    [0, 2, 2, 0, 0],
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0],
]

def is_clear(p1, p2):
    if p1.r != p2.r and p1.c != p2.c: return False
    if p1.r == p2.r:
        mn = min(p1.c, p2.c)
        mx = max(p1.c, p2.c)
        for c in range(mn + 1, mx):
            if grid[p1.r][c] != 0: return False
    else:
        mn = min(p1.r, p2.r)
        mx = max(p1.r, p2.r)
        for r in range(mn + 1, mx):
            if grid[r][p1.c] != 0: return False
    return True

def find_path(p1, p2):
    if is_clear(p1, p2): return [p1, p2]
    
    corner1 = Point(p1.r, p2.c)
    if grid[corner1.r][corner1.c] == 0 and is_clear(p1, corner1) and is_clear(corner1, p2):
        return [p1, corner1, p2]
        
    corner2 = Point(p2.r, p1.c)
    if grid[corner2.r][corner2.c] == 0 and is_clear(p1, corner2) and is_clear(corner2, p2):
        return [p1, corner2, p2]
        
    for r in range(0, rows + 2):
        p3 = Point(r, p1.c)
        p4 = Point(r, p2.c)
        if grid[p3.r][p3.c] == 0 and grid[p4.r][p4.c] == 0 and is_clear(p1, p3) and is_clear(p3, p4) and is_clear(p4, p2):
            return [p1, p3, p4, p2]
            
    for c in range(0, cols + 2):
        p3 = Point(p1.r, c)
        p4 = Point(p2.r, c)
        if grid[p3.r][p3.c] == 0 and grid[p4.r][p4.c] == 0 and is_clear(p1, p3) and is_clear(p3, p4) and is_clear(p4, p2):
            return [p1, p3, p4, p2]
            
    return None

print("1-turn (1,1) to (1,3):", find_path(Point(1,1), Point(1,3)))
print("1-turn (2,1) to (2,2):", find_path(Point(2,1), Point(2,2)))
print("2-turn (1,1) to (2,2):", find_path(Point(1,1), Point(2,2)))
