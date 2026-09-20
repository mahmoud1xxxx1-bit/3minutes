import re

with open('lib/features/minigames/presentation/mole_strike/mole_strike_game.dart', 'r', encoding='utf-8') as f:
    code = f.read()

old = '''                  itemBuilder: (context, index) {
                    return MoleSlot(
                      key: _slotKeys[index],
                      onHit: (res) {
                        RenderBox box = _slotKeys[index].currentContext!.findRenderObject() as RenderBox;
                        Offset pos = box.localToGlobal(Offset(box.size.width / 2, box.size.height / 2));
                        _handleHit(index, res, pos);
                      },
                      getCombo: () => _combo,
                    );
                  },
                ),
              ),
            ),
          ),
          
          for (var m in _mallets)'''

new = '''                  itemBuilder: (context, index) {
                    return MoleSlot(
                      key: _slotKeys[index],
                      onHit: (res) {
                        RenderBox box = _slotKeys[index].currentContext!.findRenderObject() as RenderBox;
                        Offset pos = box.localToGlobal(Offset(box.size.width / 2, box.size.height / 2));
                        _handleHit(index, res, pos);
                      },
                      getCombo: () => _combo,
                    );
                  },
                ),
              );
            },
          ),
          ),
          ),
          
          for (var m in _mallets)'''

code = code.replace(old, new)

with open('lib/features/minigames/presentation/mole_strike/mole_strike_game.dart', 'w', encoding='utf-8') as f:
    f.write(code)
