import re

with open('lib/test_4_games.dart', 'r', encoding='utf-8') as f:
    code = f.read()

code = code.replace("child: Text('\')", "child: Text('\')")
code = code.replace("subtitle: Text('Category: \')", "subtitle: Text('Category: \')")
code = code.replace("content: Text('Score: \\\nMistakes: \\\nDuration: \s'),", "content: Text('Score: \\\nMistakes: \\\nDuration: \s'),")

with open('lib/test_4_games.dart', 'w', encoding='utf-8') as f:
    f.write(code)
