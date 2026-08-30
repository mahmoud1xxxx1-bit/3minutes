import re

host_path = r"c:\Users\loved\3minutes\lib\features\minigames\presentation\mini_game_host.dart"
with open(host_path, "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("mirror_control_game.dart", "mirror_control_minigame.dart")
content = content.replace("MirrorControlGame(", "MirrorControlMinigame(")

with open(host_path, "w", encoding="utf-8") as f:
    f.write(content)

print("Mirror control fixed in host")
