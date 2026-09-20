import re

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace(
    "child: _PigeonWidget(",
    "child: _PigeonWidget(roundIndex: _roundIndex,"
)
content = content.replace(
    "class _PigeonWidget extends StatelessWidget {",
    "class _PigeonWidget extends StatelessWidget {\n  final int roundIndex;"
)
content = content.replace(
    "const _PigeonWidget({required this.found, required this.isHinted, required this.colorIndex});",
    "const _PigeonWidget({super.key, required this.roundIndex, required this.found, required this.isHinted, required this.colorIndex});"
)
content = content.replace(
    "opacity: _roundIndex == 0 ? 0.5 : (_roundIndex == 1 ? 0.3 : 0.2),",
    "opacity: roundIndex == 0 ? 0.5 : (roundIndex == 1 ? 0.3 : 0.2),"
)

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "w", encoding="utf-8") as f:
    f.write(content)
