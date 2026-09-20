import 'package:flutter/material.dart';
import 'features/minigames/domain/mini_game_contract.dart';
import 'features/minigames/presentation/mini_game_host.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AllGamesTester(),
  ));
}

class AllGamesTester extends StatefulWidget {
  const AllGamesTester({super.key});
  @override
  State<AllGamesTester> createState() => _AllGamesTesterState();
}

class _AllGamesTesterState extends State<AllGamesTester> {
  final List<String> gameIds = [
    'mole_strike',
    'follow_the_cup',
    'find_differences',
    'mirror_control',
    'path_rush',
    'traffic_loop',
    'level_devil',
    'ninja_slice',
    'key_escape',
    'onet_connect',
  ];
  int currentIndex = 9;

  void _nextGame() {
    setState(() {
      currentIndex = (currentIndex + 1) % gameIds.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentIndex >= gameIds.length) return const Scaffold(body: Center(child: Text('Done')));
    
    final currentId = gameIds[currentIndex];
    
    return Scaffold(
      body: Stack(
        children: [
          MiniGameHost(
            game: MiniGameDescriptor(id: currentId, title: currentId, category: MiniGameCategory.reaction),
            config: const MiniGameConfig(seed: 12345, difficulty: 1),
            onComplete: (res) {
              Future.delayed(const Duration(milliseconds: 1500), _nextGame);
            },
          ),
          Positioned(
            top: 20, left: 20,
            child: Material(
              color: Colors.black54,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Testing: $currentId (V2.0)', style: const TextStyle(color: Colors.white)),
              ),
            ),
          ),
          Positioned(
            top: 20, right: 20,
            child: ElevatedButton(
              onPressed: _nextGame,
              child: const Text('Skip / Next'),
            ),
          )
        ],
      ),
    );
  }
}





