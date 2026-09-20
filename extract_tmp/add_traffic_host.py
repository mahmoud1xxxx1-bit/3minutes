import os

path = "lib/features/minigames/presentation/mini_game_host.dart"
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

import_statement = "import 'path_rush/path_rush_game.dart';\nimport 'traffic_loop/traffic_loop_game.dart';"
content = content.replace("import 'path_rush/path_rush_game.dart';", import_statement)

switch_statement = """      case 'mole_strike':
        return MoleStrikeGame(
          key: ValueKey('${game.id}-${config.seed}'),
          config: config,
          onComplete: onComplete,
        );
      case 'traffic_loop':
        return TrafficLoopGame(
          key: ValueKey('${game.id}-${config.seed}'),
          config: config,
          onComplete: onComplete,
        );"""

content = content.replace("""      case 'mole_strike':
        return MoleStrikeGame(
          key: ValueKey('${game.id}-${config.seed}'),
          config: config,
          onComplete: onComplete,
        );""", switch_statement)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
