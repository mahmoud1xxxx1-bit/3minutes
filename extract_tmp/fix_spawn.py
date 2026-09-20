import re

file_path = r"lib/features/minigames/presentation/mirror_control/game_engine.dart"
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

old_spawn = """  void _spawnExitGate() {
    // Spawn exit far from player
    double x = playerPos.dx < fieldSize / 2 ? fieldSize - 100 : 100;
    double y = playerPos.dy < fieldSize / 2 ? fieldSize - 100 : 100;
    exitGate = Offset(x, y);
  }"""

new_spawn = """  void _spawnExitGate() {
    // Try corners
    List<Offset> corners = [
      const Offset(100, 100),
      const Offset(900, 900),
      const Offset(100, 900),
      const Offset(900, 100),
      const Offset(500, 100),
      const Offset(500, 900),
      const Offset(100, 500),
      const Offset(900, 500),
      const Offset(500, 500),
    ];
    
    // Sort by distance to player (furthest first)
    corners.sort((a, b) => (playerPos - b).distanceSquared.compareTo((playerPos - a).distanceSquared));
    
    for (var corner in corners) {
      bool valid = true;
      for (var obs in obstacles) {
        if (obs.inflate(45).contains(corner)) {
          valid = false;
          break;
        }
      }
      if (valid) {
        exitGate = corner;
        return;
      }
    }
    // Fallback if somehow all are blocked
    exitGate = corners.first;
  }"""

content = content.replace(old_spawn, new_spawn)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Fixed exitGate spawn")
