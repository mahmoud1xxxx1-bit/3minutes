import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/minigames/data/mini_game_content_policy.dart';

void main() {
  test('every registered mini-game has exactly one known engine', () {
    expect(MiniGameContentPolicy.validate, returnsNormally);
  });
}
