import re

with open("lib/test_all_games_1_10.dart", "r", encoding="utf-8") as f:
    content = f.read()

new_build_game_image = """
  Widget _buildGameImage(String id) {
    IconData iconData = Icons.games;
    List<Color> gradient = [Colors.purple, Colors.deepPurple];
    
    switch (id) {
      case 'find_differences':
        iconData = Icons.search;
        gradient = [const Color(0xFF2196F3), const Color(0xFF0D47A1)];
        break;
      case 'follow_the_cup':
        iconData = Icons.local_cafe;
        gradient = [const Color(0xFFFFC107), const Color(0xFFFF8F00)];
        break;
      case 'key_escape':
        iconData = Icons.vpn_key;
        gradient = [const Color(0xFF9C27B0), const Color(0xFF4A148C)];
        break;
      case 'level_devil':
        iconData = Icons.directions_run;
        gradient = [const Color(0xFFFF5252), const Color(0xFFD32F2F)];
        break;
      case 'mirror_control':
        iconData = Icons.sync_alt;
        gradient = [const Color(0xFF00BCD4), const Color(0xFF006064)];
        break;
      case 'mole_strike':
        iconData = Icons.pest_control;
        gradient = [const Color(0xFF8BC34A), const Color(0xFF33691E)];
        break;
      case 'ninja_slice':
        iconData = Icons.sports_martial_arts;
        gradient = [const Color(0xFF9E9E9E), const Color(0xFF212121)];
        break;
      case 'path_rush':
        iconData = Icons.timeline;
        gradient = [const Color(0xFFFF9800), const Color(0xFFE65100)];
        break;
      case 'onet_connect':
        iconData = Icons.extension;
        gradient = [const Color(0xFFE91E63), const Color(0xFF880E4F)];
        break;
      case 'traffic_loop':
        iconData = Icons.all_inclusive;
        gradient = [const Color(0xFF607D8B), const Color(0xFF263238)];
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
        child: Icon(
          iconData,
          size: 72,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }
"""

content = re.sub(r'Widget _buildGameImage\(String id\) \{.*?\n  \}\n\n  @override', new_build_game_image.strip() + '\n\n  @override', content, flags=re.DOTALL)

with open("lib/test_all_games_1_10.dart", "w", encoding="utf-8") as f:
    f.write(content)
