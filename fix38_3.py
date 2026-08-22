import re

file_path = r'C:\Users\loved\.gemini\antigravity\brain\14eb05f0-e654-49e3-8d08-001f2e289eae\scratch\find_differences\lib\puzzles\puzzle_38.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

new_diffs = '''  @override
  List<Difference> get differences => [
    Difference(
      'starColor',
      const Rect.fromLTWH(80.0, 180.0, 40.0, 40.0),
      const Offset(100, 200),
      (HtmlCanvas c) {
        c.save(); c.translate(100, 200);
        c.fillStyle = '#c0c0c0'; // Silver
        c.beginPath();
        c.moveTo(math.cos(18 * math.pi / 180) * 20, -math.sin(18 * math.pi / 180) * 20);
        for (double i = 0; i < 5; i++) {
          c.lineTo(math.cos((18 + i * 72) * math.pi / 180) * 20, -math.sin((18 + i * 72) * math.pi / 180) * 20);
          c.lineTo(math.cos((54 + i * 72) * math.pi / 180) * 10, -math.sin((54 + i * 72) * math.pi / 180) * 10);
        }
        c.fill(); c.restore();
      }
    ),
    Difference(
      'podiumStripe',
      const Rect.fromLTWH(385.0, 420.0, 20.0, 80.0),
      const Offset(395, 460),
      (HtmlCanvas c) {
        c.fillStyle = '#00008b'; c.fillRect(390, 420, 10, 80);
      }
    ),
    Difference(
      'extraStar',
      const Rect.fromLTWH(380.0, 80.0, 40.0, 40.0),
      const Offset(400, 100),
      (HtmlCanvas c) {
        c.save(); c.translate(400, 100);
        c.fillStyle = '#ffd700';
        c.beginPath();
        c.moveTo(math.cos(18 * math.pi / 180) * 20, -math.sin(18 * math.pi / 180) * 20);
        for (double i = 0; i < 5; i++) {
          c.lineTo(math.cos((18 + i * 72) * math.pi / 180) * 20, -math.sin((18 + i * 72) * math.pi / 180) * 20);
          c.lineTo(math.cos((54 + i * 72) * math.pi / 180) * 10, -math.sin((54 + i * 72) * math.pi / 180) * 10);
        }
        c.fill(); c.restore();
      }
    ),
    Difference(
      'trapezeRing',
      const Rect.fromLTWH(380.0, 140.0, 40.0, 50.0),
      const Offset(400, 165),
      (HtmlCanvas c) {
        c.strokeStyle = '#ff0000'; c.lineWidth = 4;
        c.beginPath(); c.arc(400, 165, 15, 0, math.pi*2); c.stroke();
      }
    ),
    Difference(
      'extraBall',
      const Rect.fromLTWH(200.0, 480.0, 40.0, 40.0),
      const Offset(220, 500),
      (HtmlCanvas c) {
        c.fillStyle = '#ff0000';
        c.beginPath(); c.arc(220, 500, 15, 0, math.pi*2); c.fill();
        c.fillStyle = '#ffffff';
        c.beginPath(); c.arc(215, 495, 5, 0, math.pi*2); c.fill();
      }
    )
  ];
}'''

content = re.sub(r'  @override\n  List<Difference> get differences => \[.*$', new_diffs, content, flags=re.DOTALL)

with open(file_path, 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
