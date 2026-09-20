code = '''import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/config/app_config.dart';
import '../../domain/mini_game_contract.dart';

class Point {
  final int r, c;
  Point(this.r, this.c);
  @override
  bool operator ==(Object other) => other is Point && other.r == r && other.c == c;
  @override
  int get hashCode => Object.hash(r, c);
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
  
  int _rows = 8;
  int _cols = 6;
  late List<List<int>> _grid;
  
  Point? _selected;
  List<Point>? _glowingPath;
  
  int _hints = 3;
  int _shuffles = 2;
  int _score = 0;
  
  // Dragging mechanic state
  List<Point> _draggingTiles = [];
  Axis? _dragAxis;
  Offset _dragDelta = Offset.zero;
  double _lastDragOffset = 0;
  int _dragIndex = 0;

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
    List<int> tiles = [];
    int numAnimals = 15;

    for (int i = 0; i < totalTiles; i += 2) {
      int animal = _rnd.nextInt(numAnimals) + 1;
      tiles.add(animal);
      tiles.add(animal);
    }
    tiles.shuffle(_rnd);

    _grid = List.generate(_rows + 2, (r) => List.generate(_cols + 2, (c) {
      if (r == 0 || r == _rows + 1 || c == 0 || c == _cols + 1) return 0;
      return tiles[(r - 1) * _cols + (c - 1)];
    }));
  }

  List<Point>? _findPath(Point p1, Point p2) {
    if (_isClearLine(p1, p2)) return [p1, p2];

    Point corner1 = Point(p1.r, p2.c);
    if (_grid[corner1.r][corner1.c] == 0 && _isClearLine(p1, corner1) && _isClearLine(corner1, p2)) {
      return [p1, corner1, p2];
    }
    Point corner2 = Point(p2.r, p1.c);
    if (_grid[corner2.r][corner2.c] == 0 && _isClearLine(p1, corner2) && _isClearLine(corner2, p2)) {
      return [p1, corner2, p2];
    }

    for (int r = 0; r <= _rows + 1; r++) {
      Point p3 = Point(r, p1.c);
      Point p4 = Point(r, p2.c);
      if (_grid[p3.r][p3.c] == 0 && _grid[p4.r][p4.c] == 0 && 
          _isClearLine(p1, p3) && _isClearLine(p3, p4) && _isClearLine(p4, p2)) {
        return [p1, p3, p4, p2];
      }
    }

    for (int c = 0; c <= _cols + 1; c++) {
      Point p3 = Point(p1.r, c);
      Point p4 = Point(p2.r, c);
      if (_grid[p3.r][p3.c] == 0 && _grid[p4.r][p4.c] == 0 && 
          _isClearLine(p1, p3) && _isClearLine(p3, p4) && _isClearLine(p4, p2)) {
        return [p1, p3, p4, p2];
      }
    }

    return null;
  }

  bool _isClearLine(Point p1, Point p2) {
    if (p1.r != p2.r && p1.c != p2.c) return false;
    if (p1.r == p2.r) {
      int min = math.min(p1.c, p2.c);
      int max = math.max(p1.c, p2.c);
      for (int c = min + 1; c < max; c++) {
        if (_grid[p1.r][c] != 0) return false;
      }
    } else {
      int min = math.min(p1.r, p2.r);
      int max = math.max(p1.r, p2.r);
      for (int r = min + 1; r < max; r++) {
        if (_grid[r][p1.c] != 0) return false;
      }
    }
    return true;
  }

  void _onTileTap(Point p) {
    if (_draggingTiles.isNotEmpty || _glowingPath != null) return;
    if (_grid[p.r][p.c] == 0) return;

    setState(() {
      if (_selected == null) {
        _selected = p;
      } else {
        if (_selected == p) {
          _selected = null;
        } else if (_grid[_selected!.r][_selected!.c] == _grid[p.r][p.c]) {
          List<Point>? path = _findPath(_selected!, p);
          if (path != null) {
            _glowingPath = path;
            int sR = _selected!.r, sC = _selected!.c;
            int pR = p.r, pC = p.c;
            _selected = null;
            
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                setState(() {
                  _glowingPath = null;
                  _grid[sR][sC] = 0;
                  _grid[pR][pC] = 0;
                  _score += 10;
                  _checkWin();
                });
              }
            });
          } else {
            _selected = p;
          }
        } else {
          _selected = p;
        }
      }
    });
  }

  void _checkWin() {
    bool win = true;
    for (int r = 1; r <= _rows; r++) {
      for (int c = 1; c <= _cols; c++) {
        if (_grid[r][c] != 0) {
          win = false;
          break;
        }
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
    for (int r1 = 1; r1 <= _rows; r1++) {
      for (int c1 = 1; c1 <= _cols; c1++) {
        if (_grid[r1][c1] == 0) continue;
        for (int r2 = r1; r2 <= _rows; r2++) {
          for (int c2 = (r1 == r2 ? c1 + 1 : 1); c2 <= _cols; c2++) {
            if (_grid[r2][c2] == _grid[r1][c1]) {
              List<Point>? path = _findPath(Point(r1, c1), Point(r2, c2));
              if (path != null) {
                setState(() {
                  _hints--;
                  _selected = Point(r1, c1);
                });
                return;
              }
            }
          }
        }
      }
    }
  }

  void _useShuffle() {
    if (_shuffles <= 0 || _glowingPath != null) return;
    List<int> remaining = [];
    for (int r = 1; r <= _rows; r++) {
      for (int c = 1; c <= _cols; c++) {
        if (_grid[r][c] != 0) remaining.add(_grid[r][c]);
      }
    }
    remaining.shuffle(_rnd);
    int idx = 0;
    setState(() {
      for (int r = 1; r <= _rows; r++) {
        for (int c = 1; c <= _cols; c++) {
          if (_grid[r][c] != 0) _grid[r][c] = remaining[idx++];
        }
      }
      _shuffles--;
      _selected = null;
    });
  }

  void _onPanStart(DragStartDetails d, double tileWidth, double tileHeight, double padding) {
    if (_glowingPath != null) return;
    
    int c = ((d.localPosition.dx - padding) / tileWidth).floor() + 1;
    int r = ((d.localPosition.dy - padding) / tileHeight).floor() + 1;
    
    if (r >= 1 && r <= _rows && c >= 1 && c <= _cols && _grid[r][c] != 0) {
      _draggingTiles = [Point(r, c)];
      _dragAxis = null;
      _dragDelta = Offset.zero;
      _lastDragOffset = 0;
      _dragIndex = c; // assume horizontal first, fix on update
    }
  }

  void _onPanUpdate(DragUpdateDetails d, double tileWidth, double tileHeight) {
    if (_draggingTiles.isEmpty) return;
    
    if (_dragAxis == null) {
      if (d.delta.dx.abs() > d.delta.dy.abs()) {
        _dragAxis = Axis.horizontal;
        _dragIndex = _draggingTiles.first.r;
        _draggingTiles.clear();
        for (int c = 1; c <= _cols; c++) {
          if (_grid[_dragIndex][c] != 0) _draggingTiles.add(Point(_dragIndex, c));
        }
      } else {
        _dragAxis = Axis.vertical;
        _dragIndex = _draggingTiles.first.c;
        _draggingTiles.clear();
        for (int r = 1; r <= _rows; r++) {
          if (_grid[r][_dragIndex] != 0) _draggingTiles.add(Point(r, _dragIndex));
        }
      }
    }

    setState(() {
      _dragDelta += d.delta;
      if (_dragAxis == Axis.horizontal) {
        if (_dragDelta.dx > tileWidth * 0.8) _lastDragOffset = _dragDelta.dx;
        else if (_dragDelta.dx < -tileWidth * 0.8) _lastDragOffset = _dragDelta.dx;
      } else {
        if (_dragDelta.dy > tileHeight * 0.8) _lastDragOffset = _dragDelta.dy;
        else if (_dragDelta.dy < -tileHeight * 0.8) _lastDragOffset = _dragDelta.dy;
      }
    });
  }

  void _onPanEnd(DragEndDetails d, double tileWidth, double tileHeight) {
    if (_draggingTiles.isEmpty || _dragAxis == null) return;
    
    setState(() {
      if (_dragAxis == Axis.horizontal) {
        int shift = (_dragDelta.dx / tileWidth).round();
        if (shift != 0) {
          List<int> newRow = List.filled(_cols + 2, 0);
          for (int c = 1; c <= _cols; c++) {
            if (_grid[_dragIndex][c] != 0) {
              int nc = c + shift;
              if (nc < 1) nc = 1;
              if (nc > _cols) nc = _cols;
              while(nc < _cols && newRow[nc] != 0) nc++;
              while(nc > 1 && newRow[nc] != 0) nc--;
              newRow[nc] = _grid[_dragIndex][c];
            }
          }
          _grid[_dragIndex] = newRow;
        }
      } else {
        int shift = (_dragDelta.dy / tileHeight).round();
        if (shift != 0) {
          List<int> newCol = List.filled(_rows + 2, 0);
          for (int r = 1; r <= _rows; r++) {
            if (_grid[r][_dragIndex] != 0) {
              int nr = r + shift;
              if (nr < 1) nr = 1;
              if (nr > _rows) nr = _rows;
              while(nr < _rows && newCol[nr] != 0) nr++;
              while(nr > 1 && newCol[nr] != 0) nr--;
              newCol[nr] = _grid[r][_dragIndex];
            }
          }
          for (int r = 1; r <= _rows; r++) {
            _grid[r][_dragIndex] = newCol[r];
          }
        }
      }
      
      _draggingTiles.clear();
      _dragAxis = null;
      _dragDelta = Offset.zero;
      _selected = null; 
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
              
              // New calculation with 60x75 aspect ratio!
              double tileWidth = math.min((maxW - padding*2) / _cols, (maxH - padding*2) / (_rows * 1.25));
              double tileHeight = tileWidth * 1.25;
              
              double boardW = tileWidth * _cols + padding * 2;
              double boardH = tileHeight * _rows + padding * 2;
              
              return Container(
                width: boardW, height: boardH,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black, width: 4),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFF14863C), offset: Offset(0, 8)),
                    BoxShadow(color: Colors.black, offset: Offset(0, 12)),
                  ],
                ),
                child: GestureDetector(
                  onPanStart: (d) => _onPanStart(d, tileWidth, tileHeight, padding),
                  onPanUpdate: (d) => _onPanUpdate(d, tileWidth, tileHeight),
                  onPanEnd: (d) => _onPanEnd(d, tileWidth, tileHeight),
                  onTapDown: (d) {
                    if (_draggingTiles.isEmpty) {
                      int c = ((d.localPosition.dx - padding) / tileWidth).floor() + 1;
                      int r = ((d.localPosition.dy - padding) / tileHeight).floor() + 1;
                      if (r >= 1 && r <= _rows && c >= 1 && c <= _cols) {
                        _onTileTap(Point(r, c));
                      }
                    }
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Static Tiles
                      for (int r = 1; r <= _rows; r++)
                        for (int c = 1; c <= _cols; c++)
                          if (_grid[r][c] != 0 && !_draggingTiles.contains(Point(r,c)))
                            Positioned(
                              left: padding + (c - 1) * tileWidth,
                              top: padding + (r - 1) * tileHeight,
                              width: tileWidth,
                              height: tileHeight,
                              child: _buildTile(r, c, tileWidth, tileHeight),
                            ),
                            
                      // Dragging Tiles
                      for (var p in _draggingTiles)
                        Positioned(
                          left: padding + (p.c - 1) * tileWidth + (_dragAxis == Axis.horizontal ? _dragDelta.dx : 0),
                          top: padding + (p.r - 1) * tileHeight + (_dragAxis == Axis.vertical ? _dragDelta.dy : 0),
                          width: tileWidth,
                          height: tileHeight,
                          child: _buildTile(p.r, p.c, tileWidth, tileHeight),
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

  Widget _buildTile(int r, int c, double tileWidth, double tileHeight) {
    bool isSelected = _selected?.r == r && _selected?.c == c;
    Widget img = Image.asset(
      'assets/images/onet_full/tile_.png',
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
    
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: img,
    );
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

    Paint p = Paint()
      ..color = const Color(0x337CFF70)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      
    canvas.drawArc(Rect.fromCenter(center: Offset(size.width*.2, size.height*.2), width: 700, height: 700), 0, math.pi*2, false, p);
    canvas.drawArc(Rect.fromCenter(center: Offset(size.width*.9, size.height*.8), width: 900, height: 900), 0, math.pi*2, false, p);
    canvas.drawArc(Rect.fromCenter(center: Offset(size.width*.6, size.height*.1), width: 1200, height: 1200), math.pi, math.pi/2, false, p);
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
    Paint glow = Paint()..color = Colors.yellowAccent.withOpacity(0.9)..style = PaintingStyle.stroke..strokeWidth = 14..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
    Paint line = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 6..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;

    Path p = Path();
    for (int i = 0; i < path.length; i++) {
      double cx = padding + (path[i].c - 1) * tileWidth + tileWidth / 2;
      double cy = padding + (path[i].r - 1) * tileHeight + tileHeight / 2;
      if (i == 0) p.moveTo(cx, cy);
      else p.lineTo(cx, cy);
    }
    canvas.drawPath(p, glow);
    canvas.drawPath(p, line);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
'''
with open('lib/features/minigames/presentation/onet_connect/onet_connect_game.dart', 'w', encoding='utf-8') as f:
    f.write(code)
