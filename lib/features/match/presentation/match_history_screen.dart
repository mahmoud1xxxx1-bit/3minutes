import 'package:flutter/material.dart';

import '../../../core/theme/arena_ui.dart';
import '../../../core/theme/cosmic_background.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/game_glyphs.dart';
import '../../../l10n/app_localizations.dart';
import '../data/match_backend.dart';
import '../domain/match_outcome.dart';
import '../domain/match_session.dart';

class MatchHistoryScreen extends StatefulWidget {
  const MatchHistoryScreen({
    super.key,
    required this.uid,
    required this.matchBackend,
  });

  final String uid;
  final MatchBackend matchBackend;

  @override
  State<MatchHistoryScreen> createState() => _MatchHistoryScreenState();
}

class _MatchHistoryScreenState extends State<MatchHistoryScreen> {
  late Future<List<MatchSession>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.matchBackend.loadHistory(widget.uid);
  }

  void _reload() {
    setState(() => _future = widget.matchBackend.loadHistory(widget.uid));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            const GameGlyph(
              type: GameGlyphType.history,
              size: 25,
              color: GameColors.accentBright,
              active: true,
            ),
            const SizedBox(width: 10),
            Text(l10n.matchHistory),
          ],
        ),
        actions: [
          IconButton(
            tooltip: l10n.refresh,
            onPressed: _reload,
            icon: const GameGlyph(
              type: GameGlyphType.history,
              size: 21,
              color: GameColors.textSoft,
            ),
          ),
        ],
      ),
      body: CosmicBackground(
        child: SafeArea(
          top: false,
          child: FutureBuilder<List<MatchSession>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _HistoryLoading();
              }
              if (snapshot.hasError) {
                return _HistoryState(
                  glyph: GameGlyphType.shield,
                  color: GameColors.danger,
                  title: l10n.couldNotLoadHistory,
                  subtitle: ar
                      ? 'تعذر الوصول إلى سجل المواجهات الآن.'
                      : 'Your battle archive could not be reached right now.',
                  action: l10n.tryAgain,
                  onTap: _reload,
                );
              }

              final items = (snapshot.data ?? const <MatchSession>[])
                  .where(
                    (match) =>
                        match.status == MatchStatus.finished ||
                        match.status == MatchStatus.cancelled,
                  )
                  .toList(growable: false);
              if (items.isEmpty) {
                return _HistoryState(
                  glyph: GameGlyphType.history,
                  color: GameColors.muted,
                  title: l10n.noFinishedMatches,
                  subtitle: ar
                      ? 'بعد أول مواجهة ستظهر نتائجك هنا كسجل تنافسي.'
                      : 'Your completed battles will build your competitive archive here.',
                );
              }

              final wins = items.where((match) => _won(match, widget.uid)).length;
              final losses = items.where((match) => _lost(match, widget.uid)).length;

              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  GameSpacing.md,
                  GameSpacing.sm,
                  GameSpacing.md,
                  GameSpacing.xl,
                ),
                children: [
                  _ArchiveHero(
                    ar: ar,
                    total: items.length,
                    wins: wins,
                    losses: losses,
                  ),
                  const SizedBox(height: GameSpacing.lg),
                  ArenaSectionTitle(
                    title: ar ? 'آخر المواجهات' : 'RECENT BATTLES',
                    subtitle: ar
                        ? 'النتيجة والخصم والنقاط في لمحة واحدة.'
                        : 'Opponent, outcome and score at a glance.',
                    trailing: const GameGlyph(
                      type: GameGlyphType.battle,
                      size: 24,
                      color: GameColors.violet,
                    ),
                  ),
                  const SizedBox(height: GameSpacing.sm),
                  for (final match in items) ...[
                    _MatchCard(match: match, uid: widget.uid),
                    const SizedBox(height: GameSpacing.sm),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  static bool _won(MatchSession match, String uid) {
    if (match.status != MatchStatus.finished) return false;
    final outcome = MatchOutcomeResolver.compare(
      playerA: match.progressA,
      playerB: match.progressB,
      gameCount: match.gameCount,
    );
    final iAmA = match.playerAId == uid;
    return (outcome == MatchOutcome.playerA && iAmA) ||
        (outcome == MatchOutcome.playerB && !iAmA);
  }

  static bool _lost(MatchSession match, String uid) {
    if (match.status != MatchStatus.finished) return false;
    final outcome = MatchOutcomeResolver.compare(
      playerA: match.progressA,
      playerB: match.progressB,
      gameCount: match.gameCount,
    );
    final iAmA = match.playerAId == uid;
    return (outcome == MatchOutcome.playerA && !iAmA) ||
        (outcome == MatchOutcome.playerB && iAmA);
  }
}

class _ArchiveHero extends StatelessWidget {
  const _ArchiveHero({
    required this.ar,
    required this.total,
    required this.wins,
    required this.losses,
  });

  final bool ar;
  final int total;
  final int wins;
  final int losses;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(GameSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF132D52), Color(0xFF251F4B), Color(0xFF09152C)],
        ),
        border: Border.all(color: GameColors.violet.withValues(alpha: .30)),
        boxShadow: const [BoxShadow(color: Color(0x282B72FF), blurRadius: 28, offset: Offset(0, 12))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const GameGlyph(
                type: GameGlyphType.history,
                size: 34,
                color: GameColors.accentBright,
                active: true,
              ),
              const SizedBox(width: GameSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ar ? 'أرشيف المواجهات' : 'BATTLE ARCHIVE',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ar
                          ? 'كل نتيجة محفوظة لتعرف كيف تتطور.'
                          : 'Every result is part of your competitive story.',
                      style: const TextStyle(color: GameColors.textSoft, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: GameSpacing.lg),
          Row(
            children: [
              ArenaMetric(
                label: ar ? 'المواجهات' : 'BATTLES',
                value: '$total',
                icon: Icons.sports_esports_rounded,
                color: GameColors.violet,
              ),
              const SizedBox(width: 8),
              ArenaMetric(
                label: ar ? 'فوز' : 'WINS',
                value: '$wins',
                icon: Icons.arrow_upward_rounded,
                color: GameColors.success,
              ),
              const SizedBox(width: 8),
              ArenaMetric(
                label: ar ? 'خسارة' : 'LOSSES',
                value: '$losses',
                icon: Icons.arrow_downward_rounded,
                color: GameColors.danger,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match, required this.uid});
  final MatchSession match;
  final String uid;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mine = match.progressFor(uid);
    final opponent = match.opponentProgress(uid);
    final cancelled = match.status == MatchStatus.cancelled;
    final outcome = MatchOutcomeResolver.compare(
      playerA: match.progressA,
      playerB: match.progressB,
      gameCount: match.gameCount,
    );
    final iAmA = match.playerAId == uid;
    final won = !cancelled &&
        ((outcome == MatchOutcome.playerA && iAmA) ||
            (outcome == MatchOutcome.playerB && !iAmA));
    final lost = !cancelled &&
        ((outcome == MatchOutcome.playerA && !iAmA) ||
            (outcome == MatchOutcome.playerB && iAmA));
    final label = cancelled
        ? l10n.cancelled
        : won
            ? l10n.win
            : lost
                ? l10n.loss
                : l10n.tie;
    final color = cancelled
        ? GameColors.muted
        : won
            ? GameColors.success
            : lost
                ? GameColors.danger
                : GameColors.warning;
    final glyph = cancelled
        ? GameGlyphType.history
        : won
            ? GameGlyphType.trophy
            : GameGlyphType.battle;

    return ArenaCard(
      glow: won,
      accent: color,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: color.withValues(alpha: .24)),
            ),
            alignment: Alignment.center,
            child: GameGlyph(type: glyph, size: 27, color: color, active: won),
          ),
          const SizedBox(width: GameSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        match.opponentName(uid),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    ArenaPill(label: label, color: color, solid: true),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _Score(label: l10n.you, value: mine.totalScore, color: GameColors.accentBright),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _Score(label: l10n.opponent, value: opponent.totalScore, color: GameColors.warning),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${mine.completedGames}/${match.gameCount}',
                      style: const TextStyle(color: GameColors.muted, fontSize: 10, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Score extends StatelessWidget {
  const _Score({required this.label, required this.value, required this.color});
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$value', style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14)),
        const SizedBox(height: 2),
        Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: GameColors.muted, fontSize: 8)),
      ],
    );
  }
}

class _HistoryLoading extends StatelessWidget {
  const _HistoryLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GameGlyph(
            type: GameGlyphType.history,
            size: 42,
            color: GameColors.accentBright,
            active: true,
          ),
          SizedBox(height: GameSpacing.md),
          SizedBox(width: 120, child: LinearProgressIndicator()),
        ],
      ),
    );
  }
}

class _HistoryState extends StatelessWidget {
  const _HistoryState({
    required this.glyph,
    required this.color,
    required this.title,
    required this.subtitle,
    this.action,
    this.onTap,
  });
  final GameGlyphType glyph;
  final Color color;
  final String title;
  final String subtitle;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(GameSpacing.lg),
        child: ArenaCard(
          accent: color,
          glow: true,
          padding: const EdgeInsets.all(GameSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GameGlyph(type: glyph, size: 48, color: color, active: true),
              const SizedBox(height: GameSpacing.md),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(height: 6),
              Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: GameColors.muted, height: 1.45)),
              if (action != null && onTap != null) ...[
                const SizedBox(height: GameSpacing.lg),
                FilledButton(onPressed: onTap, child: Text(action!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
