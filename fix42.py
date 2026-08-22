import re

file_path = r'C:\Users\loved\.gemini\antigravity\brain\14eb05f0-e654-49e3-8d08-001f2e289eae\scratch\find_differences\lib\puzzles\puzzle_42.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

new_diffs = '''  @override
  List<Difference> get differences => [
    Difference(
      'extraFootprint',
      const Rect.fromLTWH(290, 540, 40, 40),
      const Offset(310, 560),
      (HtmlCanvas c) {
        c.fillStyle = '#cfd8dc';
        c.beginPath(); c.ellipse(310, 560, 8, 4, 0.5, 0, math.pi*2); c.fill();
      }
    ),
    Difference(
      'windowLightOff',
      const Rect.fromLTWH(310, 450, 60, 60),
      const Offset(330, 470),
      (HtmlCanvas c) {
        c.save(); c.translate(400, 520); c.scale(2.0, 2.0);
        c.fillStyle = '#212121'; // Dark window instead of lit
        c.fillRect(-35, -25, 15, 15);
        c.restore();
      }
    ),
    Difference(
      'missingFootprint',
      const Rect.fromLTWH(430, 500, 40, 40),
      const Offset(450, 520),
      (HtmlCanvas c) {
        c.fillStyle = '#ffffff'; // Snow color
        c.beginPath(); c.ellipse(450, 520, 10, 6, 0.5, 0, math.pi*2); c.fill();
      }
    ),
    Difference(
      'extraStar',
      const Rect.fromLTWH(480, 180, 40, 40),
      const Offset(500, 200),
      (HtmlCanvas c) {
        c.fillStyle = '#ffffff';
        c.beginPath();
        c.moveTo(500, 190);
        c.lineTo(505, 205);
        c.lineTo(520, 205);
        c.lineTo(508, 215);
        c.lineTo(512, 230);
        c.lineTo(500, 220);
        c.lineTo(488, 230);
        c.lineTo(492, 215);
        c.lineTo(480, 205);
        c.lineTo(495, 205);
        c.fill();
      }
    ),
    Difference(
      'moonCrater',
      const Rect.fromLTWH(670, 70, 40, 40),
      const Offset(690, 90),
      (HtmlCanvas c) {
        c.fillStyle = '#dcb873'; // Darker moon color
        c.beginPath(); c.arc(690, 90, 12, 0, math.pi*2); c.fill();
        c.beginPath(); c.arc(710, 110, 8, 0, math.pi*2); c.fill();
      }
    )
  ];
}'''

content = re.sub(r'  @override\n  List<Difference> get differences => \[.*$', new_diffs, content, flags=re.DOTALL)

with open(file_path, 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
