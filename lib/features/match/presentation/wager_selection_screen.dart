import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../domain/competitive_match_rules.dart';

class WagerSelectionScreen extends StatefulWidget {
  const WagerSelectionScreen({
    super.key,
    required this.goldBalance,
    required this.onFindOpponent,
  });

  final int goldBalance;
  final Future<void> Function(int wager) onFindOpponent;

  @override
  State<WagerSelectionScreen> createState() => _WagerSelectionScreenState();
}

class _WagerSelectionScreenState extends State<WagerSelectionScreen> {
  int? _selected;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.backgroundDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('CHOOSE YOUR WAGER'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: GameColors.arenaGradient),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(GameSpacing.md),
            child: Column(
              children: [
                const SizedBox(height: GameSpacing.md),
                Text(
                  'Your GOLD  ${widget.goldBalance}',
                  style: const TextStyle(
                    color: GameColors.rewardGoldBright,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: GameSpacing.lg),
                for (final wager in CompetitiveMatchRules.wagerTiers)
                  Padding(
                    padding: const EdgeInsets.only(bottom: GameSpacing.md),
                    child: _WagerCard(
                      wager: wager,
                      selected: _selected == wager,
                      enabled: widget.goldBalance >= wager,
                      onTap: () => setState(() => _selected = wager),
                    ),
                  ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: FilledButton(
                    onPressed: _selected == null || _busy
                        ? null
                        : () async {
                            setState(() => _busy = true);
                            try {
                              await widget.onFindOpponent(_selected!);
                            } finally {
                              if (mounted) setState(() => _busy = false);
                            }
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: GameColors.wagerGold,
                      foregroundColor: GameColors.backgroundDeep,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(GameRadii.button),
                      ),
                    ),
                    child: Text(
                      _busy ? 'SEARCHING…' : 'FIND OPPONENT',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WagerCard extends StatelessWidget {
  const _WagerCard({
    required this.wager,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final int wager;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  String get subtitle => switch (wager) {
        180 => 'QUICK MATCH',
        500 => 'COMPETITIVE',
        _ => 'HIGH STAKES',
      };

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : .42,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(GameRadii.panel),
        child: AnimatedContainer(
          duration: GameDurations.normal,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          decoration: BoxDecoration(
            gradient: selected ? GameColors.goldGradient : null,
            color: selected ? null : GameColors.surfaceGlass,
            borderRadius: BorderRadius.circular(GameRadii.panel),
            border: Border.all(
              color: selected ? GameColors.rewardGoldBright : GameColors.surfaceStrong,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected ? GameShadows.goldGlow : GameShadows.card,
          ),
          child: Row(
            children: [
              const Icon(Icons.workspace_premium_rounded, size: 34),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$wager GOLD', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                    Text(subtitle, style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              if (selected) const Icon(Icons.check_circle_rounded, size: 30),
            ],
          ),
        ),
      ),
    );
  }
}
