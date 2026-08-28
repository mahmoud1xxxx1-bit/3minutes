import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';

enum CompetitiveResultOutcome { victory, defeat, draw }

class GameResultLine {
  const GameResultLine({
    required this.name,
    required this.myScore,
    required this.opponentScore,
  });
  final String name;
  final int myScore;
  final int opponentScore;
}

class CompetitiveResultScreen extends StatelessWidget {
  const CompetitiveResultScreen({
    super.key,
    required this.outcome,
    required this.games,
    required this.goldDelta,
    required this.coinsDelta,
    required this.rpDelta,
    required this.onContinue,
  });

  final CompetitiveResultOutcome outcome;
  final List<GameResultLine> games;
  final int goldDelta;
  final int coinsDelta;
  final int rpDelta;
  final VoidCallback onContinue;

  int get myTotal => games.fold(0, (sum, game) => sum + game.myScore);
  int get opponentTotal => games.fold(0, (sum, game) => sum + game.opponentScore);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final victory = outcome == CompetitiveResultOutcome.victory;
    final draw = outcome == CompetitiveResultOutcome.draw;
    final title = victory ? l10n.victory : draw ? l10n.tie : l10n.defeat;
    final icon = victory ? Icons.emoji_events_rounded : draw ? Icons.handshake_rounded : Icons.shield_outlined;
    final accent = victory ? GameColors.rewardGoldBright : draw ? GameColors.accentBright : GameColors.textSoft;

    return Scaffold(
      backgroundColor: GameColors.backgroundDeep,
      body: Container(
        decoration: const BoxDecoration(gradient: GameColors.arenaGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(GameSpacing.lg),
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: .7, end: 1),
                duration: GameDurations.reveal,
                curve: Curves.easeOutBack,
                builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
                child: Icon(icon, size: 76, color: accent),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: accent),
              ),
              const SizedBox(height: 4),
              Text(
                '$myTotal  —  $opponentTotal',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 24),
              for (final game in games)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: GameColors.surfaceGlass,
                    borderRadius: BorderRadius.circular(GameRadii.card),
                    border: Border.all(color: GameColors.surfaceStrong),
                    boxShadow: GameShadows.card,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          game.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      Text(
                        '${game.myScore}',
                        style: TextStyle(
                          color: game.myScore >= game.opponentScore ? GameColors.success : GameColors.textStrong,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(l10n.vs, style: const TextStyle(color: GameColors.textSoft)),
                      ),
                      Text(
                        '${game.opponentScore}',
                        style: TextStyle(
                          color: game.opponentScore > game.myScore ? GameColors.danger : GameColors.textStrong,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: GameColors.surfaceGlass,
                  borderRadius: BorderRadius.circular(GameRadii.card),
                  border: Border.all(color: GameColors.surfaceStrong),
                ),
                child: Column(
                  children: [
                    _RewardRow(label: 'GOLD', value: goldDelta, color: GameColors.rewardGoldBright),
                    _RewardRow(label: l10n.coins.toUpperCase(), value: coinsDelta, color: GameColors.coin),
                    _RewardRow(label: 'RP', value: rpDelta, color: GameColors.rp),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              SizedBox(
                height: 56,
                child: FilledButton(onPressed: onContinue, child: Text(l10n.resultContinue)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RewardRow extends StatelessWidget {
  const _RewardRow({required this.label, required this.value, required this.color});
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800)),
            const SizedBox(width: 12),
            Text(
              '${value >= 0 ? '+' : ''}$value',
              style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      );
}
