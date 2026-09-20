import os
import shutil
import json

src = r"C:\Users\loved\3minutes"
dst = r"C:\Users\loved\3minutes\games_5_10_export"

if os.path.exists(dst):
    shutil.rmtree(dst)

# We will only copy what is needed to make a fully runnable flutter project containing games 5-10
# This includes pubspec, lib, assets, web, test, android, ios (well, flutter create can recreate them, but let's copy lib, web, pubspec, assets)

def copy_tree(s, d):
    if not os.path.exists(d):
        os.makedirs(d)
    for item in os.listdir(s):
        if item in ['.git', '.dart_tool', 'build', '.idea', 'games_5_10_export', 'first_4_games_web.zip', 'first_4_games_source.zip', 'games_5_8_web.zip', 'games_5_8_source.zip', 'games_9_10_web.zip', 'games_9_10_source.zip', 'scratch']:
            continue
        s_item = os.path.join(s, item)
        d_item = os.path.join(d, item)
        if os.path.isdir(s_item):
            copy_tree(s_item, d_item)
        else:
            shutil.copy2(s_item, d_item)

copy_tree(src, dst)

# Now delete the unrequested games
games_to_delete = ['find_differences', 'follow_the_cup', 'key_escape', 'level_devil']
for g in games_to_delete:
    p = os.path.join(dst, 'lib', 'features', 'minigames', 'presentation', g)
    if os.path.exists(p):
        shutil.rmtree(p)

# We should make a main file that runs ONLY these 6 games to prove they are buildable and playable.
main_code = '''import 'package:flutter/material.dart';
import 'features/minigames/domain/mini_game_contract.dart';
import 'features/minigames/presentation/mini_game_host.dart';

void main() {
  runApp(const Games5To10App());
}

class Games5To10App extends StatelessWidget {
  const Games5To10App({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Minigames 5-10',
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
      const MiniGameDescriptor(id: 'mirror_control', title: 'Mirror Control', category: MiniGameCategory.precision),
      const MiniGameDescriptor(id: 'mole_strike', title: 'Mole Strike', category: MiniGameCategory.reaction),
      const MiniGameDescriptor(id: 'ninja_slice', title: 'Ninja Slice', category: MiniGameCategory.reaction),
      const MiniGameDescriptor(id: 'onet_connect', title: 'Onet Connect', category: MiniGameCategory.logic),
      const MiniGameDescriptor(id: 'path_rush', title: 'Path Rush', category: MiniGameCategory.reaction),
      const MiniGameDescriptor(id: 'traffic_loop', title: 'Traffic Loop', category: MiniGameCategory.logic),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Games 5 to 10 Launcher')),
      body: ListView.builder(
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.tealAccent,
                child: Text('\', style: const TextStyle(color: Colors.black)),
              ),
              title: Text(game.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              subtitle: Text('Category: \'),
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
                  content: Text('Score: \\\nMistakes: \\\nDuration: \s'),
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
'''
with open(os.path.join(dst, 'lib', 'main.dart'), 'w', encoding='utf-8') as f:
    f.write(main_code)

print("Export ready")
