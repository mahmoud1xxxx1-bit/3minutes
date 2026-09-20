import re

with open("lib/thumbnails.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Fix the math import and type issues
content = content.replace("dart_math.Random(42)", "Random(42)")
content = content.replace("100 + random.nextInt(155),", "(100 + random.nextInt(155)).toInt(),")
content = content.replace("10 + random.nextDouble() * 30,", "(10 + random.nextDouble() * 30).toDouble(),")

# Ensure dart:math is imported as just import 'dart:math';
content = content.replace("import 'dart:math' as dart_math;", "import 'dart:math';")

with open("lib/thumbnails.dart", "w", encoding="utf-8") as f:
    f.write(content)
