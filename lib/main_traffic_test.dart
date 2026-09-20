import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/minigames/domain/mini_game_contract.dart';
import 'features/minigames/presentation/traffic_loop/traffic_loop_game.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: [
      Locale('ar'),
      Locale('en'),
    ],
    locale: Locale('ar'), // Force Arabic for the user to see!
    home: TrafficTestMenu(),
  ));
}

class TrafficTestMenu extends StatelessWidget {
  const TrafficTestMenu({super.key});

  void _startGame(BuildContext context, int trackId) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: TrafficLoopGame(
        config: MiniGameConfig(
          difficulty: 1,
          seed: 12345 + trackId,
        ),
        onComplete: (r) {
          Navigator.pop(context);
        },
      ),
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('اختبار مسارات المرور (b1 - b20)', style: TextStyle(color: Colors.white, fontSize: 24)),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 1; i <= 5; i++) ...[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C202B),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)
                  ),
                  onPressed: () => _startGame(context, i), 
                  child: Text('b$i', style: const TextStyle(color: Colors.white, fontSize: 20)),
                ),
                if (i < 5) const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 6; i <= 10; i++) ...[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C202B),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)
                  ),
                  onPressed: () => _startGame(context, i), 
                  child: Text('b$i', style: const TextStyle(color: Colors.white, fontSize: 20)),
                ),
                if (i < 10) const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 11; i <= 15; i++) ...[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C202B),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)
                  ),
                  onPressed: () => _startGame(context, i), 
                  child: Text('b$i', style: const TextStyle(color: Colors.white, fontSize: 20)),
                ),
                if (i < 15) const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 16; i <= 20; i++) ...[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C202B),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)
                  ),
                  onPressed: () => _startGame(context, i), 
                  child: Text('b$i', style: const TextStyle(color: Colors.white, fontSize: 20)),
                ),
                if (i < 20) const SizedBox(width: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
