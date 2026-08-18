import 'multiplayer_match.dart';

class MultiplayerPlacement {
  const MultiplayerPlacement({
    required this.uid,
    required this.position,
  });

  final String uid;
  final int position;
}

class MultiplayerResultPolicy {
  const MultiplayerResultPolicy._();

  static List<MultiplayerPlacement> rank(List<MatchParticipant> participants) {
    final ordered = [...participants]
      ..sort((a, b) {
        final progress = b.progress.completedGames.compareTo(a.progress.completedGames);
        if (progress != 0) return progress;

        final score = b.progress.totalScore.compareTo(a.progress.totalScore);
        if (score != 0) return score;

        final accuracy = b.progress.averageAccuracy.compareTo(a.progress.averageAccuracy);
        if (accuracy != 0) return accuracy;

        final mistakes = a.progress.mistakes.compareTo(b.progress.mistakes);
        if (mistakes != 0) return mistakes;

        final elapsed = a.progress.elapsedMs.compareTo(b.progress.elapsedMs);
        if (elapsed != 0) return elapsed;

        return a.uid.compareTo(b.uid);
      });

    return [
      for (var i = 0; i < ordered.length; i++)
        MultiplayerPlacement(uid: ordered[i].uid, position: i + 1),
    ];
  }
}
