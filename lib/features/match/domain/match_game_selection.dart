class MatchGameSelection {
  const MatchGameSelection({
    required this.playerAId,
    required this.playerBId,
    required this.playerAGameIds,
    required this.playerBGameIds,
  });

  static const int picksPerPlayer = 2;
  static const int totalGames = 4;

  final String playerAId;
  final String playerBId;
  final List<String> playerAGameIds;
  final List<String> playerBGameIds;

  List<String> validateAndLock() {
    if (playerAId.isEmpty || playerBId.isEmpty || playerAId == playerBId) {
      throw StateError('A match requires two different players.');
    }
    _validatePlayerPicks(playerAGameIds, 'A');
    _validatePlayerPicks(playerBGameIds, 'B');

    final combined = <String>[...playerAGameIds, ...playerBGameIds];
    if (combined.toSet().length != totalGames) {
      throw StateError(
        'Competitive selection must lock four different games; duplicate picks are not allowed.',
      );
    }
    return List<String>.unmodifiable(combined);
  }

  static void _validatePlayerPicks(List<String> ids, String side) {
    if (ids.length != picksPerPlayer) {
      throw StateError('Player $side must choose exactly $picksPerPlayer games.');
    }
    if (ids.any((id) => id.trim().isEmpty)) {
      throw StateError('Player $side has an empty game id.');
    }
    if (ids.toSet().length != ids.length) {
      throw StateError('Player $side cannot choose the same game twice.');
    }
  }
}
