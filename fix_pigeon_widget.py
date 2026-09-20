import re

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Pass roundIndex to _PigeonWidget
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
    "_roundIndex", "roundIndex"
)

# BUT wait, the main game class also uses _roundIndex!
# Let me undo the _roundIndex replacement in the whole file and ONLY do it for _PigeonWidget's opacity and size!
