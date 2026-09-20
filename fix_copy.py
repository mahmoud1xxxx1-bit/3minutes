import re

with open("lib/features/minigames_VBN/presentation/mini_game_copy.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Add hidden_pigeon title
if "'hidden_pigeon'" not in content:
    content = content.replace(
        "'traffic_loop' => isArabic ? 'المرور الدائري' : 'Traffic Loop',",
        "'traffic_loop' => isArabic ? 'المرور الدائري' : 'Traffic Loop',\n        'hidden_pigeon' => isArabic ? 'الطائر المخفي' : 'Hidden Pigeon',"
    )
    # also handle the corrupted ansi case just in case
    content = content.replace(
        "'traffic_loop' => isArabic ? 'Ø§Ù„Ù…Ø±ÙˆØ± Ø§Ù„Ø¯Ø§Ø¦Ø±ÙŠ' : 'Traffic Loop',",
        "'traffic_loop' => isArabic ? 'Ø§Ù„Ù…Ø±ÙˆØ± Ø§Ù„Ø¯Ø§Ø¦Ø±ÙŠ' : 'Traffic Loop',\n        'hidden_pigeon' => isArabic ? 'الطائر المخفي' : 'Hidden Pigeon',"
    )

# Add hiddenPigeonInstruction
if "hiddenPigeonInstruction" not in content:
    content = content.replace(
        "String get pathRushRound",
        "String get hiddenPigeonInstruction => isArabic ? 'ابحث عن الطائر !!' : 'Find the pigeon!!';\n  String get pathRushRound"
    )

with open("lib/features/minigames_VBN/presentation/mini_game_copy.dart", "w", encoding="utf-8") as f:
    f.write(content)
