import 'package:flutter/material.dart';
import 'features/minigames/domain/mini_game_contract.dart';
import 'features/minigames/presentation/mini_game_host.dart';

void main() {
  runApp(const AllGamesApp());
}

class AllGamesApp extends StatelessWidget {
  const AllGamesApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Minigame Tester',
      theme: ThemeData.dark(),
      home: const MainMenu(),
    );
  }
}

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final List<MiniGameDescriptor> games = [
      const MiniGameDescriptor(id: 'find_differences', title: 'Find Differences', category: MiniGameCategory.logic),
      const MiniGameDescriptor(id: 'follow_the_cup', title: 'Follow The Cup', category: MiniGameCategory.memory),
      const MiniGameDescriptor(id: 'key_escape', title: 'Key Escape', category: MiniGameCategory.logic),
      const MiniGameDescriptor(id: 'level_devil', title: 'Level Devil', category: MiniGameCategory.reaction),
      const MiniGameDescriptor(id: 'mirror_control', title: 'Mirror Control', category: MiniGameCategory.precision),
      const MiniGameDescriptor(id: 'mole_strike', title: 'Mole Strike', category: MiniGameCategory.reaction),
      const MiniGameDescriptor(id: 'ninja_slice', title: 'Ninja Slice', category: MiniGameCategory.reaction),
      const MiniGameDescriptor(id: 'onet_connect', title: 'Onet Connect', category: MiniGameCategory.logic),
      const MiniGameDescriptor(id: 'path_rush', title: 'Path Rush', category: MiniGameCategory.precision),
      const MiniGameDescriptor(id: 'traffic_loop', title: 'Traffic Loop', category: MiniGameCategory.reaction),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('All 10 Minigames Launcher')),
      body: ListView.builder(
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Text('${index + 1}'),
              ),
              title: Text(game.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              subtitle: Text('Category: ${game.category.name}'),
              trailing: const Icon(Icons.play_arrow_rounded, size: 30, color: Colors.green),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameScreen(game: game),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class GameScreen extends StatelessWidget {
  final MiniGameDescriptor game;

  const GameScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MiniGameHost(
            game: game,
            config: const MiniGameConfig(seed: 1234, difficulty: 1),
            onComplete: (result) {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Game Over'),
                  content: Text('Score: ${result.score}\nMistakes: ${result.mistakes}\nDuration: ${result.duration.inSeconds}s'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      child: const Text('Back to Menu'),
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            top: 20,
            left: 20,
            child: SafeArea(
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.black54,
                child: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
