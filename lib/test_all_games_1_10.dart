import 'package:flutter/material.dart';
import 'thumbnails.dart';
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
      title: 'Minigames 1-10',
      theme: ThemeData.dark(),
      home: const MainMenu(),
    );
  }
}

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  Widget _buildGameImage(String id) {
    return getGameThumbnail(id);
  }

  @override
  Widget build(BuildContext context) {
    final List<MiniGameDescriptor> games = [
      const MiniGameDescriptor(id: 'find_differences', title: 'Find Differences', category: MiniGameCategory.precision),
      const MiniGameDescriptor(id: 'follow_the_cup', title: 'Follow The Cup', category: MiniGameCategory.memory),
      const MiniGameDescriptor(id: 'key_escape', title: 'Key Escape', category: MiniGameCategory.logic),
      const MiniGameDescriptor(id: 'level_devil', title: 'Level Devil', category: MiniGameCategory.reaction),
      const MiniGameDescriptor(id: 'mirror_control', title: 'Mirror Control', category: MiniGameCategory.precision),
      const MiniGameDescriptor(id: 'mole_strike', title: 'Mole Strike', category: MiniGameCategory.reaction),
      const MiniGameDescriptor(id: 'ninja_slice', title: 'Ninja Slice', category: MiniGameCategory.reaction),
      const MiniGameDescriptor(id: 'path_rush', title: 'Path Rush', category: MiniGameCategory.reaction),
      const MiniGameDescriptor(id: 'onet_connect', title: 'Onet Connect', category: MiniGameCategory.logic),
      const MiniGameDescriptor(id: 'traffic_loop', title: 'Traffic Loop', category: MiniGameCategory.logic),
        const MiniGameDescriptor(id: 'hidden_pigeon', title: 'Hidden Pigeon', category: MiniGameCategory.precision),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A24),
      appBar: AppBar(
        title: const Text('Mini Games Collection', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = constraints.maxWidth > 800 ? 4 : (constraints.maxWidth > 500 ? 3 : 2);
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.85,
            ),
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameScreen(game: game),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A36),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _buildGameImage(game.id),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              game.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              game.category.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.6),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
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
            config: MiniGameConfig(seed: DateTime.now().millisecondsSinceEpoch, difficulty: 1),
            onComplete: (result) {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Game Over'),
                  content: Text('Score: ${result.score}\\nMistakes: ${result.mistakes}\\nDuration: ${result.duration.inSeconds}s'),
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
