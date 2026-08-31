import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// deleted
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

class Particle {
  Offset position;
  Offset velocity;
  Color color;
  double life;
  double maxLife;
  double size;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.maxLife,
    required this.size,
  }) : life = maxLife;
}

class ComboText {
  String text;
  double life;
  double maxLife;
  Offset randomOffset;

  ComboText({required this.text, required this.maxLife}) : 
    life = maxLife, 
    randomOffset = Offset((math.Random().nextDouble() - 0.5) * 60, (math.Random().nextDouble() - 0.5) * 40);
}

class OnetConnectGame extends StatefulWidget {
  final MiniGameConfig config;
  final Function(MiniGameResult)? onComplete;

  const OnetConnectGame({super.key, required this.config, this.onComplete});

  @override
  State<OnetConnectGame> createState() => _OnetConnectGameState();
}

class _OnetConnectGameState extends State<OnetConnectGame> with TickerProviderStateMixin {
  late math.Random _rnd;
  late DateTime _startTime;
  
  late Ticker _ticker;
  Duration _lastTime = Duration.zero;
  
  int _rows = 7;
  int _cols = 8;
  
  List<TileModel> _tiles = [];
  List<List<TileModel?>> _grid = [];
  
  TileModel? _selected;
  
  TileModel? _dragStartTile;
  TileModel? _draggedTile;
  Offset _dragDeltaPx = Offset.zero;
  bool _wasDragged = false;
  
  int _hints = 3;
  int _shuffles = 2;
  int _score = 0;
  
  final List<Particle> _particles = [];
  final List<ComboText> _comboTexts = [];
  double _screenShakeTimer = 0;
  
  int _comboCount = 0;
  DateTime? _lastMatchTime;
  
  double _currentTileWidth = 0;
  double _currentTileHeight = 0;
  double _currentPadding = 12.0;

  @override
  void initState() {
    super.initState();
    _rnd = math.Random(widget.config.seed);
    _startTime = DateTime.now();
    _initRound();
    
    _ticker = createTicker((elapsed) {
      if (_lastTime == Duration.zero) _lastTime = elapsed;
      double dt = (elapsed - _lastTime).inMilliseconds / 1000.0;
      _lastTime = elapsed;
      _updateGameLoop(dt);
    });
    _ticker.start();
  }
  
  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _updateGameLoop(double dt) {
    if (_particles.isEmpty && _comboTexts.isEmpty && _screenShakeTimer <= 0) return;
    
    setState(() {
      for (var p in _particles) {
        p.position += p.velocity * dt;
        p.velocity += Offset(0, 500 * dt); 
        p.life -= dt;
      }
      _particles.removeWhere((p) => p.life <= 0);
      
      for (var c in _comboTexts) {
        c.life -= dt;
      }
      _comboTexts.removeWhere((c) => c.life <= 0);
      
      if (_screenShakeTimer > 0) {
        _screenShakeTimer -= dt;
      }
    });
  }

  void _spawnParticles(Offset center) {
    List<Color> colors = [Colors.yellowAccent, Colors.orangeAccent, Colors.white, Colors.lightGreenAccent];
    for (int i = 0; i < 20; i++) {
      double angle = _rnd.nextDouble() * 2 * math.pi;
      double speed = 150 + _rnd.nextDouble() * 250;
      _particles.add(Particle(
        position: center,
        velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
        color: colors[_rnd.nextInt(colors.length)],
        maxLife: 0.4 + _rnd.nextDouble() * 0.4,
        size: 8 + _rnd.nextDouble() * 10,
      ));
    }
  }

  void _spawnComboText(String text) {
    _comboTexts.add(ComboText(text: text, maxLife: 1.2));
  }

  void _initRound() {
    _rows = 7;
    _cols = 8;
    _generateGrid();
  }

  void _generateGrid() {
    int totalTiles = _rows * _cols;
    List<int> animals = [];
    int numAnimals = 15; // Reverted to 15!

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
  
  void _processMatch(TileModel s, TileModel t) {
    _grid[s.r][s.c] = null;
    _grid[t.r][t.c] = null;
    s.isMatched = true;
    t.isMatched = true;
    
    DateTime now = DateTime.now();
    if (_lastMatchTime != null && now.difference(_lastMatchTime!).inSeconds <= 3) {
      _comboCount++;
    } else {
      _comboCount = 1;
    }
    _lastMatchTime = now;
    
    _score += 10 * _comboCount;
    
    double cx1 = _currentPadding + (s.c - 1) * _currentTileWidth + _currentTileWidth / 2;
    double cy1 = _currentPadding + (s.r - 1) * _currentTileHeight + _currentTileHeight / 2;
    double cx2 = _currentPadding + (t.c - 1) * _currentTileWidth + _currentTileWidth / 2;
    double cy2 = _currentPadding + (t.r - 1) * _currentTileHeight + _currentTileHeight / 2;
    
    _spawnParticles(Offset(cx1, cy1));
    _spawnParticles(Offset(cx2, cy2));
    
    if (_comboCount >= 2) {
      _screenShakeTimer = 0.3;
      _spawnComboText("COMBO x$_comboCount!");
    }
    
    _checkWin();
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
            _processMatch(s, t);
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
    int c = ((d.localPosition.dx - padding) / tileWidth).floor() + 1;
    int r = ((d.localPosition.dy - padding) / tileHeight).floor() + 1;
    
    if (r >= 1 && r <= _rows && c >= 1 && c <= _cols && _grid[r][c] != null) {
      _dragStartTile = _grid[r][c];
      _draggedTile = null;
      _dragDeltaPx = Offset.zero;
      _wasDragged = false;
    } else {
      _dragStartTile = null;
    }
  }

  bool _tryMoveTile(TileModel t, int dr, int dc, double tileWidth, double tileHeight) {
    int nextR = t.r + dr;
    int nextC = t.c + dc;
    
    if (nextR < 1 || nextR > _rows || nextC < 1 || nextC > _cols) return false;
    if (_grid[nextR][nextC] != null) return false;
    
    _grid[t.r][t.c] = null;
    t.r = nextR;
    t.c = nextC;
    _grid[t.r][t.c] = t;
    
    _dragDeltaPx -= Offset(dc * tileWidth, dr * tileHeight);
    return true;
  }

  void _onPanUpdate(DragUpdateDetails d, double tileWidth, double tileHeight) {
    if (_dragStartTile == null) return;
    
    setState(() {
      _dragDeltaPx += d.delta;
      if (!_wasDragged && _dragDeltaPx.distance > 5) {
        _draggedTile = _dragStartTile;
        _selected = _dragStartTile;
        _wasDragged = true;
      }
      
      if (_draggedTile == null) return;
      TileModel t = _draggedTile!;
      
      while (_dragDeltaPx.dx > tileWidth * 0.6) {
        if (!_tryMoveTile(t, 0, 1, tileWidth, tileHeight)) break;
      }
      while (_dragDeltaPx.dx < -tileWidth * 0.6) {
        if (!_tryMoveTile(t, 0, -1, tileWidth, tileHeight)) break;
      }
      while (_dragDeltaPx.dy > tileHeight * 0.6) {
        if (!_tryMoveTile(t, 1, 0, tileWidth, tileHeight)) break;
      }
      while (_dragDeltaPx.dy < -tileHeight * 0.6) {
        if (!_tryMoveTile(t, -1, 0, tileWidth, tileHeight)) break;
      }
      
      double dx = _dragDeltaPx.dx;
      double dy = _dragDeltaPx.dy;
      
      bool canGoRight = t.c < _cols && _grid[t.r][t.c + 1] == null;
      bool canGoLeft = t.c > 1 && _grid[t.r][t.c - 1] == null;
      bool canGoDown = t.r < _rows && _grid[t.r + 1][t.c] == null;
      bool canGoUp = t.r > 1 && _grid[t.r - 1][t.c] == null;
      
      if (dx > 0 && !canGoRight) dx = math.min(dx, 0);
      if (dx < 0 && !canGoLeft) dx = math.max(dx, 0);
      if (dy > 0 && !canGoDown) dy = math.min(dy, 0);
      if (dy < 0 && !canGoUp) dy = math.max(dy, 0);
      
      if (dx.abs() > dy.abs()) {
        dy = 0;
      } else {
        dx = 0;
      }
      
      _dragDeltaPx = Offset(dx, dy);
    });
  }

  void _onPanEnd(DragEndDetails d) {
    setState(() {
      _dragStartTile = null;
      _draggedTile = null;
      _dragDeltaPx = Offset.zero;
      _wasDragged = false;
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
                Container(
                  width: 100,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.amberAccent, width: 2),
                  ),
                  child: Column(
                    children: [
                      const Text('SCORE', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                      Text('$_score', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
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
              double maxW = math.max(10.0, constraints.maxWidth - 140);
              double maxH = math.max(10.0, constraints.maxHeight - 40);
              double padding = 12.0;
              
              _currentTileWidth = math.min(math.max(10.0, maxW - padding*2) / _cols, math.max(10.0, maxH - padding*2) / (_rows * 1.25));
              _currentTileHeight = _currentTileWidth * 1.25;
              _currentPadding = padding;
              
              double boardW = _currentTileWidth * _cols + padding * 2;
              double boardH = _currentTileHeight * _rows + padding * 2;
              
              double shakeX = 0;
              double shakeY = 0;
              if (_screenShakeTimer > 0) {
                shakeX = (_rnd.nextDouble() - 0.5) * 15;
                shakeY = (_rnd.nextDouble() - 0.5) * 15;
              }
              
              return Transform.translate(
                offset: Offset(shakeX, shakeY),
                child: Container(
                  width: boardW, height: boardH,
                  color: Colors.transparent, 
                  child: GestureDetector(
                    onPanStart: (d) => _onPanStart(d, _currentTileWidth, _currentTileHeight, padding),
                    onPanUpdate: (d) => _onPanUpdate(d, _currentTileWidth, _currentTileHeight),
                    onPanEnd: _onPanEnd,
                    onTapUp: (d) {
                      if (_wasDragged) return;
                      int c = ((d.localPosition.dx - padding) / _currentTileWidth).floor() + 1;
                      int r = ((d.localPosition.dy - padding) / _currentTileHeight).floor() + 1;
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
                            duration: Duration(milliseconds: (_draggedTile == t) ? 0 : 150),
                            curve: Curves.easeOutQuad,
                            left: padding + (t.c - 1) * _currentTileWidth + (_draggedTile == t ? _dragDeltaPx.dx : 0),
                            top: padding + (t.r - 1) * _currentTileHeight + (_draggedTile == t ? _dragDeltaPx.dy : 0),
                            width: _currentTileWidth,
                            height: _currentTileHeight,
                            child: _buildTile(t, _currentTileWidth, _currentTileHeight),
                          ),
                          
                        if (_particles.isNotEmpty)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: CustomPaint(
                                painter: _ParticlePainter(_particles),
                              ),
                            ),
                          ),
                          
                        if (_comboTexts.isNotEmpty)
                          ..._comboTexts.map((c) {
                            double progress = 1.0 - (c.life / c.maxLife);
                            double scale = 1.0 + math.sin(progress * math.pi) * 0.4;
                            double opacity = c.life > 0.3 ? 1.0 : (c.life / 0.3);
                            return Positioned.fill(
                              child: IgnorePointer(
                                child: Center(
                                  child: Transform.translate(
                                    offset: Offset(c.randomOffset.dx, -100 * progress + c.randomOffset.dy),
                                    child: Opacity(
                                      opacity: opacity,
                                      child: Transform.scale(
                                        scale: scale,
                                        child: Text(
                                          c.text,
                                          style: const TextStyle(
                                            color: Colors.amberAccent,
                                            fontSize: 48,
                                            fontWeight: FontWeight.w900,
                                            shadows: [
                                              Shadow(color: Colors.black, blurRadius: 10, offset: Offset(3, 3)),
                                              Shadow(color: Colors.deepOrange, blurRadius: 20, offset: Offset(0, 0)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
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
      'assets/images/onet_full/tile_${t.animal}.png',
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
              child: Text('$count', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
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

class _ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      Paint paint = Paint()
        ..color = p.color.withValues(alpha: math.max(0.0, p.life / p.maxLife))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(p.position, p.size * (p.life / p.maxLife), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
