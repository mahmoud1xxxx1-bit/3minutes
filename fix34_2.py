import re

file_path = r'C:\Users\loved\.gemini\antigravity\brain\14eb05f0-e654-49e3-8d08-001f2e289eae\scratch\find_differences\lib\puzzles\puzzle_34.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

replacement = '''    Difference(
      'missingLitWindow',
      const Rect.fromLTWH(90, 100, 50, 50),
      const Offset(115, 125),
      (HtmlCanvas c) {
        c.fillStyle = '#222233'; // Unlit window color
        c.fillRect(100, 110, 30, 30);
      }
    ),'''

content = re.sub(r"Difference\(\s*'missingWallCable'.*?\}\s*\),", replacement, content, flags=re.DOTALL)

with open(file_path, 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
