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
import '../domain/ranked_wager.dart';
import 'match_room_screen.dart';
import 'match_rules_sheet.dart';

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
  bool _joining = false;
  bool _leaving = false;
  bool _navigating = false;
  RankedWager? _selectedWager;
  late DateTime _startedAt;
  Timer? _ticker;

  bool get _usesGoldWager => widget.matchBackend is RankedWagerQueueBackend;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    if (!_usesGoldWager) unawaited(_join());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _chooseWager(RankedWager wager) async {
    if (_joining) return;
    setState(() {
      _selectedWager = wager;
      _startedAt = DateTime.now();
    });
    await _join();
  }

  Future<void> _join() async {
    if (_usesGoldWager && _selectedWager == null) return;
    if (mounted) {
      setState(() {
        _joining = true;
        _error = null;
      });
    }
    try {
      final backend = widget.matchBackend;
      if (backend is RankedWagerQueueBackend) {
        await (backend as RankedWagerQueueBackend).joinRankedQueueWithWager(
          widget.profile,
          wager: _selectedWager!,
        );
      } else {
        await backend.joinQueue(widget.profile);
      }
    } catch (error) {
      if (!mounted) return;
      final raw = error.toString();
      final isInsufficientGold = raw.contains('Insufficient Gold');
      final copy = ArenaCopy.of(context);
      setState(() {
        _error = isInsufficientGold
            ? (copy.isArabic
                ? 'رصيد Gold غير كافٍ لهذا التحدي. اختر رهانًا أقل أو احصل على Gold إضافي.'
                : 'Not enough Gold for this challenge. Choose a lower wager or earn more Gold.')
            : AppLocalizations.of(context).matchmakingFailed;
      });
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
          pageBuilder: (_, animation, _) => FadeTransition(
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
    final radarSize = MediaQuery.sizeOf(context).width.clamp(210.0, 265.0).toDouble();

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
              padding: const EdgeInsets.fromLTRB(
                GameSpacing.md,
                GameSpacing.sm,
                GameSpacing.md,
                GameSpacing.lg,
              ),
              child: StreamBuilder<MatchTicket?>(
                stream: widget.matchBackend.watchTicket(widget.profile.uid),
                builder: (context, snapshot) {
                  final ticket = snapshot.data;
                  if (ticket?.status == MatchTicketStatus.matched && ticket?.matchId != null) {
                    _openMatch(ticket!.matchId!);
                  }

                  if (_usesGoldWager && _selectedWager == null) {
                    return _WagerPicker(
                      copy: copy,
                      leaving: _leaving,
                      onCancel: _cancel,
                      onRules: () => showMatchRulesSheet(context),
                      onChoose: _chooseWager,
                    );
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
                                Text(
                                  copy.searching,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  _selectedWager == null
                                      ? copy.fairFight
                                      : (copy.isArabic
                                          ? 'تحدي ${_selectedWager!.gold} Gold'
                                          : '${_selectedWager!.gold} Gold challenge'),
                                  style: const TextStyle(
                                    color: GameColors.muted,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: copy.isArabic ? 'قواعد المواجهة' : 'Match rules',
                            onPressed: () => showMatchRulesSheet(context),
                            icon: const Icon(
                              Icons.info_outline_rounded,
                              color: GameColors.accentBright,
                            ),
                          ),
                          ArenaPill(
                            label: elapsedText,
                            icon: Icons.timer_outlined,
                            color: GameColors.accentBright,
                          ),
                        ],
                      ),
                      const Spacer(),
                      Center(child: ArenaRadar(size: radarSize)),
                      const SizedBox(height: GameSpacing.lg),
                      AnimatedSwitcher(
                        duration: GameDurations.normal,
                        child: Text(
                          _stage(copy),
                          key: ValueKey(_stage(copy)),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: .5,
                              ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        copy.searchHint,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: GameColors.muted,
                              height: 1.5,
                            ),
                      ),
                      const SizedBox(height: GameSpacing.lg),
                      ArenaCard(
                        accent: GameColors.violet,
                        child: Row(
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: GameColors.cosmicGradient,
                              ),
                              padding: const EdgeInsets.all(2),
                              child: ClipOval(
                                child: ColoredBox(
                                  color: GameColors.surface,
                                  child: AvatarArtwork(
                                    avatarId: widget.profile.avatarId,
                                    size: 54,
                                    borderRadius: 27,
                                  ),
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
                                        child: Text(
                                          widget.profile.gameName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.w900),
                                        ),
                                      ),
                                      RankBadge(tier: tier, compact: true),
                                    ],
                                  ),
                                  const SizedBox(height: 7),
                                  Row(
                                    children: [
                                      _MiniStat(
                                        label: copy.yourPower,
                                        value: '${widget.profile.rankPoints} RP',
                                      ),
                                      const SizedBox(width: 12),
                                      _MiniStat(
                                        label: copy.winRate,
                                        value: '${(widget.profile.winRate * 100).round()}%',
                                      ),
                                      const SizedBox(width: 12),
                                      _MiniStat(
                                        label: copy.bestStreak,
                                        value: '${widget.profile.bestWinStreak}',
                                      ),
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
                              const Icon(
                                Icons.error_outline_rounded,
                                color: GameColors.danger,
                              ),
                              const SizedBox(height: GameSpacing.sm),
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: GameColors.danger),
                              ),
                              const SizedBox(height: GameSpacing.sm),
                              OutlinedButton(
                                onPressed: _joining ? null : _join,
                                child: Text(l10n.tryAgain),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: ArenaCard(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.shield_rounded,
                                    color: GameColors.success,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      copy.fairFight,
                                      style: const TextStyle(
                                        color: GameColors.textSoft,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ArenaPill(
                            label: copy.estimated,
                            icon: Icons.speed_rounded,
                            color: GameColors.warning,
                          ),
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

class _WagerPicker extends StatelessWidget {
  const _WagerPicker({
    required this.copy,
    required this.leaving,
    required this.onCancel,
    required this.onRules,
    required this.onChoose,
  });

  final ArenaCopy copy;
  final bool leaving;
  final VoidCallback onCancel;
  final VoidCallback onRules;
  final ValueChanged<RankedWager> onChoose;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: leaving ? null : onCancel,
              icon: const Icon(Icons.close_rounded),
            ),
            Expanded(
              child: Text(
                copy.isArabic ? 'اختر قيمة التحدي' : 'CHOOSE CHALLENGE',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
              ),
            ),
            IconButton(
              tooltip: copy.isArabic ? 'القواعد والنقاط' : 'Rules & scoring',
              onPressed: onRules,
              icon: const Icon(
                Icons.info_outline_rounded,
                color: GameColors.accentBright,
              ),
            ),
          ],
        ),
        const Spacer(),
        Text(
          copy.isArabic
              ? 'كل لاعب يضع نفس قيمة Gold في الرهان. عند العثور على الخصم يحجز الخادم الرهان من الطرفين، والفائز يحصل على كامل المبلغ.'
              : 'Both players stake the same Gold amount. The server locks both wagers when a rival is found, and the winner receives the full pool.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: GameColors.textSoft, height: 1.55),
        ),
        const SizedBox(height: GameSpacing.lg),
        for (final wager in RankedWager.values) ...[
          _WagerCard(wager: wager, copy: copy, onTap: () => onChoose(wager)),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: GameSpacing.md),
        ArenaCard(
          accent: GameColors.warning,
          child: Text(
            copy.isArabic
                ? 'مثال: تحدي 250 Gold = 250 منك + 250 من الخصم. الفائز يستلم 500 Gold.'
                : 'Example: 250 Gold challenge = 250 from you + 250 from your rival. Winner receives 500 Gold.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: GameColors.textSoft, height: 1.45),
          ),
        ),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: leaving ? null : onCancel,
          icon: const Icon(Icons.close_rounded),
          label: Text(copy.isArabic ? 'إلغاء' : 'Cancel'),
        ),
      ],
    );
  }
}

class _WagerCard extends StatelessWidget {
  const _WagerCard({
    required this.wager,
    required this.copy,
    required this.onTap,
  });

  final RankedWager wager;
  final ArenaCopy copy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pool = wager.gold * 2;
    return ArenaCard(
      accent: wager == RankedWager.gold500
          ? GameColors.warning
          : wager == RankedWager.gold250
              ? GameColors.violet
              : GameColors.accentBright,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.paid_rounded, color: GameColors.warning, size: 30),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${wager.gold} Gold',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      copy.isArabic ? 'مجموع الجائزة $pool Gold' : 'Prize pool $pool Gold',
                      style: const TextStyle(color: GameColors.textSoft, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: GameColors.muted),
            ],
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
          Text(
            value,
            maxLines: 1,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: GameColors.muted, fontSize: 8),
          ),
        ],
      ),
    );
  }
}
