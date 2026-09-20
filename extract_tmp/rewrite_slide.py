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
    // Hint can just wiggle a playable tile? Or we can just disable hint for now since mechanics changed.
  }

  void _useShuffle() {
    if (_shuffles <= 0) return;
    
    List<TileModel> activeTiles = _tiles.where((t) => !t.isMatched).toList();
    List<int> animals = activeTiles.map((t) => t.animal).toList();
    animals.shuffle(_rnd);
    
    setState(() {
      for (int i = 0; i < activeTiles.length; i++) {
        // We actually need to re-assign animals, but TileModel animal is final.
        // Instead, let's shuffle their positions!
      }
      
      List<Point> positions = activeTiles.map((t) => Point(t.r, t.c)).toList();
      positions.shuffle(_rnd);
      
      _grid = List.generate(_rows + 2, (r) => List.generate(_cols + 2, (c) => null));
      
      for (int i = 0; i < activeTiles.length; i++) {
        activeTiles[i].r = positions[i].r;
        activeTiles[i].c = positions[i].c;
        _grid[positions[i].r][positions[i].c] = activeTiles[i];
      }
      
      _shuffles--;
    });
  }

  void _onPanStart(DragStartDetails d, double tileWidth, double tileHeight, double padding) {
    int c = ((d.localPosition.dx - padding) / tileWidth).floor() + 1;
    int r = ((d.localPosition.dy - padding) / tileHeight).floor() + 1;
    
    if (r >= 1 && r <= _rows && c >= 1 && c <= _cols && _grid[r][c] != null) {
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
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      for (var t in _tiles)
                        if (!t.isMatched)
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
    Widget img = Image.asset(
      'assets/images/onet_full/tile_.png',
      width: tileWidth,
      height: tileHeight,
      fit: BoxFit.fill,
      filterQuality: FilterQuality.high,
    );
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 3.75),
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
              child: Text('', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}

class Point {
  final int r, c;
  Point(this.r, this.c);
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
code = code.replace('', '') # safety
with open('lib/features/minigames/presentation/onet_connect/onet_connect_game.dart', 'w', encoding='utf-8') as f:
    f.write(code)
