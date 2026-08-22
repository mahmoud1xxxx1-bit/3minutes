import re

file_path = r'C:\Users\loved\.gemini\antigravity\brain\14eb05f0-e654-49e3-8d08-001f2e289eae\scratch\find_differences\lib\puzzles\puzzle_35.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

replacement = '''    Difference(
      'extraStarfish',
      const Rect.fromLTWH(500, 500, 60, 60),
      const Offset(530, 530),
      (HtmlCanvas c) {
        c.save();
        c.translate(530, 530);
        c.fillStyle = '#ff5252';
        c.beginPath();
        double a0 = -math.pi / 2;
        c.moveTo(math.cos(a0)*20, math.sin(a0)*20);
        for(int i=0; i<5; i++) {
          double a = i * math.pi * 2 / 5 - math.pi / 2;
          c.lineTo(math.cos(a)*20, math.sin(a)*20);
          a += math.pi / 5;
          c.lineTo(math.cos(a)*8, math.sin(a)*8);
        }
        c.fill();
        c.restore();
      }
    )'''

content = re.sub(r"Difference\(\s*'extraStarfish'.*?\}\s*\)", replacement, content, flags=re.DOTALL)

with open(file_path, 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
