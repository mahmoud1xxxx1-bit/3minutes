p = r'C:\Users\loved\3minutes\lib\features\minigames\presentation\find_differences\find_differences_game.dart'
with open(p, 'r', encoding='utf-8') as f: lines = f.readlines()
for i, line in enumerate(lines):
    if '_FindPill(label:' in line:
        if '5' in line:
            lines[i] = "            _FindPill(label: '\: \/5'),\n"
        else:
            lines[i] = "            _FindPill(label: '\: \'),\n"
with open(p, 'w', encoding='utf-8') as f: f.writelines(lines)
