import re

file_path = r'C:\Users\loved\.gemini\antigravity\brain\14eb05f0-e654-49e3-8d08-001f2e289eae\scratch\find_differences\lib\puzzles\puzzle_33.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

replacement = '''    Difference(
      'extraVine',
      const Rect.fromLTWH(310, 190, 60, 120),
      const Offset(340, 250),
      (HtmlCanvas c) {
        c.strokeStyle = '#558b2f';
        c.lineWidth = 6;
        c.beginPath(); c.moveTo(350, 200); c.quadraticCurveTo(380, 250, 360, 300); c.stroke();
      }
    ),'''

content = re.sub(r"Difference\(\s*'flippedVine'.*?\}\s*\),", replacement, content, flags=re.DOTALL)

with open(file_path, 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
