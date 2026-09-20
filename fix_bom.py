with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "rb") as f:
    content = f.read()

# Remove BOM
content = content.replace(b'\xef\xbb\xbf', b'')
# Remove duplicate imports if any
text = content.decode('utf-8')
text = text.replace("import 'package:flutter/rendering.dart';\nimport 'package:flutter/rendering.dart';", "import 'package:flutter/rendering.dart';")

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "wb") as f:
    f.write(text.encode('utf-8'))
