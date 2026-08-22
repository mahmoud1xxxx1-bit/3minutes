import re

file_path = r'C:\Users\loved\.gemini\antigravity\brain\14eb05f0-e654-49e3-8d08-001f2e289eae\scratch\find_differences\lib\puzzles\puzzle_34.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

replacement = '''    Difference(
      'vendingMachineScreen',
      const Rect.fromLTWH(100, 350, 100, 70),
      const Offset(150, 390),
      (HtmlCanvas c) {
        c.fillStyle = '#ffb74d'; // Orange screen
        c.fillRect(110, 360, 80, 60);
        c.fillStyle = '#ff5252'; c.fillRect(115, 365, 10, 20);
        c.fillStyle = '#448aff'; c.fillRect(135, 365, 10, 20);
        c.fillStyle = '#69f0ae'; c.fillRect(155, 365, 10, 20);
      }
    ),'''

content = re.sub(r"Difference\(\s*'lampGlowRadius'.*?\}\s*\),", replacement, content, flags=re.DOTALL)

with open(file_path, 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
