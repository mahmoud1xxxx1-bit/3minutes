import os
import re

path = "lib/features/home/presentation/cosmic_home_screen.dart"
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add import for PracticeScreen
if "import '../../match/presentation/practice_screen.dart';" not in content:
    content = content.replace("import '../../match/presentation/matchmaking_screen.dart';", "import '../../match/presentation/matchmaking_screen.dart';\nimport '../../match/presentation/practice_screen.dart';")

# 2. Add button instance
old_buttons = """                _QuickPlayButton(
                  profile: profile,
                  matchBackend: quickMatchBackend,
                ),
                const SizedBox(height: GameSpacing.sm),"""

new_buttons = """                _QuickPlayButton(
                  profile: profile,
                  matchBackend: quickMatchBackend,
                ),
                const SizedBox(height: GameSpacing.sm),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PracticeScreen())),
                  icon: const Icon(Icons.videogame_asset_rounded),
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('تمرين فردي', style: TextStyle(fontWeight: FontWeight.w900)),
                      Text('العب منفرداً لتجربة الألعاب بدون رانك', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
                const SizedBox(height: GameSpacing.sm),"""

content = content.replace(old_buttons, new_buttons)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
