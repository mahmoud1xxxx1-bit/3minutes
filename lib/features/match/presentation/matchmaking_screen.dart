import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
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

  @override
  void initState() {
    super.initState();
    _join();
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
        MaterialPageRoute<void>(
          builder: (_) => MatchRoomScreen(
            matchId: matchId,
            uid: widget.profile.uid,
            matchBackend: widget.matchBackend,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _cancel();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.findingOpponent),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: StreamBuilder<MatchTicket?>(
            stream: widget.matchBackend.watchTicket(widget.profile.uid),
            builder: (context, snapshot) {
              final ticket = snapshot.data;
              if (ticket?.status == MatchTicketStatus.matched &&
                  ticket?.matchId != null) {
                _openMatch(ticket!.matchId!);
              }

              return Padding(
                padding: const EdgeInsets.all(GameSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    Center(
                      child: SizedBox.square(
                        dimension: 156,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox.square(
                              dimension: 156,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: GameColors.accent.withValues(alpha: 0.75),
                                backgroundColor: GameColors.surfaceStrong,
                              ),
                            ),
                            Container(
                              width: 112,
                              height: 112,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: GameColors.surface,
                                border: Border.all(
                                  color: GameColors.accent.withValues(alpha: 0.35),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: GameColors.accent.withValues(alpha: 0.12),
                                    blurRadius: 28,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person_search_rounded,
                                size: 54,
                                color: GameColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: GameSpacing.xl),
                    Text(
                      _joining ? l10n.joiningQueue : l10n.searchingForPlayer,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: GameSpacing.sm),
                    Text(
                      l10n.fairMatchMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: GameColors.muted,
                        height: 1.45,
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: GameSpacing.lg),
                      Container(
                        padding: const EdgeInsets.all(GameSpacing.md),
                        decoration: BoxDecoration(
                          color: GameColors.danger.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(GameRadii.card),
                          border: Border.all(
                            color: GameColors.danger.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Column(
                          children: [
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
                    OutlinedButton.icon(
                      onPressed: _leaving ? null : _cancel,
                      icon: const Icon(Icons.close_rounded),
                      label: Text(_leaving ? l10n.leaving : l10n.cancel),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
