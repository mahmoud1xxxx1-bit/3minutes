import 'competitive_match_rules.dart';

enum CompetitiveMatchState {
  searching,
  opponentFound,
  selectingGames,
  waitingReady,
  countdown,
  playing,
  settling,
  finished,
  cancelled,
}

class CompetitivePlayerSlot {
  const CompetitivePlayerSlot({
    required this.uid,
    required this.displayName,
    required this.selectedGameIds,
    required this.ready,
  });

  final String uid;
  final String displayName;
  final List<String> selectedGameIds;
  final bool ready;
}

class CompetitiveMatch {
  const CompetitiveMatch({
    required this.id,
    required this.wager,
    required this.state,
    required this.players,
    required this.gameOrder,
    required this.createdAt,
    this.startedAt,
    this.deadline,
  });

  final String id;
  final int wager;
  final CompetitiveMatchState state;
  final List<CompetitivePlayerSlot> players;
  final List<String> gameOrder;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? deadline;

  int get pot => CompetitiveMatchRules.potFor(wager);
  bool get bothReady => players.length == 2 && players.every((p) => p.ready);
  bool get selectionComplete =>
      players.length == 2 &&
      players.every((p) => p.selectedGameIds.length == CompetitiveMatchRules.picksPerPlayer) &&
      gameOrder.length == CompetitiveMatchRules.gamesPerMatch;
}
