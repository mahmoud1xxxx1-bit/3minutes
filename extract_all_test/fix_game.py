import re

with open('lib/features/minigames/presentation/onet_connect/onet_connect_game.dart', 'r', encoding='utf-8') as f:
    code = f.read()

old_build_tile = '''  Widget _buildTile(int r, int c, double tileSize) {
    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: CustomPaint(
              painter: _TilePainter(selected: _selected?.r == r && _selected?.c == c),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Image.asset(
              'assets/images/onet_clean/animal_.png',
              width: tileSize * 0.6,
              height: tileSize * 0.6,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ],
    );
  }'''

new_build_tile = '''  Widget _buildTile(int r, int c, double tileSize) {
    bool isSelected = _selected?.r == r && _selected?.c == c;
    Widget img = Image.asset(
      'assets/images/onet_full/tile_.png',
      width: tileSize,
      height: tileSize * (80.0 / 60.5),
      fit: BoxFit.fill,
      filterQuality: FilterQuality.high,
    );
    
    if (isSelected) {
      img = ColorFiltered(
        colorFilter: const ColorFilter.mode(
          Color(0x88FFF000), 
          BlendMode.srcATop,
        ),
        child: img,
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: OverflowBox(
        maxHeight: tileSize * (80.0 / 60.5),
        alignment: Alignment.bottomCenter,
        child: img,
      ),
    );
  }'''

code = code.replace(old_build_tile, new_build_tile)

# Remove _TilePainter
tile_painter_start = code.find('class _TilePainter extends CustomPainter {')
if tile_painter_start != -1:
    tile_painter_end = code.find('class _BackgroundPainter extends CustomPainter {', tile_painter_start)
    if tile_painter_end != -1:
        code = code[:tile_painter_start] + code[tile_painter_end:]

with open('lib/features/minigames/presentation/onet_connect/onet_connect_game.dart', 'w', encoding='utf-8') as f:
    f.write(code)

print('Updated buildTile!')
