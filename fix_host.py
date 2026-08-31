import re
with open('lib/features/minigames/presentation/mini_game_host.dart', 'r', encoding='utf-8') as f:
    c = f.read()

c = c.replace('LevelDevilGame(\n          config: config,\n        )', 'LevelDevilGame(\n          levelId: config.seed % 100,\n        )')
c = c.replace('import \'mirror_control/mirror_control_game.dart\';', 'import \'mirror_control/mirror_control_game.dart\';\nimport \'mirror_control/mirror_control_minigame.dart\';')

with open('lib/features/minigames/presentation/mini_game_host.dart', 'w', encoding='utf-8') as f:
    f.write(c)
