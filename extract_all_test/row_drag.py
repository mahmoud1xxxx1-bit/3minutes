code = '''import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/config/app_config.dart';
import '../../domain/mini_game_contract.dart';

class TileModel {
  final int id;
  final int animal;
  int r;
  int c;
  bool isMatched;
  
  TileModel({required this.id, required this.animal, required this.r, required this.c, this.isMatched = false});
}

class Point {
  final int r, c;
  Point(this.r, this.c);
}

class OnetConnectGame extends StatefulWidget {
  final MiniGameConfig config;
  final Function(MiniGameResult)? onComplete;

  const OnetConnectGame({super.key, required this.config, this.onComplete});

  @override
  State<OnetConnectGame> createState() => _OnetConnectGameState();
}

class _OnetConnectGameState extends State<OnetConnectGame> with SingleTickerProviderStateMixin {
  late math.Random _rnd;
  late DateTime _startTime;
  
  int _rows = 7;
  int _cols = 8;
  
  List<TileModel> _tiles = [];
  List<List<TileModel?>> _grid = [];
  
  TileModel? _selected;
  
  TileModel? _dragStartTile;
  List<TileModel> _draggedBlock = [];
  Axis? _dragAxis;
  Offset _dragDeltaPx = Offset.zero;
  
  int _hints = 3;
  int _shuffles = 2;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _rnd = math.Random(widget.config.seed);
    _startTime = DateTime.now();
    _initRound();
  }

  void _initRound() {
    _rows = 7;
    _cols = 8;
    _generateGrid();
  }

  void _generateGrid() {
    int totalTiles = _rows * _cols;
    List<int> animals = [];
    int numAnimals = 15;

    for (int i = 0; i < totalTiles; i += 2) {
      int animal = _rnd.nextInt(numAnimals) + 1;
      animals.add(animal);
      animals.add(animal);
    }
    animals.shuffle(_rnd);

    _tiles = [];
    _grid = List.generate(_rows + 2, (r) => List.generate(_cols + 2, (c) => null));
    
    int idCounter = 1;
    for (int r = 1; r <= _rows; r++) {
      for (int c = 1; c <= _cols; c++) {
        var t = TileModel(
          id: idCounter++,
          animal: animals[(r - 1) * _cols + (c - 1)],
          r: r,
          c: c,
        );
        _tiles.add(t);
        _grid[r][c] = t;
      }
    }
  }

  void _checkWin() {
    bool win = true;
    for (var t in _tiles) {
      if (!t.isMatched) {
        win = false;
        break;
      }
    }
    if (win && widget.onComplete != null) {
      widget.onComplete!(
        MiniGameResult(
          completed: true,
          score: _score,
          accuracy: 1.0,
          mistakes: 0,
          duration: DateTime.now().difference(_startTime),
        ),
      );
    }
  }

  void _useHint() {
    if (_hints <= 0) return;
    List<TileModel> activeTiles = _tiles.where((t) => !t.isMatched).toList();
    for (int i = 0; i < activeTiles.length; i++) {
      for (int j = i + 1; j < activeTiles.length; j++) {
        if (activeTiles[i].animal == activeTiles[j].animal) {
          int rDiff = (activeTiles[i].r - activeTiles[j].r).abs();
          int cDiff = (activeTiles[i].c - activeTiles[j].c).abs();
          if ((rDiff == 1 && cDiff == 0) || (rDiff == 0 && cDiff == 1)) {
            setState(() {
              _hints--;
              _selected = activeTiles[i];
            });
            return;
          }
        }
      }
    }
  }

  void _useShuffle() {
    if (_shuffles <= 0) return;
    List<TileModel> activeTiles = _tiles.where((t) => !t.isMatched).toList();
    List<Point> positions = activeTiles.map((t) => Point(t.r, t.c)).toList();
    positions.shuffle(_rnd);
    
    setState(() {
      _grid = List.generate(_rows + 2, (r) => List.generate(_cols + 2, (c) => null));
      for (int i = 0; i < activeTiles.length; i++) {
        activeTiles[i].r = positions[i].r;
        activeTiles[i].c = positions[i].c;
        _grid[positions[i].r][positions[i].c] = activeTiles[i];
      }
      _shuffles--;
      _selected = null;
    });
  }

  void _onTileTap(int r, int c) {
    TileModel? tappedTile = _grid[r][c];
    if (tappedTile == null) return;

    setState(() {
      if (_selected == null) {
        _selected = tappedTile;
      } else if (_selected == tappedTile) {
        _selected = null;
      } else {
        if (_selected!.animal == tappedTile.animal) {
          int rDiff = (_selected!.r - tappedTile.r).abs();
          int cDiff = (_selected!.c - tappedTile.c).abs();
          
          if ((rDiff == 1 && cDiff == 0) || (rDiff == 0 && cDiff == 1)) {
            TileModel s = _selected!;
            TileModel t = tappedTile;
            _selected = null;
            
            _grid[s.r][s.c] = null;
            _grid[t.r][t.c] = null;
            s.isMatched = true;
            t.isMatched = true;
            _score += 10;
            _checkWin();
          } else {
            _selected = tappedTile;
          }
        } else {
          _selected = tappedTile;
        }
      }
    });
  }

  List<TileModel> _getHorizontalBlock(int r, int c) {
    List<TileModel> block = [];
    if (_grid[r][c] == null) return block;
    
    int minC = c;
    while (minC > 1 && _grid[r][minC - 1] != null) minC--;
    
    int maxC = c;
    while (maxC < _cols && _grid[r][maxC + 1] != null) maxC++;
    
    for (int i = minC; i <= maxC; i++) {
      block.add(_grid[r][i]!);
    }
    return block;
  }

  List<TileModel> _getVerticalBlock(int r, int c) {
    List<TileModel> block = [];
    if (_grid[r][c] == null) return block;
    
    int minR = r;
    while (minR > 1 && _grid[minR - 1][c] != null) minR--;
    
    int maxR = r;
    while (maxR < _rows && _grid[maxR + 1][c] != null) maxR++;
    
    for (int i = minR; i <= maxR; i++) {
      block.add(_grid[i][c]!);
    }
    return block;
  }

  void _onPanStart(DragStartDetails d, double tileWidth, double tileHeight, double padding) {
    int c = ((d.localPosition.dx - padding) / tileWidth).floor() + 1;
    int r = ((d.localPosition.dy - padding) / tileHeight).floor() + 1;
    
    if (r >= 1 && r <= _rows && c >= 1 && c <= _cols && _grid[r][c] != null) {
      _dragStartTile = _grid[r][c];
      _dragDeltaPx = Offset.zero;
      _dragAxis = null;
      _draggedBlock = [];
    }
  }

  bool _tryMoveBlockRight(double tileWidth) {
    int r = _dragStartTile!.r;
    int maxC = _draggedBlock.last.c;
    if (maxC >= _cols || _grid[r][maxC + 1] != null) return false;
    
    for (int i = _draggedBlock.length - 1; i >= 0; i--) {
      TileModel t = _draggedBlock[i];
      _grid[r][t.c] = null;
      t.c += 1;
      _grid[r][t.c] = t;
    }
    _dragDeltaPx -= Offset(tileWidth, 0);
    return true;
  }

  bool _tryMoveBlockLeft(double tileWidth) {
    int r = _dragStartTile!.r;
    int minC = _draggedBlock.first.c;
    if (minC <= 1 || _grid[r][minC - 1] != null) return false;
    
    for (int i = 0; i < _draggedBlock.length; i++) {
      TileModel t = _draggedBlock[i];
      _grid[r][t.c] = null;
      t.c -= 1;
      _grid[r][t.c] = t;
    }
    _dragDeltaPx += Offset(tileWidth, 0);
    return true;
  }

  bool _tryMoveBlockDown(double tileHeight) {
    int c = _dragStartTile!.c;
    int maxR = _draggedBlock.last.r;
    if (maxR >= _rows || _grid[maxR + 1][c] != null) return false;
    
    for (int i = _draggedBlock.length - 1; i >= 0; i--) {
      TileModel t = _draggedBlock[i];
      _grid[t.r][c] = null;
      t.r += 1;
      _grid[t.r][c] = t;
    }
    _dragDeltaPx -= Offset(0, tileHeight);
    return true;
  }

  bool _tryMoveBlockUp(double tileHeight) {
    int c = _dragStartTile!.c;
    int minR = _draggedBlock.first.r;
    if (minR <= 1 || _grid[minR - 1][c] != null) return false;
    
    for (int i = 0; i < _draggedBlock.length; i++) {
      TileModel t = _draggedBlock[i];
      _grid[t.r][c] = null;
      t.r -= 1;
      _grid[t.r][c] = t;
    }
    _dragDeltaPx += Offset(0, tileHeight);
    return true;
  }

  void _onPanUpdate(DragUpdateDetails d, double tileWidth, double tileHeight) {
    if (_dragStartTile == null) return;
    
    setState(() {
      _dragDeltaPx += d.delta;
      
      if (_dragAxis == null && _dragDeltaPx.distance > 5) {
        if (_dragDeltaPx.dx.abs() > _dragDeltaPx.dy.abs()) {
          _dragAxis = Axis.horizontal;
          _draggedBlock = _getHorizontalBlock(_dragStartTile!.r, _dragStartTile!.c);
          _dragDeltaPx = Offset(_dragDeltaPx.dx, 0);
        } else {
          _dragAxis = Axis.vertical;
          _draggedBlock = _getVerticalBlock(_dragStartTile!.r, _dragStartTile!.c);
          _dragDeltaPx = Offset(0, _dragDeltaPx.dy);
        }
      }
      
      if (_dragAxis == null) return;
      
      if (_dragAxis == Axis.horizontal) {
        _dragDeltaPx = Offset(_dragDeltaPx.dx, 0);
        
        while (_dragDeltaPx.dx > tileWidth * 0.6) {
          if (!_tryMoveBlockRight(tileWidth)) break;
        }
        while (_dragDeltaPx.dx < -tileWidth * 0.6) {
          if (!_tryMoveBlockLeft(tileWidth)) break;
        }
        
        int maxC = _draggedBlock.last.c;
        int minC = _draggedBlock.first.c;
        bool canGoRight = maxC < _cols && _grid[_dragStartTile!.r][maxC + 1] == null;
        bool canGoLeft = minC > 1 && _grid[_dragStartTile!.r][minC - 1] == null;
        
        if (_dragDeltaPx.dx > 0 && !canGoRight) _dragDeltaPx = Offset(0, 0);
        if (_dragDeltaPx.dx < 0 && !canGoLeft) _dragDeltaPx = Offset(0, 0);
        
      } else {
        _dragDeltaPx = Offset(0, _dragDeltaPx.dy);
        
        while (_dragDeltaPx.dy > tileHeight * 0.6) {
          if (!_tryMoveBlockDown(tileHeight)) break;
        }
        while (_dragDeltaPx.dy < -tileHeight * 0.6) {
          if (!_tryMoveBlockUp(tileHeight)) break;
        }
        
        int maxR = _draggedBlock.last.r;
        int minR = _draggedBlock.first.r;
        bool canGoDown = maxR < _rows && _grid[maxR + 1][_dragStartTile!.c] == null;
        bool canGoUp = minR > 1 && _grid[minR - 1][_dragStartTile!.c] == null;
        
        if (_dragDeltaPx.dy > 0 && !canGoDown) _dragDeltaPx = Offset(0, 0);
        if (_dragDeltaPx.dy < 0 && !canGoUp) _dragDeltaPx = Offset(0, 0);
      }
    });
  }

  void _onPanEnd(DragEndDetails d) {
    setState(() {
      _dragStartTile = null;
      _dragAxis = null;
      _draggedBlock = [];
      _dragDeltaPx = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D5D30), 
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _BackgroundPainter())),
          
          Positioned(
            left: 20,
            top: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPauseBtn(),
                const SizedBox(height: 40),
                _buildPowerUpBtn(Icons.lightbulb, Colors.yellow, _hints, _useHint),
                const SizedBox(height: 20),
                _buildPowerUpBtn(Icons.sync, Colors.cyanAccent, _shuffles, _useShuffle),
              ],
            ),
          ),
          
          Center(
            child: LayoutBuilder(builder: (context, constraints) {
              double maxW = constraints.maxWidth - 200;
              double maxH = constraints.maxHeight - 80;
              double padding = 12.0;
              
              double tileWidth = math.min((maxW - padding*2) / _cols, (maxH - padding*2) / (_rows * 1.25));
              double tileHeight = tileWidth * 1.25;
              
              double boardW = tileWidth * _cols + padding * 2;
              double boardH = tileHeight * _rows + padding * 2;
              
              return Container(
                width: boardW, height: boardH,
                color: Colors.transparent, 
                child: GestureDetector(
                  onPanStart: (d) => _onPanStart(d, tileWidth, tileHeight, padding),
                  onPanUpdate: (d) => _onPanUpdate(d, tileWidth, tileHeight),
                  onPanEnd: _onPanEnd,
                  onTapUp: (d) {
                    if (_dragAxis != null) return;
                    int c = ((d.localPosition.dx - padding) / tileWidth).floor() + 1;
                    int r = ((d.localPosition.dy - padding) / tileHeight).floor() + 1;
                    if (r >= 1 && r <= _rows && c >= 1 && c <= _cols) {
                      _onTileTap(r, c);
                    }
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      for (var t in _tiles)
                        AnimatedPositioned(
                          key: ValueKey(t.id),
                          duration: Duration(milliseconds: _draggedBlock.contains(t) ? 0 : 150),
                          curve: Curves.easeOutQuad,
                          left: padding + (t.c - 1) * tileWidth + (_draggedBlock.contains(t) ? _dragDeltaPx.dx : 0),
                          top: padding + (t.r - 1) * tileHeight + (_draggedBlock.contains(t) ? _dragDeltaPx.dy : 0),
                          width: tileWidth,
                          height: tileHeight,
                          child: _buildTile(t, tileWidth, tileHeight),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(TileModel t, double tileWidth, double tileHeight) {
    bool isSelected = _selected == t;
    
    Widget img = Image.asset(
      'assets/images/onet_full/tile_.png',
      width: tileWidth,
      height: tileHeight,
      fit: BoxFit.fill,
      filterQuality: FilterQuality.high,
    );
    
    Widget tileWidget = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 3.75),
      child: Stack(
        fit: StackFit.expand,
        children: [
          img,
          if (isSelected)
            Container(
              decoration: BoxDecoration(
                color: const Color(0x33FFFF00),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.yellowAccent, width: 4),
              ),
            ),
        ],
      ),
    );

    if (isSelected) {
      tileWidget = Transform.scale(
        scale: 1.05,
        child: tileWidget,
      );
    }

    if (t.isMatched) {
      return TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 350),
        tween: Tween(begin: 1.0, end: 0.0),
        builder: (context, val, child) {
          return Opacity(
            opacity: val,
            child: Transform.scale(
              scale: 0.5 + (0.5 * val),
              child: child,
            ),
          );
        },
        child: tileWidget,
      );
    }
    
    return tileWidget;
  }

  Widget _buildPauseBtn() {
    return Container(
      width: 60, height: 60,
      margin: const EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFF00FF),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black54, offset: Offset(0, 4))],
      ),
      child: const Center(
        child: Text('||', style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildPowerUpBtn(IconData icon, Color color, int count, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100, height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF103623),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.black, width: 3),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: -15, top: -10,
              child: Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: Border.all(color: Colors.black, width: 3),
                ),
                child: Icon(icon, size: 36, color: Colors.black),
              ),
            ),
            Positioned(
              right: 20, top: 12,
              child: Text('\', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint gradientPaint = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFF1C9E4B), const Color(0xFF0D5D30)],
        radius: 1.0,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), gradientPaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
'''
code = code.replace('', '')
with open('lib/features/minigames/presentation/onet_connect/onet_connect_game.dart', 'w', encoding='utf-8') as f:
    f.write(code)
