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
  
  int _rows = 7;
  int _cols = 8;
  late List<List<int>> _grid;
  
  Point? _selected;
  List<Point>? _glowingPath;
  List<Point> _matchedTiles = [];
  
  int _hints = 3;
  int _shuffles = 2;
  int _score = 0;

  bool _isDragging = false;
  Axis? _dragAxis;
  int _dragIndexR = 0;
  int _dragIndexC = 0;
  double _dragDeltaPx = 0;
  double _maxPosDelta = 0;
  double _minPosDelta = 0;

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
    if (_glowingPath != null) return;
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
            _matchedTiles = [_selected!, p];
            int sR = _selected!.r, sC = _selected!.c;
            int pR = p.r, pC = p.c;
            _selected = null;
            
            Future.delayed(const Duration(milliseconds: 350), () {
              if (mounted) {
                setState(() {
                  _glowingPath = null;
                  _grid[sR][sC] = 0;
                  _grid[pR][pC] = 0;
                  _matchedTiles.clear();
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
      _isDragging = true;
      _dragAxis = null;
      _dragIndexR = r;
      _dragIndexC = c;
      _dragDeltaPx = 0;
    }
  }

  void _onPanUpdate(DragUpdateDetails d, double tileWidth, double tileHeight) {
    if (!_isDragging) return;
    
    if (_dragAxis == null) {
      if (d.delta.dx.abs() > d.delta.dy.abs()) {
        _dragAxis = Axis.horizontal;
        int minC = _cols + 1, maxC = 0;
        for (int c = 1; c <= _cols; c++) {
          if (_grid[_dragIndexR][c] != 0) {
            if (c < minC) minC = c;
            if (c > maxC) maxC = c;
          }
        }
        _maxPosDelta = (maxC < minC) ? 0 : (_cols - maxC) * tileWidth;
        _minPosDelta = (maxC < minC) ? 0 : -(minC - 1) * tileWidth;
      } else {
        _dragAxis = Axis.vertical;
        int minR = _rows + 1, maxR = 0;
        for (int r = 1; r <= _rows; r++) {
          if (_grid[r][_dragIndexC] != 0) {
            if (r < minR) minR = r;
            if (r > maxR) maxR = r;
          }
        }
        _maxPosDelta = (maxR < minR) ? 0 : (_rows - maxR) * tileHeight;
        _minPosDelta = (maxR < minR) ? 0 : -(minR - 1) * tileHeight;
      }
    }

    setState(() {
      double delta = (_dragAxis == Axis.horizontal) ? d.delta.dx : d.delta.dy;
      _dragDeltaPx += delta;
      _dragDeltaPx = _dragDeltaPx.clamp(_minPosDelta, _maxPosDelta);
    });
  }

  void _onPanEnd(DragEndDetails d, double tileWidth, double tileHeight) {
    if (!_isDragging) return;
    
    setState(() {
      if (_dragAxis == Axis.horizontal) {
        int shift = (_dragDeltaPx / tileWidth).round();
        if (shift != 0) {
          List<int> newRow = List.filled(_cols + 2, 0);
          for (int c = 1; c <= _cols; c++) {
            if (_grid[_dragIndexR][c] != 0) {
              newRow[c + shift] = _grid[_dragIndexR][c];
            }
          }
          _grid[_dragIndexR] = newRow;
        }
      } else if (_dragAxis == Axis.vertical) {
        int shift = (_dragDeltaPx / tileHeight).round();
        if (shift != 0) {
          List<int> newCol = List.filled(_rows + 2, 0);
          for (int r = 1; r <= _rows; r++) {
            if (_grid[r][_dragIndexC] != 0) {
              newCol[r + shift] = _grid[r][_dragIndexC];
            }
          }
          for (int r = 1; r <= _rows; r++) {
            _grid[r][_dragIndexC] = newCol[r];
          }
        }
      }
      _isDragging = false;
      _dragAxis = null;
      _dragDeltaPx = 0;
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
                  onPanEnd: (d) => _onPanEnd(d, tileWidth, tileHeight),
                  onTapUp: (d) {
                    if (_isDragging && _dragDeltaPx.abs() > 5) return; // Ignore tap if it was a drag
                    int c = ((d.localPosition.dx - padding) / tileWidth).floor() + 1;
                    int r = ((d.localPosition.dy - padding) / tileHeight).floor() + 1;
                    if (r >= 1 && r <= _rows && c >= 1 && c <= _cols) {
                      _onTileTap(Point(r, c));
                    }
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Static Tiles
                      for (int r = 1; r <= _rows; r++)
                        for (int c = 1; c <= _cols; c++)
                          if (_grid[r][c] != 0)
                            Positioned(
                              left: padding + (c - 1) * tileWidth + (_isDragging && _dragAxis == Axis.horizontal && _dragIndexR == r ? _dragDeltaPx : 0),
                              top: padding + (r - 1) * tileHeight + (_isDragging && _dragAxis == Axis.vertical && _dragIndexC == c ? _dragDeltaPx : 0),
                              width: tileWidth,
                              height: tileHeight,
                              child: _buildTile(r, c, tileWidth, tileHeight),
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
    bool isMatched = _matchedTiles.contains(Point(r, c));
    
    Widget img = Image.asset(
      'assets/images/onet_full/tile_\.png',
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

    if (isMatched) {
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
with open('lib/features/minigames/presentation/onet_connect/onet_connect_game.dart', 'w', encoding='utf-8') as f:
    f.write(code)
