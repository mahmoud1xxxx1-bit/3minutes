import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/match/domain/match_game_selection.dart';

void main() {
  test('locks exactly two different games from each player into four unique games', () {
    const selection = MatchGameSelection(
      playerAId: 'A',
      playerBId: 'B',
      playerAGameIds: ['g1', 'g2'],
      playerBGameIds: ['g3', 'g4'],
    );

    expect(selection.validateAndLock(), ['g1', 'g2', 'g3', 'g4']);
  });

  test('rejects duplicate game across players', () {
    const selection = MatchGameSelection(
      playerAId: 'A',
      playerBId: 'B',
      playerAGameIds: ['g1', 'g2'],
      playerBGameIds: ['g2', 'g4'],
    );

    expect(selection.validateAndLock, throwsStateError);
  });

  test('rejects a player selecting fewer or more than two games', () {
    const selection = MatchGameSelection(
      playerAId: 'A',
      playerBId: 'B',
      playerAGameIds: ['g1'],
      playerBGameIds: ['g3', 'g4'],
    );

    expect(selection.validateAndLock, throwsStateError);
  });

  test('rejects self match identity', () {
    const selection = MatchGameSelection(
      playerAId: 'A',
      playerBId: 'A',
      playerAGameIds: ['g1', 'g2'],
      playerBGameIds: ['g3', 'g4'],
    );

    expect(selection.validateAndLock, throwsStateError);
  });
}
