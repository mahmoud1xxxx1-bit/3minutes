import re

with open('lib/features/minigames/presentation/mini_game_host.dart', 'r', encoding='utf-8') as f:
    code = f.read()

code = re.sub(r"import 'find_differences/find_differences_game.dart';\n", "", code)
code = re.sub(r"import 'follow_the_cup/follow_the_cup_game.dart';\n", "", code)
code = re.sub(r"import 'key_escape/key_escape_game.dart';\n", "", code)
code = re.sub(r"import 'level_devil/level_devil_host.dart';\n", "", code)

code = re.sub(r"case 'level_devil':\s+gameWidget = LevelDevilHost\(.*?\);\s+break;", "", code, flags=re.DOTALL)
code = re.sub(r"case 'follow_the_cup':\s+gameWidget = FollowTheCupGame\(.*?\);\s+break;", "", code, flags=re.DOTALL)
code = re.sub(r"case 'find_differences':\s+gameWidget = FindDifferencesGame\(.*?\);\s+break;", "", code, flags=re.DOTALL)
code = re.sub(r"case 'key_escape':\s+gameWidget = KeyEscapeGame\(.*?\);\s+break;", "", code, flags=re.DOTALL)


with open('lib/features/minigames/presentation/mini_game_host.dart', 'w', encoding='utf-8') as f:
    f.write(code)

