import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import 'rank_promotion_events.dart';
import 'rank_promotion_reveal.dart';

class RankPromotionOverlayHost extends StatelessWidget {
  const RankPromotionOverlayHost({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<RankPromotionEvent?>(
      valueListenable: RankPromotionEvents.current,
      builder: (context, event, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            child,
            if (event != null)
              Positioned.fill(
                child: Material(
                  color: GameColors.backgroundDeep.withValues(alpha: .9),
                  child: SafeArea(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(GameSpacing.lg),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 430),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              RankPromotionReveal(settlement: event.settlement),
                              const SizedBox(height: GameSpacing.md),
                              FilledButton.icon(
                                onPressed: RankPromotionEvents.dismiss,
                                icon: const Icon(Icons.check_circle_rounded),
                                label: Text(
                                  Localizations.localeOf(context).languageCode == 'ar'
                                      ? 'متابعة'
                                      : 'CONTINUE',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
