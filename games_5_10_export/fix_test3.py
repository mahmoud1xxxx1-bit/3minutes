code = '''import 'package:flutter/material.dart';
import 'features/minigames/presentation/onet_connect/onet_connect_game.dart';
import 'core/config/app_config.dart';

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
        config: MinigameConfig(
          gameId: 'onet_test',
          type: MinigameType.onetConnect,
          seed: 42,
          difficulty: 1,
          timeLimitSeconds: 300,
          parTimeSeconds: 150,
          starsThresholds: [300, 200, 100],
          rewards: {},
        ),
        onComplete: (int stars, int score, Duration timeTaken) {
          print('Game completed! Stars: \, Score: \');
        },
      ),
    );
  }
}
'''
with open('lib/test_animals.dart', 'w', encoding='utf-8') as f:
    f.write(code)
