import 'package:flutter/material.dart';

import 'arena_ui.dart';
import 'design_tokens.dart';
import 'game_glyphs.dart';

class ArenaStatePanel extends StatelessWidget {
  const ArenaStatePanel({
    super.key,
    required this.glyph,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.color = GameColors.accentBright,
    this.loading = false,
  });

  final GameGlyphType glyph;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color color;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return ArenaCard(
      accent: color,
      padding: const EdgeInsets.all(GameSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: .08),
              border: Border.all(color: color.withValues(alpha: .24)),
              boxShadow: [BoxShadow(color: color.withValues(alpha: .12), blurRadius: 26)],
            ),
            child: loading
                ? SizedBox.square(
                    dimension: 26,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: color),
                  )
                : GameGlyph(type: glyph, size: 34, color: color, active: true),
          ),
          const SizedBox(height: GameSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          if (message != null) ...[
            const SizedBox(height: 5),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: GameColors.muted, fontSize: 11, height: 1.45),
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: GameSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ),
          ],
        ],
      ),
    );
  }
}

class ArenaGlyphAction extends StatelessWidget {
  const ArenaGlyphAction({
    super.key,
    required this.glyph,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.color = GameColors.accentBright,
    this.badge,
  });

  final GameGlyphType glyph;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color color;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return ArenaCard(
      onTap: onTap,
      accent: color,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .09),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: .2)),
            ),
            child: GameGlyph(type: glyph, size: 28, color: color, active: true),
          ),
          const SizedBox(width: GameSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: GameColors.muted, fontSize: 10, height: 1.35),
                  ),
                ],
              ],
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 7),
            ArenaPill(label: badge!, color: color),
          ],
          const SizedBox(width: 6),
          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: onTap == null ? GameColors.muted : color),
        ],
      ),
    );
  }
}
