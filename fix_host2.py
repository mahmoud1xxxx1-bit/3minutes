import re
with open('lib/features/minigames/presentation/mini_game_host.dart', 'r', encoding='utf-8') as f:
    c = f.read()

c = c.replace('MirrorControlMinigame(', 'MirrorControlMiniGame(')

with open('lib/features/minigames/presentation/mini_game_host.dart', 'w', encoding='utf-8') as f:
    f.write(c)
