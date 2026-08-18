import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../../progression/data/progression_backend.dart';
import '../../progression/presentation/progression_copy.dart';
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
    final copy = ProgressionCopy.of(context);
    return Stack(
      children: [
        SeasonScreen(competitionBackend: competitionBackend),
        PositionedDirectional(
          end: GameSpacing.md,
          bottom: GameSpacing.md,
          child: FloatingActionButton.extended(
            heroTag: 'season-progression',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ProgressionScreen(uid: uid, backend: progressionBackend),
                ),
              );
            },
            icon: const Icon(Icons.flag_circle_rounded),
            label: Text(copy.missions),
          ),
        ),
      ],
    );
  }
}
