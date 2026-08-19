import 'package:flutter/material.dart';

import '../../progression/data/progression_backend.dart';
import '../../progression/presentation/progression_screen.dart';
import '../data/competition_backend.dart';
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

  @override
  Widget build(BuildContext context) {
    void openProgression() {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ProgressionScreen(uid: uid, backend: progressionBackend),
        ),
      );
    }

    return SeasonScreen(
      uid: uid,
      competitionBackend: competitionBackend,
      onOpenMissions: openProgression,
    );
  }
}
