import os
p = 'lib/features/minigames/presentation/find_differences/find_differences_policy_game.dart'
with open(p, 'r', encoding='utf-8') as f:
    c = f.read()

c = c.replace("import 'mini_game_copy.dart';", "import '../mini_game_copy.dart';")

with open(p, 'w', encoding='utf-8') as f:
    f.write(c)
