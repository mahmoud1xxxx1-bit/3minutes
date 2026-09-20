with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "rb") as f:
    content = f.read()

content = content.replace(b'\xef\xbb\xbf', b'')
text = content.decode('utf-8')

# Ensure rendering import is at the top
if "import 'package:flutter/rendering.dart';" not in text:
    text = "import 'package:flutter/rendering.dart';\n" + text
elif text.find("import 'package:flutter/rendering.dart';") > 200:
    text = text.replace("import 'package:flutter/rendering.dart';", "")
    text = "import 'package:flutter/rendering.dart';\n" + text

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "wb") as f:
    f.write(text.encode('utf-8'))
