with open('lib/features/minigames/presentation/onet_connect/onet_connect_game.dart', 'r', encoding='utf-8') as f:
    code = f.read()

code = code.replace('double maxW = constraints.maxWidth - 200;', 'double maxW = math.max(10.0, constraints.maxWidth - 140);')
code = code.replace('double maxH = constraints.maxHeight - 80;', 'double maxH = math.max(10.0, constraints.maxHeight - 40);')
code = code.replace('_currentTileWidth = math.min((maxW - padding*2) / _cols, (maxH - padding*2) / (_rows * 1.25));', '_currentTileWidth = math.min(math.max(10.0, maxW - padding*2) / _cols, math.max(10.0, maxH - padding*2) / (_rows * 1.25));')

with open('lib/features/minigames/presentation/onet_connect/onet_connect_game.dart', 'w', encoding='utf-8') as f:
    f.write(code)
