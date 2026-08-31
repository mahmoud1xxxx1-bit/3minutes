import os

files = [
    r"test\find_differences_policy_test.dart",
    r"test\find_differences_rtl_interaction_test.dart",
    r"test\path_rush_rtl_interaction_test.dart"
]

for file in files:
    if os.path.exists(file):
        with open(file, "r", encoding="utf-8") as f:
            content = f.read()
        
        content = content.replace("package:game/features/minigames/presentation/find_differences_policy_game.dart", "package:game/features/minigames/presentation/find_differences/find_differences_game.dart")
        content = content.replace("FindDifferencesPolicyGame", "FindDifferencesGame")
        content = content.replace("package:game/features/minigames/presentation/find_differences_game.dart", "package:game/features/minigames/presentation/find_differences/find_differences_game.dart")
        content = content.replace("package:game/features/minigames/presentation/path_rush_game.dart", "package:game/features/minigames/presentation/path_rush/path_rush_game.dart")

        with open(file, "w", encoding="utf-8") as f:
            f.write(content)

print("Tests fixed")
