import re
with open('lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart', 'r', encoding='utf-8') as f:
    c = f.read()
c = c.replace('minigames_VBN', 'minigames')
with open('lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart', 'w', encoding='utf-8') as f:
    f.write(c)
