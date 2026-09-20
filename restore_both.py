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
  List<Point>? _glowingPath;
  
  TileModel? _dragStartTile;
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

  bool _isGridEmpty(int r, int c) {
    if (r < 0 || r > _rows + 1 || c < 0 || c > _cols + 1) return false;
    if (r == 0 || r == _rows + 1 || c == 0 || c == _cols + 1) return true;
    return _grid[r][c] == null;
  }

  bool _isClearLine(Point p1, Point p2) {
    if (p1.r != p2.r && p1.c != p2.c) return false;
    if (p1.r == p2.r) {
      int min = math.min(p1.c, p2.c);
      int max = math.max(p1.c, p2.c);
      for (int c = min + 1; c < max; c++) {
        if (!_isGridEmpty(p1.r, c)) return false;
      }
    } else {
      int min = math.min(p1.r, p2.r);
      int max = math.max(p1.r, p2.r);
      for (int r = min + 1; r < max; r++) {
        if (!_isGridEmpty(r, p1.c)) return false;
      }
    }
    return true;
  }

  List<Point>? _findPath(Point p1, Point p2) {
    if (_isClearLine(p1, p2)) return [p1, p2];

    Point corner1 = Point(p1.r, p2.c);
    if (_isGridEmpty(corner1.r, corner1.c) && _isClearLine(p1, corner1) && _isClearLine(corner1, p2)) {
      return [p1, corner1, p2];
    }
    Point corner2 = Point(p2.r, p1.c);
    if (_isGridEmpty(corner2.r, corner2.c) && _isClearLine(p1, corner2) && _isClearLine(corner2, p2)) {
      return [p1, corner2, p2];
    }

    for (int r = 0; r <= _rows + 1; r++) {
      Point p3 = Point(r, p1.c);
      Point p4 = Point(r, p2.c);
      if (_isGridEmpty(p3.r, p3.c) && _isGridEmpty(p4.r, p4.c) && 
          _isClearLine(p1, p3) && _isClearLine(p3, p4) && _isClearLine(p4, p2)) {
        return [p1, p3, p4, p2];
      }
    }

    for (int c = 0; c <= _cols + 1; c++) {
      Point p3 = Point(p1.r, c);
      Point p4 = Point(p2.r, c);
      if (_isGridEmpty(p3.r, p3.c) && _isGridEmpty(p4.r, p4.c) && 
          _isClearLine(p1, p3) && _isClearLine(p3, p4) && _isClearLine(p4, p2)) {
        return [p1, p3, p4, p2];
      }
    }

    return null;
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
    if (_hints <= 0 || _glowingPath != null) return;
    List<TileModel> activeTiles = _tiles.where((t) => !t.isMatched).toList();
    for (int i = 0; i < activeTiles.length; i++) {
      for (int j = i + 1; j < activeTiles.length; j++) {
        if (activeTiles[i].animal == activeTiles[j].animal) {
          List<Point>? path = _findPath(Point(activeTiles[i].r, activeTiles[i].c), Point(activeTiles[j].r, activeTiles[j].c));
          if (path != null) {
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
    if (_shuffles <= 0 || _glowingPath != null) return;
    
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
    if (_glowingPath != null) return;
    TileModel? tappedTile = _grid[r][c];
    if (tappedTile == null) return;

    setState(() {
      if (_selected == null || _selected == tappedTile) {
        _selected = tappedTile;
      } else {
        if (_selected!.animal == tappedTile.animal) {
          List<Point>? path = _findPath(Point(_selected!.r, _selected!.c), Point(r, c));
          if (path != null) {
            _glowingPath = path;
            TileModel s = _selected!;
            TileModel t = tappedTile;
            _selected = null;
            
            Future.delayed(const Duration(milliseconds: 350), () {
              if (mounted) {
                setState(() {
                  _glowingPath = null;
                  _grid[s.r][s.c] = null;
                  _grid[t.r][t.c] = null;
                  s.isMatched = true;
                  t.isMatched = true;
                  _score += 10;
                  _checkWin();
                });
              }
            });
          } else {
            _selected = tappedTile;
          }
        } else {
          _selected = tappedTile;
        }
      }
    });
  }

  void _onPanStart(DragStartDetails d, double tileWidth, double tileHeight, double padding) {
    if (_glowingPath != null) return;
    int c = ((d.localPosition.dx - padding) / tileWidth).floor() + 1;
    int r = ((d.localPosition.dy - padding) / tileHeight).floor() + 1;
    
    if (r >= 1 && r <= _rows && c >= 1 && c <= _cols && _grid[r][c] != null) {
      setState(() {
        _selected = _grid[r][c];
      });
      _dragStartTile = _grid[r][c];
      _dragDeltaPx = Offset.zero;
    } else {
      _dragStartTile = null;
    }
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_dragStartTile != null) {
      _dragDeltaPx += d.delta;
    }
  }

  void _onPanEnd(DragEndDetails d) {
    if (_dragStartTile == null) return;
    
    if (_dragDeltaPx.distance < 10 && d.velocity.pixelsPerSecond.distance < 100) {
      _dragStartTile = null;
      return;
    }

    int dr = 0, dc = 0;
    if (_dragDeltaPx.dx.abs() > _dragDeltaPx.dy.abs()) {
      dc = _dragDeltaPx.dx > 0 ? 1 : -1;
    } else {
      dr = _dragDeltaPx.dy > 0 ? 1 : -1;
    }

    _shootTile(_dragStartTile!, dr, dc);
    _dragStartTile = null;
  }
  
  void _shootTile(TileModel t, int dr, int dc) {
    int r = t.r;
    int c = t.c;
    
    int targetR = r;
    int targetC = c;
    
    TileModel? matchTile;
    
    while (true) {
      int nextR = targetR + dr;
      int nextC = targetC + dc;
      
      if (nextR < 1 || nextR > _rows || nextC < 1 || nextC > _cols) {
        break; // Hit wall
      }
      
      TileModel? nextTile = _grid[nextR][nextC];
      if (nextTile != null) {
        if (nextTile.animal == t.animal) {
          matchTile = nextTile; // Hit matching tile
        }
        break; // Hit obstacle (matching or not)
      }
      
      targetR = nextR;
      targetC = nextC;
    }
    
    if (targetR != r || targetC != c || matchTile != null) {
      setState(() {
        _grid[t.r][t.c] = null; // remove from old
        t.r = targetR;
        t.c = targetC;
        if (matchTile == null) {
           _grid[targetR][targetC] = t; // place in new
        }
        _selected = null; // deselect after shooting
      });
      
      if (matchTile != null) {
        _grid[matchTile.r][matchTile.c] = null; // remove matched tile from grid too
        
        int delay = (targetR != r || targetC != c) ? 150 : 0;
        Future.delayed(Duration(milliseconds: delay), () {
          if (mounted) {
            setState(() {
              t.isMatched = true;
              matchTile!.isMatched = true;
              _score += 10;
              _checkWin();
            });
          }
        });
      }
    }
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
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  onTapUp: (d) {
                    if (_dragDeltaPx.distance > 5) return;
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
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeOutQuad,
                          left: padding + (t.c - 1) * tileWidth,
                          top: padding + (t.r - 1) * tileHeight,
                          width: tileWidth,
                          height: tileHeight,
                          child: _buildTile(t, tileWidth, tileHeight),
                        ),
                        
                      if (_glowingPath != null)
                        Positioned.fill(
                          child: CustomPaint(painter: _PathLinePainter(_glowingPath!, tileWidth, tileHeight, padding)),
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

class _PathLinePainter extends CustomPainter {
  final List<Point> path;
  final double tileWidth;
  final double tileHeight;
  final double padding;
  _PathLinePainter(this.path, this.tileWidth, this.tileHeight, this.padding);

  @override
  void paint(Canvas canvas, Size size) {
    Path p = Path();
    for (int i = 0; i < path.length; i++) {
      double cx = padding + (path[i].c - 1) * tileWidth + tileWidth / 2;
      double cy = padding + (path[i].r - 1) * tileHeight + tileHeight / 2;
      if (i == 0) p.moveTo(cx, cy);
      else p.lineTo(cx, cy);
    }

    Paint outerGlow = Paint()..color = Colors.lightGreenAccent.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 24..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    Paint innerGlow = Paint()..color = Colors.yellowAccent.withOpacity(0.8)..style = PaintingStyle.stroke..strokeWidth = 14..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    Paint core = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 6..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;

    canvas.drawPath(p, outerGlow);
    canvas.drawPath(p, innerGlow);
    canvas.drawPath(p, core);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
'''
code = code.replace('', '')
with open('lib/features/minigames/presentation/onet_connect/onet_connect_game.dart', 'w', encoding='utf-8') as f:
    f.write(code)
