import 'package:flutter/material.dart';
import 'features/minigames/presentation/level_devil/level_devil_game.dart';

void main() {
  runApp(const LevelDevilTestApp());
}

class LevelDevilTestApp extends StatelessWidget {
  const LevelDevilTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Level Devil Test',
      home: LevelSelector(),
    );
  }
}

class LevelSelector extends StatefulWidget {
  const LevelSelector({super.key});

  @override
  State<LevelSelector> createState() => _LevelSelectorState();
}

class _LevelSelectorState extends State<LevelSelector> {
  int? _selectedLevel;

  @override
  Widget build(BuildContext context) {
    if (_selectedLevel != null) {
      return Stack(
        children: [
          LevelDevilGame(levelId: _selectedLevel!),
          Positioned(
            top: 20,
            left: 20,
            child: FloatingActionButton(
              child: const Icon(Icons.arrow_back),
              onPressed: () => setState(() => _selectedLevel = null),
            ),
          )
        ],
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1C202B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Level Devil Test (1-5)', style: TextStyle(color: Colors.white, fontSize: 32)),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 1; i <= 5; i++) ...[
                  ElevatedButton(
                    onPressed: () => setState(() => _selectedLevel = i),
                    child: Text('Level $i'),
                  ),
                  const SizedBox(width: 10),
                ]
              ],
            )
          ],
        ),
      ),
    );
  }
}
