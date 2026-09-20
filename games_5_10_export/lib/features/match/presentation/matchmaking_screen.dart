import 'package:flutter/material.dart';

import '../../../core/theme/cosmic_background.dart';
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
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(l10n.findingOpponent),
          automaticallyImplyLeading: false,
        ),
        body: CosmicBackground(
          child: SafeArea(
            top: false,
            child: StreamBuilder<MatchTicket?>(
              stream: widget.matchBackend.watchTicket(widget.profile.uid),
              builder: (context, snapshot) {
                final ticket = snapshot.data;
                if (ticket?.status == MatchTicketStatus.matched && ticket?.matchId != null) {
                  _openMatch(ticket!.matchId!);
                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                    GameSpacing.lg,
                    GameSpacing.md,
                    GameSpacing.lg,
                    GameSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(),
                      Center(
                        child: SizedBox.square(
                          dimension: 230,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 230,
                                height: 230,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [Color(0x2426E3EE), Color(0x007957F5)],
                                  ),
                                ),
                              ),
                              SizedBox.square(
                                dimension: 194,
                                child: CircularProgressIndicator(
                                  strokeWidth: 4,
                                  color: GameColors.accentBright,
                                  backgroundColor: GameColors.surfaceStrong,
                                ),
                              ),
                              Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: GameColors.surfaceGlass,
                                  border: Border.all(
                                    color: GameColors.violet.withValues(alpha: 0.45),
                                  ),
                                  boxShadow: GameShadows.primaryGlow,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _joining
                                          ? Icons.sync_rounded
                                          : Icons.rocket_launch_rounded,
                                      color: GameColors.accentBright,
                                      size: 36,
                                    ),
                                    const SizedBox(height: GameSpacing.sm),
                                    Text(
                                      '3:00',
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                            fontWeight: FontWeight.w900,
                                          ),
                                    ),
                                  ],
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
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: GameSpacing.sm),
                      Text(
                        l10n.fairMatchMessage,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                      ),
                      const SizedBox(height: GameSpacing.lg),
                      if (_error != null)
                        CosmicPanel(
                          child: Column(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: GameColors.danger),
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
                        )
                      else
                        CosmicPanel(
                          child: Row(
                            children: [
                              const Icon(Icons.shield_outlined, color: GameColors.violet),
                              const SizedBox(width: GameSpacing.sm),
                              Expanded(
                                child: Text(
                                  l10n.fairMatchMessage,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ),
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
      ),
    );
  }
}
