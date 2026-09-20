import 'package:flutter/material.dart';
import 'features/minigames/domain/mini_game_contract.dart';
import 'features/minigames/presentation/mini_game_host.dart';

void main() {
  runApp(const Games9To10App());
}

class Games9To10App extends StatelessWidget {
  const Games9To10App({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Minigames 9-10',
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
      const MiniGameDescriptor(id: 'path_rush', title: 'Path Rush', category: MiniGameCategory.reaction),
      const MiniGameDescriptor(id: 'traffic_loop', title: 'Traffic Loop', category: MiniGameCategory.logic),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Games 9 & 10 Launcher')),
      body: ListView.builder(
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orangeAccent,
                child: Text('${index + 9}'),
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
