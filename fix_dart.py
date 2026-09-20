with open('lib/test_all_games_1_10.dart', 'r', encoding='utf-8') as f:
    code = f.read()

code = code.replace(r\"Text('\\\', style:\", \"Text('', style:\")
code = code.replace(r\"Text('Category: \\\'),\", \"Text('Category: '),\")
code = code.replace(r\"Text('Score: \\\n\", r\"Text('Score: \\nMistakes: \\nDuration: s'), //\")
code = code.replace(\"Mistakes: \\\nDuration: \\\s')\", \"\")

with open('lib/test_all_games_1_10.dart', 'w', encoding='utf-8') as f:
    f.write(code)
