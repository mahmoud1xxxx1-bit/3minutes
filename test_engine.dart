// ignore_for_file: avoid_print
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'lib/features/minigames/presentation/traffic_loop/advanced_traffic_engine.dart';

void main() {
  test('Engine test', () {
    final engine = FlawlessTrafficEngine(goal: 10, seed: 123, trackId: 1, round: 1);
    
    // Tap to insert car
    engine.tap();
    
    for (int i = 0; i < 500; i++) {
      engine.update(0.016); // 60fps
    }
    
    print('Correct: ${engine.correct}, Mistakes: ${engine.mistakes}');
  });
}

