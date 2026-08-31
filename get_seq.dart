import 'package:game/features/minigames/data/game_registry.dart';
void main() {
  final sequence = GameRegistry.sequence(seed: 20260818, count: 8);
  print(sequence.map((game) => game.id).toList());
}
