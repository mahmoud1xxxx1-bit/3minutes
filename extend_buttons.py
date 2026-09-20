import re

with open("lib/test_hidden_pigeon_x.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("itemCount: 10,", "itemCount: 30,")
content = content.replace("Hidden Pigeon - X Packs (X1 to X10)", "Hidden Pigeon - X Packs (X1 to X30)")
content = content.replace("Hidden Pigeon X1-X10 Tester", "Hidden Pigeon X1-X30 Tester")

with open("lib/test_hidden_pigeon_x.dart", "w", encoding="utf-8") as f:
    f.write(content)
