code = '''import 'package:flutter/material.dart';
import 'features/minigames/presentation/onet_connect/onet_connect_game.dart';
import 'features/minigames/domain/mini_game_contract.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: OnetGameWrapper(),
  ));
}

class OnetGameWrapper extends StatelessWidget {
  const OnetGameWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D5D30),
      body: OnetConnectGame(
        config: const MiniGameConfig(
          gameId: 'onet_test',
          type: MiniGameType.onetConnect,
          seed: 42,
          difficulty: 1,
          timeLimitSeconds: 300,
          parTimeSeconds: 150,
          starsThresholds: [300, 200, 100],
          rewards: {},
        ),
        onComplete: (MiniGameResult result) {
          debugPrint('Game completed');
        },
      ),
    );
  }
}
'''
with open('lib/test_animals.dart', 'w', encoding='utf-8') as f:
    f.write(code)
