import os

path = "lib/features/minigames/presentation/mirror_control/mirror_control_minigame.dart"
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

old_row = """      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: colors.primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(999), border: Border.all(color: colors.primary.withValues(alpha: .25))),
          child: Text('${copy.findDifferencesMistakes}: ${engine.mistakes}', style: TextStyle(color: colors.primary, fontSize: 11, fontWeight: FontWeight.w900)),
        ),
      ]),"""

new_row = """      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: colors.primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(999), border: Border.all(color: colors.primary.withValues(alpha: .25))),
          child: Text('${copy.followCupCorrect}: ${engine.currentTargetIndex}/${engine.targets.length}', style: TextStyle(color: colors.primary, fontSize: 11, fontWeight: FontWeight.w900)),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: colors.primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(999), border: Border.all(color: colors.primary.withValues(alpha: .25))),
          child: Text('${copy.findDifferencesMistakes}: ${engine.mistakes}', style: TextStyle(color: colors.primary, fontSize: 11, fontWeight: FontWeight.w900)),
        ),
      ]),"""

content = content.replace(old_row, new_row)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
