import os

pubspec_path = r"c:\Users\loved\3minutes\pubspec.yaml"
with open(pubspec_path, "r", encoding="utf-8") as f:
    pubspec = f.read()

assets_to_add = [
    "assets/hidden_pigeon/",
    "assets/mole_strike/",
    "assets/find_differences/",
    "assets/mirror_control/",
    "assets/onet_connect/"
]

# Find where assets are defined
if "assets:" in pubspec:
    for asset in assets_to_add:
        if asset not in pubspec:
            pubspec = pubspec.replace("  assets:\n", f"  assets:\n    - {asset}\n")

with open(pubspec_path, "w", encoding="utf-8") as f:
    f.write(pubspec)
print("pubspec updated")
