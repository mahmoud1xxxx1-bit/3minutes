import 'package:flutter/material.dart';

import 'design_tokens.dart';
import 'game_glyphs.dart';

class GameNavItemData {
  const GameNavItemData({
    required this.label,
    required this.glyph,
  });

  final String label;
  final GameGlyphType glyph;
}

class GameNavDock extends StatelessWidget {
  const GameNavDock({
    super.key,
    required this.index,
    required this.items,
    required this.onChanged,
  });

  final int index;
  final List<GameNavItemData> items;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(10, 0, 10, 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(7, 8, 7, 7),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xF20B1730), Color(0xFA061023)],
          ),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0xFF1B355C), width: .8),
          boxShadow: const [
            BoxShadow(color: Color(0x66000000), blurRadius: 30, offset: Offset(0, 12)),
            BoxShadow(color: Color(0x1819DCE8), blurRadius: 28),
          ],
        ),
        child: Row(
          children: List.generate(items.length, (i) {
            final selected = i == index;
            final item = items[i];
            return Expanded(
              child: _DockItem(
                data: item,
                selected: selected,
                onTap: () => onChanged(i),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final GameNavItemData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? GameColors.accentBright : const Color(0xFF6D83A7);
    return Semantics(
      selected: selected,
      button: true,
      label: data.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          constraints: const BoxConstraints(minHeight: 64),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            gradient: selected
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0x3319DCE8), Color(0x227957F5)],
                  )
                : null,
            border: selected
                ? Border.all(color: GameColors.accentBright.withValues(alpha: .24))
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                scale: selected ? 1.12 : .92,
                child: Container(
                  width: 36,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: selected
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: [
                            BoxShadow(
                              color: GameColors.accentBright.withValues(alpha: .18),
                              blurRadius: 16,
                            ),
                          ],
                        )
                      : null,
                  child: GameGlyph(
                    type: data.glyph,
                    size: 24,
                    color: color,
                    active: selected,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: TextStyle(
                  color: color,
                  fontSize: selected ? 10.5 : 9.5,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                  letterSpacing: selected ? .15 : 0,
                ),
                child: Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: selected ? 17 : 0,
                height: 2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(99),
                  gradient: selected ? GameColors.cosmicGradient : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
