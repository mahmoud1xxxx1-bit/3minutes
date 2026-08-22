import os
import re

path = "lib/features/minigames/presentation/mirror_control/mirror_control_minigame.dart"
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add import
if "import '../mini_game_copy.dart';" not in content:
    content = content.replace("import 'game_engine.dart';", "import 'game_engine.dart';\nimport '../mini_game_copy.dart';")

start_idx = content.find("  Widget build(BuildContext context) {")
end_idx = content.find("    }\n  }", start_idx)

if start_idx != -1 and end_idx != -1:
    new_build = """  Widget build(BuildContext context) {
    if (!_assetsLoaded) return const Center(child: CircularProgressIndicator());
    final copy = MiniGameCopy.fromContext(context);
    final colors = Theme.of(context).colorScheme;
    
    return Column(children: [
      Text(copy.isArabic ? 'اهرب من الشبح للوصول للباب' : 'Escape the ghost to reach the door', 
           textAlign: TextAlign.center, 
           style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
      const SizedBox(height: 6),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: colors.primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(999), border: Border.all(color: colors.primary.withValues(alpha: .25))),
          child: Text('${copy.findDifferencesMistakes}: ${engine.mistakes}', style: TextStyle(color: colors.primary, fontSize: 11, fontWeight: FontWeight.w900)),
        ),
      ]),
      const SizedBox(height: 12),
      Expanded(
        child: GestureDetector(
          onPanStart: (d) => _dragVector = Offset.zero,
          onPanUpdate: (d) {
            final scaleX = context.size!.width / GameEngine.fieldSize;
            final scaleY = context.size!.height / GameEngine.fieldSize;
            final scale = math.min(scaleX, scaleY);
            _dragVector += Offset(-d.delta.dx, -d.delta.dy) / scale;
          },
          onPanEnd: (d) => _dragVector = Offset.zero,
          child: CustomPaint(painter: getPainter(), size: Size.infinite),
        ),
      ),
    ]);"""
    
    content = content[:start_idx] + new_build + content[end_idx:]
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Fixed UI wrapper successfully.")
else:
    print("Could not find start or end indices!")
