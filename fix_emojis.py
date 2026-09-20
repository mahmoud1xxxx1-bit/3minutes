code = open('lib/features/minigames/presentation/ninja_slice/ninja_slice_game.dart', 'r', encoding='utf-8').read()
code = code.replace('ðŸ Ž', '🍎')
code = code.replace('ðŸ ‰', '🍉')
code = code.replace('ðŸ Œ', '🍌')
code = code.replace('ðŸ¥¥', '🥥')
code = code.replace('ðŸ§Š', '🧊')
code = code.replace('ðŸŒŸ', '🌟')

with open('lib/features/minigames/presentation/ninja_slice/ninja_slice_game.dart', 'w', encoding='utf-8') as f:
    f.write(code)
