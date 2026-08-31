import os

test_dir = 'test'
for root, _, files in os.walk(test_dir):
    for f in files:
        if not f.endswith('.dart'): continue
        p = os.path.join(root, f)
        with open(p, 'r', encoding='utf-8') as file:
            c = file.read()
        
        c = c.replace('package:game/features/minigames/presentation/find_differences_game.dart', 'package:game/features/minigames/presentation/find_differences/find_differences_game.dart')
        c = c.replace('package:game/features/minigames/presentation/find_differences_policy_game.dart', 'package:game/features/minigames/presentation/find_differences/find_differences_policy_game.dart')
        c = c.replace('package:game/features/minigames/presentation/path_rush_game.dart', 'package:game/features/minigames/presentation/path_rush/path_rush_game.dart')
        
        with open(p, 'w', encoding='utf-8') as file:
            file.write(c)
print('Fixed imports')
