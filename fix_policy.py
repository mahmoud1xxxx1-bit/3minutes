import os

p = 'lib/features/minigames/presentation/find_differences/find_differences_policy_game.dart'
with open(p, 'r', encoding='utf-8') as f:
    c = f.read()

c = c.replace("import '../domain/", "import '../../domain/")
c = c.replace("import 'find_differences_scene_painter.dart'", "import 'painters/find_differences_scene_painter.dart'")

with open(p, 'w', encoding='utf-8') as f:
    f.write(c)

p2 = 'test/find_differences_rtl_interaction_test.dart'
with open(p2, 'r', encoding='utf-8') as f:
    c = f.read()

c = c.replace("import 'package:game/features/minigames/presentation/find_differences/find_differences_game.dart';", "import 'package:game/features/minigames/presentation/find_differences/find_differences_game.dart';\nimport 'package:game/features/minigames/presentation/find_differences/find_differences_logical_point.dart';")

with open(p2, 'w', encoding='utf-8') as f:
    f.write(c)

