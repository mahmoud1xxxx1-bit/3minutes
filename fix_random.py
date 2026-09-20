import re

with open("lib/thumbnails.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Fix Random to math.Random
content = content.replace("final random = Random(42);", "final random = math.Random(42);")

with open("lib/thumbnails.dart", "w", encoding="utf-8") as f:
    f.write(content)
