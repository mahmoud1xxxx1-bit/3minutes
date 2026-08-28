import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';

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
    final victory = outcome == CompetitiveResultOutcome.victory;
    final draw = outcome == CompetitiveResultOutcome.draw;
    final title = victory ? 'VICTORY' : draw ? 'DRAW' : 'DEFEAT';
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
              Icon(icon, size: 76, color: accent),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: accent),
              ),
              Text('$myTotal  —  $opponentTotal', textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 24),
              for (final game in games)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: GameColors.surfaceGlass,
                    borderRadius: BorderRadius.circular(GameRadii.card),
                    border: Border.all(color: GameColors.surfaceStrong),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(game.name, style: const TextStyle(fontWeight: FontWeight.w800))),
                      Text('${game.myScore}', style: const TextStyle(color: GameColors.success, fontWeight: FontWeight.w900)),
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('vs')),
                      Text('${game.opponentScore}', style: const TextStyle(fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              const SizedBox(height: 14),
              _RewardRow(label: 'GOLD', value: goldDelta, color: GameColors.rewardGoldBright),
              _RewardRow(label: 'COINS', value: coinsDelta, color: GameColors.coin),
              _RewardRow(label: 'RP', value: rpDelta, color: GameColors.rp),
              const SizedBox(height: 26),
              SizedBox(
                height: 56,
                child: FilledButton(onPressed: onContinue, child: const Text('CONTINUE')),
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
            Text('${value >= 0 ? '+' : ''}$value', style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900)),
          ],
        ),
      );
}
