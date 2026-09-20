import re

with open("pubspec.yaml", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace(
    "  assets:\n",
    "  assets:\n    - assets/hidden_pigeon/\n"
)

with open("pubspec.yaml", "w", encoding="utf-8") as f:
    f.write(content)
