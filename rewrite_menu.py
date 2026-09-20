import re

with open("lib/test_all_games_1_10.dart", "r", encoding="utf-8") as f:
    content = f.read()

new_main_menu = """class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  Widget _buildGameImage(String id) {
    if (id == 'find_differences' || id == 'follow_the_cup' || id == 'key_escape') {
      return Image.asset(
        'assets/thumbnails/.jpg',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    
    String emoji = '🎮';
    List<Color> gradient = [Colors.purple, Colors.deepPurple];
    
    switch (id) {
      case 'level_devil':
        emoji = '😈';
        gradient = [const Color(0xFFFF5252), const Color(0xFFFF9800)];
        break;
      case 'mirror_control':
        emoji = '🪞🚗';
        gradient = [const Color(0xFF2196F3), const Color(0xFF00BCD4)];
        break;
      case 'mole_strike':
        emoji = '🐿️';
        gradient = [const Color(0xFF4CAF50), const Color(0xFF8BC34A)];
        break;
      case 'ninja_slice':
        emoji = '🥷🍉';
        gradient = [const Color(0xFF424242), const Color(0xFF212121)];
        break;
      case 'path_rush':
        emoji = '🐾';
        gradient = [const Color(0xFF795548), const Color(0xFFFFB74D)];
        break;
      case 'onet_connect':
        emoji = '🐼🐱';
        gradient = [const Color(0xFFFF4081), const Color(0xFFE040FB)];
        break;
      case 'traffic_loop':
        emoji = '🚗♾️';
        gradient = [const Color(0xFF607D8B), const Color(0xFF9E9E9E)];
        break;
    }
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 54),
        ),
      ),
    );
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
}"""

content = re.sub(r'class MainMenu extends StatelessWidget \{.*?\nclass GameScreen', new_main_menu + '\nclass GameScreen', content, flags=re.DOTALL)

with open("lib/test_all_games_1_10.dart", "w", encoding="utf-8") as f:
    f.write(content)
