import re

pubspec_path = "pubspec.yaml"
with open(pubspec_path, "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("    - assets/onet_connect/\n", "")
content = content.replace("    - assets/mole_strike/\n", "")
content = content.replace("    - assets/find_differences/\n", "")

with open(pubspec_path, "w", encoding="utf-8") as f:
    f.write(content)

print("pubspec fixed")
