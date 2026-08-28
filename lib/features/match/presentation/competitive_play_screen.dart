import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../economy/data/competitive_economy_service.dart';
import '../../economy/data/competitive_wallet_repository.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/domain/player_profile.dart';
import '../application/game_integration_catalog.dart';
import '../data/competitive_match_firestore_repository.dart';
import 'competitive_session_flow.dart';
import 'wager_selection_screen.dart';

class CompetitivePlayScreen extends StatefulWidget {
  const CompetitivePlayScreen({
    super.key,
    required this.uid,
    required this.profileRepository,
    required this.walletRepository,
    required this.economyService,
    required this.matchRepository,
  });

  final String uid;
  final ProfileRepository profileRepository;
  final CompetitiveWalletRepository walletRepository;
  final CompetitiveEconomyService economyService;
  final CompetitiveMatchFirestoreRepository matchRepository;

  @override
  State<CompetitivePlayScreen> createState() => _CompetitivePlayScreenState();
}

class _CompetitivePlayScreenState extends State<CompetitivePlayScreen> {
  late Future<CompetitiveRecoveryResult> _recovery;

  @override
  void initState() {
    super.initState();
    _recovery = widget.economyService.recoverQueue();
  }

  void _refreshRecovery() {
    setState(() => _recovery = widget.economyService.recoverQueue());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerProfile?>(
      stream: widget.profileRepository.watchProfile(widget.uid),
      builder: (context, profileSnapshot) {
        final profile = profileSnapshot.data;
        if (profile == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return FutureBuilder<CompetitiveRecoveryResult>(
          future: _recovery,
          builder: (context, recoverySnapshot) {
            if (recoverySnapshot.connectionState != ConnectionState.done) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            if (recoverySnapshot.hasError) {
              return _RecoveryError(onRetry: _refreshRecovery);
            }

            final recovery = recoverySnapshot.data!;
            final wager = recovery.wager;

            if (recovery.hasActiveMatch && wager != null) {
              return _ResumeMatchPanel(
                uid: widget.uid,
                matchId: recovery.matchId!,
                wager: wager,
                matchRepository: widget.matchRepository,
                onResume: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => CompetitiveSessionFlow(
                        uid: widget.uid,
                        matchId: recovery.matchId!,
                        wager: wager,
                        matchRepository: widget.matchRepository,
                        economyService: widget.economyService,
                      ),
                    ),
                  );
                  if (mounted) _refreshRecovery();
                },
              );
            }

            if (recovery.status == 'searching' && wager != null) {
              return CompetitiveMatchmakingFlow(
                uid: widget.uid,
                wager: wager,
                playerName: profile.gameName,
                initialMatchId: null,
                economyService: widget.economyService,
                matchRepository: widget.matchRepository,
                embedded: true,
                onFlowEnded: _refreshRecovery,
              );
            }

            if (!GameIntegrationCatalog.isCompetitionReady) {
              return const _CompetitionPreparingPanel();
            }

            return StreamBuilder(
              stream: widget.walletRepository.watchWallet(widget.uid),
              builder: (context, walletSnapshot) {
                final wallet = walletSnapshot.data;
                return WagerSelectionScreen(
                  goldBalance: wallet?.availableGold ?? 0,
                  onFindOpponent: (selectedWager) async {
                    final result = await widget.economyService.enterWager(
                      wager: selectedWager,
                      displayName: profile.gameName,
                      avatarId: profile.avatarId,
                    );
                    if (!context.mounted) return;
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => CompetitiveMatchmakingFlow(
                          uid: widget.uid,
                          wager: selectedWager,
                          playerName: profile.gameName,
                          initialMatchId: result.matchId,
                          economyService: widget.economyService,
                          matchRepository: widget.matchRepository,
                        ),
                      ),
                    );
                    if (mounted) _refreshRecovery();
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _CompetitionPreparingPanel extends StatelessWidget {
  const _CompetitionPreparingPanel();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(GameSpacing.lg),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: GameColors.surfaceGlass,
              borderRadius: BorderRadius.circular(GameRadii.panel),
              border: Border.all(color: GameColors.violet),
              boxShadow: GameShadows.primaryGlow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.extension_rounded, size: 58, color: GameColors.accentBright),
                const SizedBox(height: 16),
                Text(
                  l10n.competitionUnavailableTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.competitionUnavailableBody(
                    GameIntegrationCatalog.installedGameCount,
                    GameIntegrationCatalog.requiredLaunchGames,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: GameColors.textSoft, height: 1.45),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: GameColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(GameRadii.pill),
                  ),
                  child: Text(
                    l10n.competitionNotReady,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: GameColors.rewardGoldBright, fontWeight: FontWeight.w800),
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

class _ResumeMatchPanel extends StatelessWidget {
  const _ResumeMatchPanel({
    required this.uid,
    required this.matchId,
    required this.wager,
    required this.matchRepository,
    required this.onResume,
  });

  final String uid;
  final String matchId;
  final int wager;
  final CompetitiveMatchFirestoreRepository matchRepository;
  final Future<void> Function() onResume;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<CompetitiveMatchSnapshot?>(
        stream: matchRepository.watchMatch(matchId),
        builder: (context, snapshot) {
          final match = snapshot.data;
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  color: GameColors.surfaceGlass,
                  borderRadius: BorderRadius.circular(GameRadii.panel),
                  border: Border.all(color: GameColors.rewardGold),
                  boxShadow: GameShadows.goldGlow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.restore_rounded, size: 54, color: GameColors.accentBright),
                    const SizedBox(height: 14),
                    Text(
                      l10n.matchInProgress,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      match == null ? l10n.restoringMatch : l10n.versusPlayer(match.opponentNameFor(uid)),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: GameColors.textSoft),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.goldPot(wager * 2),
                      style: const TextStyle(
                        color: GameColors.rewardGoldBright,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: match == null ? null : onResume,
                        child: Text(l10n.resumeMatch),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RecoveryError extends StatelessWidget {
  const _RecoveryError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 48),
              const SizedBox(height: 12),
              Text(l10n.unableRestoreCompetitive, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: Text(l10n.retry)),
            ],
          ),
        ),
      ),
    );
  }
}
