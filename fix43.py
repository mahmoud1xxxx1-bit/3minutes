import re

file_path = r'C:\Users\loved\.gemini\antigravity\brain\14eb05f0-e654-49e3-8d08-001f2e289eae\scratch\find_differences\lib\puzzles\puzzle_43.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

replacement = '''    Difference(
      'extraNode',
      const Rect.fromLTWH(380, 400, 40, 40),
      const Offset(400, 420),
      (HtmlCanvas c) {
        c.fillStyle = '#e91e63';
        c.beginPath(); c.arc(400, 420, 8, 0, 3.14159265*2); c.fill();
      }
    ),'''

content = re.sub(r"Difference\(\s*'connectingLineMissing'.*?\}\s*\),", replacement, content, flags=re.DOTALL)

with open(file_path, 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
