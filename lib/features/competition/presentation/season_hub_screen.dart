import 'dart:async';

import 'package:flutter/material.dart';

import '../../progression/data/progression_backend.dart';
import '../../progression/presentation/arena_progression_screen.dart';
import '../../progression/presentation/premium_season_pass_screen.dart';
import '../data/competition_backend.dart';
import 'arena_season_hub.dart';
import 'season_screen.dart';

class SeasonHubScreen extends StatelessWidget {
  const SeasonHubScreen({
    super.key,
    required this.uid,
    required this.competitionBackend,
    required this.progressionBackend,
  });

  final String uid;
  final CompetitionBackend competitionBackend;
  final ProgressionBackend progressionBackend;

  Future<String> _resolveSeasonId() async {
    try {
      final season = await competitionBackend
          .watchCurrentSeason()
          .firstWhere((value) => value != null)
          .timeout(const Duration(seconds: 2));
      return season?.id ?? 'preview_current';
    } catch (_) {
      return 'preview_current';
    }
  }

  Future<void> _openMissions(BuildContext context) async {
    final seasonId = await _resolveSeasonId();
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ArenaProgressionScreen(
          uid: uid,
          seasonId: seasonId,
          backend: progressionBackend,
        ),
      ),
    );
  }

  Future<void> _openPremium(BuildContext context) async {
    final seasonId = await _resolveSeasonId();
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PremiumSeasonPassScreen(
          uid: uid,
          seasonId: seasonId,
          backend: progressionBackend,
        ),
      ),
    );
  }

  void _openDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SeasonScreen(
          uid: uid,
          competitionBackend: competitionBackend,
          onOpenMissions: () => unawaited(_openMissions(context)),
          onOpenPremium: () => unawaited(_openPremium(context)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ArenaSeasonHub(
      uid: uid,
      competitionBackend: competitionBackend,
      onOpenMissions: () => unawaited(_openMissions(context)),
      onOpenPremium: () => unawaited(_openPremium(context)),
      onOpenDetails: () => _openDetails(context),
    );
  }
}
