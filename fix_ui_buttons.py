import re

with open("lib/features/minigames/presentation/path_rush/path_rush_game.dart", "r", encoding="utf-8") as f:
    content = f.read()

buttons_str = """
              children: [
                _StartButton(number: 3, selected: _selectedLane == 0, enabled: !_locked, onTap: () => _choose(3)),
                _StartButton(number: 2, selected: _selectedLane == 1, enabled: !_locked, onTap: () => _choose(2)),
                _StartButton(number: 1, selected: _selectedLane == 2, enabled: !_locked, onTap: () => _choose(1)),
              ],
"""

content = re.sub(r'children: \[\s*_StartButton\(number: 3.*?_StartButton\(number: 1.*?\],\s*', buttons_str.strip() + '\n            ),\n', content, flags=re.DOTALL)

with open("lib/features/minigames/presentation/path_rush/path_rush_game.dart", "w", encoding="utf-8") as f:
    f.write(content)
