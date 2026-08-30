import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/arena_copy.dart';
import '../../../core/theme/arena_ui.dart';
import '../../../core/theme/cosmic_background.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../competition/domain/rank_tier.dart';
import '../../competition/presentation/rank_badge.dart';
import '../../economy/presentation/avatar_artwork.dart';
import '../../profile/domain/player_profile.dart';
import '../data/match_backend.dart';
import '../domain/match_ticket.dart';
import 'match_room_screen.dart';

class MatchmakingScreen extends StatefulWidget {
  const MatchmakingScreen({
    super.key,
    required this.profile,
    required this.matchBackend,
  });

  final PlayerProfile profile;
  final MatchBackend matchBackend;

  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen> {
  String? _error;
  bool _joining = true;
  bool _leaving = false;
  bool _navigating = false;
  late final DateTime _startedAt;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    _join();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _join() async {
    if (mounted) {
      setState(() {
        _joining = true;
        _error = null;
      });
    }
    try {
      await widget.matchBackend.joinQueue(widget.profile);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = AppLocalizations.of(context).matchmakingFailed);
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  Future<void> _cancel() async {
    if (_leaving || _navigating) return;
    setState(() => _leaving = true);
    try {
      await widget.matchBackend.leaveQueue(widget.profile.uid);
    } finally {
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _openMatch(String matchId) {
    if (_navigating) return;
    _navigating = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, animation, __) => FadeTransition(
            opacity: animation,
            child: MatchRoomScreen(
              matchId: matchId,
              uid: widget.profile.uid,
              matchBackend: widget.matchBackend,
            ),
          ),
        ),
      );
    });
  }

  int get _elapsed => DateTime.now().difference(_startedAt).inSeconds;

  String _stage(ArenaCopy copy) {
    if (_joining) return copy.scanningArena;
    if (_elapsed < 5) return copy.scanningArena;
    if (_elapsed < 12) return copy.syncingRank;
    return copy.searching;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final copy = ArenaCopy.of(context);
    final tier = RankPolicy.tierFor(widget.profile.rankPoints);
    final elapsedText = '0:${_elapsed.clamp(0, 99).toString().padLeft(2, '0')}';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _cancel();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CosmicBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(GameSpacing.md, GameSpacing.sm, GameSpacing.md, GameSpacing.lg),
              child: StreamBuilder<MatchTicket?>(
                stream: widget.matchBackend.watchTicket(widget.profile.uid),
                builder: (context, snapshot) {
                  final ticket = snapshot.data;
                  if (ticket?.status == MatchTicketStatus.matched && ticket?.matchId != null) {
                    _openMatch(ticket!.matchId!);
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            tooltip: l10n.cancel,
                            onPressed: _leaving ? null : _cancel,
                            icon: const Icon(Icons.close_rounded),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(copy.searching, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                                Text(copy.fairFight, style: const TextStyle(color: GameColors.muted, fontSize: 10)),
                              ],
                            ),
                          ),
                          ArenaPill(label: elapsedText, icon: Icons.timer_outlined, color: GameColors.accentBright),
                        ],
                      ),
                      const Spacer(),
                      Center(child: ArenaRadar(size: MediaQuery.sizeOf(context).width.clamp(210.0, 265.0))),
                      const SizedBox(height: GameSpacing.lg),
                      AnimatedSwitcher(
                        duration: GameDurations.normal,
                        child: Text(
                          _stage(copy),
                          key: ValueKey(_stage(copy)),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: .5),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        copy.searchHint,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: GameColors.muted, height: 1.5),
                      ),
                      const SizedBox(height: GameSpacing.lg),
                      ArenaCard(
                        accent: GameColors.violet,
                        child: Row(
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: const BoxDecoration(shape: BoxShape.circle, gradient: GameColors.cosmicGradient),
                              padding: const EdgeInsets.all(2),
                              child: ClipOval(
                                child: ColoredBox(
                                  color: GameColors.surface,
                                  child: AvatarArtwork(avatarId: widget.profile.avatarId, size: 54, borderRadius: 27),
                                ),
                              ),
                            ),
                            const SizedBox(width: GameSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(widget.profile.gameName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
                                      ),
                                      RankBadge(tier: tier, compact: true),
                                    ],
                                  ),
                                  const SizedBox(height: 7),
                                  Row(
                                    children: [
                                      _MiniStat(label: copy.yourPower, value: '${widget.profile.rankPoints} RP'),
                                      const SizedBox(width: 12),
                                      _MiniStat(label: copy.winRate, value: '${(widget.profile.winRate * 100).round()}%'),
                                      const SizedBox(width: 12),
                                      _MiniStat(label: copy.bestStreak, value: '${widget.profile.bestWinStreak}'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: GameSpacing.md),
                        ArenaCard(
                          accent: GameColors.danger,
                          child: Column(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: GameColors.danger),
                              const SizedBox(height: GameSpacing.sm),
                              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: GameColors.danger)),
                              const SizedBox(height: GameSpacing.sm),
                              OutlinedButton(onPressed: _joining ? null : _join, child: Text(l10n.tryAgain)),
                            ],
                          ),
                        ),
                      ],
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: ArenaCard(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Row(
                                children: [
                                  const Icon(Icons.shield_rounded, color: GameColors.success, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(copy.fairFight, style: const TextStyle(color: GameColors.textSoft, fontSize: 9, fontWeight: FontWeight.w800))),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ArenaPill(label: copy.estimated, icon: Icons.speed_rounded, color: GameColors.warning),
                        ],
                      ),
                      const SizedBox(height: GameSpacing.sm),
                      OutlinedButton.icon(
                        onPressed: _leaving ? null : _cancel,
                        icon: const Icon(Icons.close_rounded),
                        label: Text(_leaving ? l10n.leaving : l10n.cancel),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, maxLines: 1, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: GameColors.muted, fontSize: 8)),
        ],
      ),
    );
  }
}
