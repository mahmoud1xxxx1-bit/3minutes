import re

with open("lib/features/minigames/presentation/path_rush/path_rush_game.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = re.sub(
    r'_StartButton\(number: 4, selected: _selectedLane == 0, enabled: !_locked, onTap: \(\) => _choose\(4\)\),\s*',
    '',
    content
)

content = re.sub(
    r'_StartButton\(number: 3, selected: _selectedLane == 1',
    '_StartButton(number: 3, selected: _selectedLane == 0',
    content
)
content = re.sub(
    r'_StartButton\(number: 2, selected: _selectedLane == 2',
    '_StartButton(number: 2, selected: _selectedLane == 1',
    content
)
content = re.sub(
    r'_StartButton\(number: 1, selected: _selectedLane == 3',
    '_StartButton(number: 1, selected: _selectedLane == 2',
    content
)

content = re.sub(
    r'for \(var i = 0; i < 4; i\+\+\)',
    'for (var i = 0; i < 3; i++)',
    content
)

with open("lib/features/minigames/presentation/path_rush/path_rush_game.dart", "w", encoding="utf-8") as f:
    f.write(content)
