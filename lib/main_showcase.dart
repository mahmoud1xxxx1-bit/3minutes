import 'package:flutter/material.dart';
import 'package:game/core/theme/app_theme.dart';
import 'package:game/features/minigames/data/game_registry.dart';
import 'package:game/features/minigames/presentation/mini_game_copy.dart';

void main() {
  runApp(const MiniGameShowcaseApp());
}

class MiniGameShowcaseApp extends StatelessWidget {
  const MiniGameShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Games Collection',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const ShowcaseScreen(),
    );
  }
}

class ShowcaseScreen extends StatelessWidget {
  const ShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1420),
      appBar: AppBar(
        title: const Text('Mini Games Collection'),
        backgroundColor: const Color(0xFF13151C),
        elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: GameRegistry.games.length,
        itemBuilder: (context, index) {
          final game = GameRegistry.games[index];
          // Provide dummy BuildContext with Locale to MiniGameCopy
          final title = MiniGameCopy.fromContext(context).title(game.id);
          final category = game.category.name.toUpperCase();
          
          IconData icon;
          Color color;
          switch (game.category.name) {
            case 'precision':
              icon = Icons.psychology;
              color = Colors.redAccent;
              break;
            case 'memory':
              icon = Icons.visibility;
              color = Colors.purpleAccent;
              break;
            case 'logic':
              icon = Icons.vpn_key;
              color = Colors.amber;
              break;
            case 'reaction':
              icon = Icons.flash_on;
              color = Colors.blueAccent;
              break;
            default:
              icon = Icons.gamepad;
              color = Colors.greenAccent;
          }

          return Card(
            color: const Color(0xFF1A1F2B),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 48, color: color),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
