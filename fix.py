import re

with open('lib/features/minigames/presentation/level_devil/troll_engine.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Remove any existing local declarations of lastTrap inside the if blocks
content = re.sub(r'String\?\s+lastTrap\s*=\s*null;', 'lastTrap = null;', content)

# Inject String? lastTrap = null; at the top of _generateLevel
content = content.replace('void _generateLevel(int mechanicOffset, Map<String, dynamic> config) {', 'void _generateLevel(int mechanicOffset, Map<String, dynamic> config) {\n    String? lastTrap = null;')

with open('lib/features/minigames/presentation/level_devil/troll_engine.dart', 'w', encoding='utf-8') as f:
    f.write(content)
