import re

with open('lib/features/minigames/presentation/key_escape/key_escape_game.dart', 'r', encoding='utf-8') as f:
    code = f.read()

old = '''                      ),
                    ),
                  );
                },
              ),
            ],
          ),'''

new = '''                      ),
                    ),
                  );
                },
              ),
              ),
              ),
            ],
          ),'''

code = code.replace(old, new)

with open('lib/features/minigames/presentation/key_escape/key_escape_game.dart', 'w', encoding='utf-8') as f:
    f.write(code)
