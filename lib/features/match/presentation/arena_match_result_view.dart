import 'package:flutter/material.dart';

import '../../../core/theme/arena_copy.dart';
import '../../../core/theme/arena_ui.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../competition/domain/ranked_settlement_player.dart';
import '../../economy/data/cosmetic_loadout_repository.dart';
import '../../economy/domain/cosmetic_loadout.dart';
import '../../economy/presentation/cosmetic_runtime.dart';
import '../data/match_backend.dart';
import '../domain/match_outcome.dart';
import '../domain/match_session.dart';
import '../domain/match_settlement.dart';

class ArenaMatchResultView extends StatefulWidget {
  const ArenaMatchResultView({super.key, required this.uid, required this.match, required this.matchBackend, required this.localCompletedGames});
  final String uid;
  final MatchSession match;
  final MatchBackend matchBackend;
  final int localCompletedGames;
  @override
  State<ArenaMatchResultView> createState() => _ArenaMatchResultViewState();
}

class _ArenaMatchResultViewState extends State<ArenaMatchResultView> {
  bool _leaving = false;
  bool _rematchBusy = false;
  bool _switchingMatch = false;
  bool _finalizeStarted = false;
  bool _settlementLoading = false;
  String? _error;
  RankedSettlementPlayer? _settlement;

  Future<void> _finalize() async {
    if (_finalizeStarted) return;
    _finalizeStarted = true;
    if (mounted) setState(() => _settlementLoading = true);
    try {
      final backend = widget.matchBackend;
      if (backend is RankedSettlementResultBackend && widget.match.isRanked) {
        final receipt = await backend.finalizeMatchWithResult(matchId: widget.match.id, uid: widget.uid);
        if (mounted) setState(() => _settlement = receipt);
      } else {
        await backend.finalizeMatch(matchId: widget.match.id, uid: widget.uid);
      }
    } catch (_) {
      _finalizeStarted = false;
    } finally {
      if (mounted) setState(() => _settlementLoading = false);
    }
  }

  Future<void> _requestRematch() async {
    if (_rematchBusy || _leaving) return;
    setState(() { _rematchBusy = true; _error = null; });
    try {
      await widget.matchBackend.requestRematch(matchId: widget.match.id, uid: widget.uid);
    } catch (_) {
      if (mounted) setState(() => _error = AppLocalizations.of(context).tryAgain);
    } finally {
      if (mounted) setState(() => _rematchBusy = false);
    }
  }

  Future<void> _switchToRematch(String newMatchId) async {
    if (_switchingMatch) return;
    _switchingMatch = true;
    try {
      await widget.matchBackend.moveTicketToMatch(uid: widget.uid, matchId: newMatchId);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      _switchingMatch = false;
      if (mounted) setState(() => _error = AppLocalizations.of(context).tryAgain);
    }
  }

  Future<void> _backHome() async {
    if (_leaving || _switchingMatch) return;
    setState(() { _leaving = true; _error = null; });
    try {
      if (widget.match.requestedRematch(widget.uid) && widget.match.rematchMatchId == null) {
        await widget.matchBackend.cancelRematchRequest(matchId: widget.match.id, uid: widget.uid);
      }
      await widget.matchBackend.clearTicket(widget.uid);
    } catch (_) {
      if (mounted) setState(() { _leaving = false; _error = AppLocalizations.of(context).tryAgain; });
      return;
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final copy = ArenaCopy.of(context);
    final match = widget.match;
    final remoteLocal = match.progressFor(widget.uid);
    final waitingForFinalWrite = widget.localCompletedGames >= match.gameCount &&
        (remoteLocal.completedGames < match.gameCount || remoteLocal.completedAt == null);
    if (waitingForFinalWrite) return _ResultWaiting(text: l10n.saving);

    final settled = MatchSettlement.isSettled(
      playerA: match.progressA,
      playerB: match.progressB,
      gameCount: match.gameCount,
      countdownStartedAt: match.countdownStartedAt,
      now: DateTime.now(),
    );
    if (!settled) {
      final opponent = match.opponentProgress(widget.uid);
      return Padding(
        padding: const EdgeInsets.all(GameSpacing.lg),
        child: Center(
          child: ArenaCard(
            glow: true,
            accent: GameColors.violet,
            padding: const EdgeInsets.all(GameSpacing.lg),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox.square(dimension: 42, child: CircularProgressIndicator(strokeWidth: 3)),
              const SizedBox(height: GameSpacing.lg),
              Text(l10n.waitingForOpponent, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: GameSpacing.sm),
              Text(l10n.historyOpponentResult(opponent.completedGames, match.gameCount, opponent.totalScore), textAlign: TextAlign.center, style: const TextStyle(color: GameColors.muted)),
            ]),
          ),
        ),
      );
    }

    if (!_finalizeStarted) WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _finalize(); });
    final newMatchId = match.rematchMatchId;
    if (newMatchId != null && !_switchingMatch) WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _switchToRematch(newMatchId); });
    if (_switchingMatch) return _ResultWaiting(text: l10n.gettingReady);

    final outcome = MatchOutcomeResolver.compare(playerA: match.progressA, playerB: match.progressB, gameCount: match.gameCount);
    final iAmA = match.playerAId == widget.uid;
    final won = (outcome == MatchOutcome.playerA && iAmA) || (outcome == MatchOutcome.playerB && !iAmA);
    final lost = (outcome == MatchOutcome.playerA && !iAmA) || (outcome == MatchOutcome.playerB && iAmA);
    final title = won ? l10n.victory : (lost ? l10n.defeat : l10n.tie);
    final headline = won ? copy.victoryHeadline : (lost ? copy.defeatHeadline : copy.tieHeadline);
    final resultColor = won ? GameColors.success : (lost ? GameColors.danger : GameColors.warning);
    final mine = match.progressFor(widget.uid);
    final opponent = match.opponentProgress(widget.uid);
    final requested = match.requestedRematch(widget.uid);
    final opponentRequested = iAmA ? match.rematchB : match.rematchA;
    final winnerUid = outcome == MatchOutcome.playerA ? match.playerAId : (outcome == MatchOutcome.playerB ? match.playerBId : null);
    final winnerName = outcome == MatchOutcome.playerA ? match.playerAName : (outcome == MatchOutcome.playerB ? match.playerBName : null);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(GameSpacing.md, GameSpacing.lg, GameSpacing.md, 42),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _ResultHero(winnerUid: winnerUid, winnerName: winnerName, title: title, headline: headline, color: resultColor),
        const SizedBox(height: GameSpacing.md),
        _ScoreBoard(myScore: mine.totalScore, opponentScore: opponent.totalScore, myGames: mine.completedGames, opponentGames: opponent.completedGames, totalGames: match.gameCount, color: resultColor),
        const SizedBox(height: GameSpacing.md),
        _RewardBoard(settlement: _settlement, loading: _settlementLoading, ranked: match.isRanked),
        if (requested || opponentRequested) ...[
          const SizedBox(height: GameSpacing.md),
          ArenaCard(accent: GameColors.violet, child: Row(children: [
            const Icon(Icons.sync_rounded, color: GameColors.violet),
            const SizedBox(width: GameSpacing.sm),
            Expanded(child: Text(requested ? l10n.waitingForOpponent : l10n.opponentFound, style: const TextStyle(color: GameColors.textSoft, fontWeight: FontWeight.w800))),
          ])),
        ],
        if (_error != null) ...[
          const SizedBox(height: GameSpacing.sm),
          Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: GameColors.danger)),
        ],
        const SizedBox(height: GameSpacing.lg),
        ArenaPlayButton(title: copy.rematchNow, subtitle: copy.isArabic ? 'نفس الخصم • مواجهة جديدة • فرصة للرد' : 'Same rival • fresh battle • settle the score', icon: Icons.replay_rounded, onPressed: requested || _rematchBusy || _leaving ? null : _requestRematch),
        const SizedBox(height: GameSpacing.sm),
        ArenaPlayButton(title: copy.home, subtitle: copy.isArabic ? 'العودة للساحة ومراجعة تقدمك' : 'Return to the arena and review your progress', icon: Icons.home_rounded, primary: false, onPressed: _leaving || _rematchBusy ? null : _backHome),
      ]),
    );
  }
}

class _ResultHero extends StatelessWidget {
  const _ResultHero({required this.winnerUid, required this.winnerName, required this.title, required this.headline, required this.color});
  final String? winnerUid;
  final String? winnerName;
  final String title;
  final String headline;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final uid = winnerUid;
    final name = winnerName;
    return Column(children: [
      if (uid != null && name != null)
        FutureBuilder<CosmeticLoadout>(
          future: CosmeticLoadoutRepository().load(uid),
          builder: (context, snapshot) {
            final loadout = snapshot.data ?? const CosmeticLoadout();
            final effect = loadout.victoryEffectId;
            return effect != null ? CosmeticVictoryEffect(effectId: effect, winnerName: name, height: 190) : _ResultEmblem(color: color);
          },
        )
      else
        _ResultEmblem(color: color),
      const SizedBox(height: GameSpacing.md),
      Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.displaySmall?.copyWith(color: color, fontWeight: FontWeight.w900, letterSpacing: .8)),
      const SizedBox(height: 5),
      Text(headline, textAlign: TextAlign.center, style: const TextStyle(color: GameColors.textSoft, fontWeight: FontWeight.w800)),
    ]);
  }
}

class _ResultEmblem extends StatelessWidget {
  const _ResultEmblem({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: 112,
    height: 112,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: .10), border: Border.all(color: color.withValues(alpha: .55), width: 2), boxShadow: [BoxShadow(color: color.withValues(alpha: .18), blurRadius: 38)]),
    child: Icon(Icons.emoji_events_rounded, size: 56, color: color),
  );
}

class _ScoreBoard extends StatelessWidget {
  const _ScoreBoard({required this.myScore, required this.opponentScore, required this.myGames, required this.opponentGames, required this.totalGames, required this.color});
  final int myScore;
  final int opponentScore;
  final int myGames;
  final int opponentGames;
  final int totalGames;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final copy = ArenaCopy.of(context);
    return ArenaCard(accent: color, glow: color == GameColors.success, child: Column(children: [
      ArenaSectionTitle(title: copy.finalScore, icon: Icons.scoreboard_rounded),
      const SizedBox(height: GameSpacing.md),
      Row(children: [
        Expanded(child: _ScoreSide(label: copy.you, score: myScore, games: myGames, total: totalGames, color: GameColors.accentBright)),
        Container(width: 1, height: 72, color: GameColors.surfaceStrong),
        Expanded(child: _ScoreSide(label: copy.rival, score: opponentScore, games: opponentGames, total: totalGames, color: GameColors.warning)),
      ]),
    ]));
  }
}

class _ScoreSide extends StatelessWidget {
  const _ScoreSide({required this.label, required this.score, required this.games, required this.total, required this.color});
  final String label;
  final int score;
  final int games;
  final int total;
  final Color color;
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900)),
    const SizedBox(height: 5),
    Text('$score', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, fontFeatures: [FontFeature.tabularFigures()])),
    const SizedBox(height: 3),
    Text('$games/$total', style: const TextStyle(color: GameColors.muted, fontSize: 10, fontWeight: FontWeight.w800)),
  ]);
}

class _RewardBoard extends StatelessWidget {
  const _RewardBoard({required this.settlement, required this.loading, required this.ranked});
  final RankedSettlementPlayer? settlement;
  final bool loading;
  final bool ranked;
  @override
  Widget build(BuildContext context) {
    final copy = ArenaCopy.of(context);
    final receipt = settlement;
    return ArenaCard(accent: GameColors.rewardGold, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ArenaSectionTitle(
        title: copy.matchRewards,
        subtitle: receipt == null ? copy.rewardPending : (receipt.promoted ? (copy.isArabic ? 'ترقية رتبة! تم تثبيت المكافآت.' : 'RANK UP! Rewards verified.') : null),
        icon: Icons.redeem_rounded,
        trailing: loading ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : null,
      ),
      const SizedBox(height: GameSpacing.md),
      if (receipt == null)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: GameColors.background.withValues(alpha: .30), borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            const Icon(Icons.verified_user_outlined, color: GameColors.muted),
            const SizedBox(width: GameSpacing.sm),
            Expanded(child: Text(copy.rewardPending, style: const TextStyle(color: GameColors.muted, fontSize: 11))),
          ]),
        )
      else ...[
        Row(children: [
          ArenaMetric(label: copy.coins, value: '+${receipt.coinsAwarded}', icon: Icons.monetization_on_rounded, color: GameColors.rewardGold),
          const SizedBox(width: 8),
          ArenaMetric(label: copy.xp, value: '+${receipt.xpAwarded}', icon: Icons.auto_awesome_rounded, color: GameColors.violet),
          if (ranked) ...[
            const SizedBox(width: 8),
            ArenaMetric(label: 'RP', value: '${receipt.rpDelta >= 0 ? '+' : ''}${receipt.rpDelta}', icon: receipt.rpDelta >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded, color: receipt.rpDelta >= 0 ? GameColors.success : GameColors.danger),
          ],
        ]),
        if (ranked) ...[
          const SizedBox(height: GameSpacing.sm),
          ArenaProgress(value: _rankDeltaProgress(receipt), color: receipt.rpDelta >= 0 ? GameColors.success : GameColors.danger, height: 7),
          const SizedBox(height: 6),
          Text('${receipt.previousRp} RP  →  ${receipt.nextRp} RP', textAlign: TextAlign.center, style: const TextStyle(color: GameColors.textSoft, fontSize: 10, fontWeight: FontWeight.w800)),
        ],
      ],
    ]));
  }

  double _rankDeltaProgress(RankedSettlementPlayer receipt) {
    final delta = receipt.rpDelta.abs().clamp(0, 120).toDouble();
    return (delta / 120).clamp(0.05, 1.0).toDouble();
  }
}

class _ResultWaiting extends StatelessWidget {
  const _ResultWaiting({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Center(
    child: ArenaCard(
      glow: true,
      accent: GameColors.violet,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const CircularProgressIndicator(),
        const SizedBox(height: GameSpacing.md),
        Text(text),
      ]),
    ),
  );
}
