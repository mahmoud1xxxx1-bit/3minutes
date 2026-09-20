from PIL import Image

code = '''  Widget _buildTile(int r, int c, double tileWidth, double tileHeight) {
    bool isSelected = _selected?.r == r && _selected?.c == c;
    Widget img = Image.asset(
      'assets/images/onet_full/tile_\.png',
      width: tileWidth,
      height: tileHeight,
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
    
    // We use symmetric padding to maintain the 60x75 aspect ratio of the inner space
    // If width padding is 2.0 (total 4.0), height padding should be 2.0 * 1.25 = 2.5 (total 5.0)
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.5),
      child: img,
    );
  }
'''
