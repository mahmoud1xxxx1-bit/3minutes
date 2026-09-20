import re

with open("lib/test_all_games_1_10.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Add import if not present
if "import 'thumbnails.dart';" not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'thumbnails.dart';")

new_build_game_image = """
  Widget _buildGameImage(String id) {
    return getGameThumbnail(id);
  }
"""

content = re.sub(r'Widget _buildGameImage\(String id\) \{.*?\n  \}\n\n  @override', new_build_game_image.strip() + '\n\n  @override', content, flags=re.DOTALL)

with open("lib/test_all_games_1_10.dart", "w", encoding="utf-8") as f:
    f.write(content)
