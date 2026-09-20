import re

with open("lib/features/minigames/domain/hidden_pigeon_plan.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("rng.nextDouble()", "(rng.nextInt(1000000) / 1000000.0)")

with open("lib/features/minigames/domain/hidden_pigeon_plan.dart", "w", encoding="utf-8") as f:
    f.write(content)
