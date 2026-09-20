import re

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Fix pigeon size to 45 (it was 40 or scaled)
# Let's check where the size is defined.
# It is hardcoded in _PigeonWidget currently as const Size(40, 40)
content = content.replace("width: 40, height: 40,", "width: 45, height: 45,")
content = content.replace("size: const Size(40, 40),", "size: const Size(45, 45),")
content = content.replace("width: 40, height: 40", "width: 45, height: 45")

# And in the Positioned widget inside the Stack:
# left: round.pigeons[i].x * constraints.maxWidth - 20,
# top: round.pigeons[i].y * constraints.maxHeight - 20,
content = content.replace("- 20,", "- 22.5,")

# Fix opacity to 0.8 for all rounds
content = content.replace(
    "opacity: roundIndex == 0 ? 0.8 : (roundIndex == 1 ? 0.7 : 0.6),",
    "opacity: 0.8,"
)

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "w", encoding="utf-8") as f:
    f.write(content)
