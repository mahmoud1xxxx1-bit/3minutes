import os

path = "lib/features/match/presentation/practice_screen.dart"
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace("import '../../../core/ui/theme.dart';\n", "")
content = content.replace("backgroundColor: GameTheme.background,", "backgroundColor: Theme.of(context).scaffoldBackgroundColor,")

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
