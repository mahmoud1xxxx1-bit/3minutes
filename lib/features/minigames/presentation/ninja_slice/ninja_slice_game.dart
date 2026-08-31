// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures, non_constant_identifier_names, empty_catches, library_private_types_in_public_api, no_leading_underscores_for_local_identifiers
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../domain/mini_game_contract.dart';

enum ItemType { apple, watermelon, banana, coconut, glassPlate, freeze, frenzy }

class GameObject {
  double x, y;
  double vx, vy;
  double size;
  ItemType type;
  double rotation = 0;
  double vr = 0;

  GameObject(this.x, this.y, this.vx, this.vy, this.type, this.size) {
    vr = (Random().nextDouble() - 0.5) * 5;
  }
}

class FruitHalf {
  double x, y;
  double vx, vy;
  double size;
  ItemType type;
  bool isLeft;
  double rotation = 0;
  double vr = 0;
  
  FruitHalf(this.x, this.y, this.vx, this.vy, this.type, this.size, this.isLeft) {
    vr = (Random().nextDouble() - 0.5) * 10;
  }
}

class Particle {
  double x, y;
  double vx, vy;
  Color color;
  double size;
  double life = 1.0;
  bool isGlass;
  
  Particle(this.x, this.y, this.vx, this.vy, this.color, this.size, {this.isGlass = false});
}

class Splatter {
  double x, y;
  Color color;
  double size;
  double life = 5.0; // 5 seconds fade
  Splatter(this.x, this.y, this.color, this.size);
}

class FloatingText {
  double x, y;
  String text;
  Color color;
  double life = 1.5;
  FloatingText(this.x, this.y, this.text, this.color);
}

class SwipePoint {
  Offset position;
  double age = 0;
  SwipePoint(this.position);
}

class NinjaSliceGame extends StatefulWidget {
  final MiniGameConfig config;
  final void Function(MiniGameResult) onComplete;

  const NinjaSliceGame({
    super.key,
    required this.config,
    required this.onComplete,
  });

  @override
  _NinjaSliceGameState createState() => _NinjaSliceGameState();
}

class _NinjaSliceGameState extends State<NinjaSliceGame> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  Duration? _lastTime;
  late DateTime startTime;
  
  List<GameObject> activeItems = [];
  List<FruitHalf> halves = [];
  List<Particle> particles = [];
  List<Splatter> splatters = [];
  List<FloatingText> floatingTexts = [];
  List<SwipePoint> swipePoints = [];
  
  int score = 0;
  int strikes = 0;
  bool isGameOver = false;
  bool isVictory = false;
  
  double spawnTimer = 1.0;
  late Random _rnd;
  
  final double baseGravity = 1500.0;

  // New Mechanics & Progression
  double timeScale = 1.0;
  double frenzyTimer = 0.0;
  double frenzySpawnTimer = 0.0;
  double screenShakeTimer = 0.0;

  int currentCombo = 0;
  double comboTimer = 0.0;
  
  // Stats
  int totalSpawned = 0;
  int totalSliced = 0;

  // Progression
  int waveCount = 1;
  double difficultyMultiplier = 1.0;
  
  @override
  void initState() {
    super.initState();
    _rnd = Random(widget.config.seed);
    startTime = DateTime.now();
    _ticker = createTicker(_update)..start();
  }

  void _endGame(bool completed) {
    if (isGameOver) return;
    isGameOver = true;
    isVictory = completed;
    
    double acc = totalSpawned > 0 ? (totalSliced / totalSpawned) : 1.0;
    
    // Slight delay so player sees the last slice/crash
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        widget.onComplete(
          MiniGameResult(
            completed: completed,
            score: score,
            accuracy: acc.clamp(0.0, 1.0),
            mistakes: strikes,
            duration: DateTime.now().difference(startTime),
          )
        );
      }
    });
  }

  void _update(Duration elapsed) {
    if (_lastTime == null) {
      _lastTime = elapsed;
      return;
    }
    double dt = (elapsed.inMicroseconds - _lastTime!.inMicroseconds) / 1000000.0;
    _lastTime = elapsed;
    if (dt > 0.05) dt = 0.05; 

    if (isGameOver) return;

    Size size = MediaQuery.of(context).size;

    setState(() {
      // Logic Timers
      if (timeScale < 1.0) {
        timeScale += dt * 0.15; // slow motion recovers gradually
        if (timeScale > 1.0) timeScale = 1.0;
      }
      
      if (screenShakeTimer > 0) {
        screenShakeTimer -= dt;
      }

      if (comboTimer > 0) {
        comboTimer -= dt;
        if (comboTimer <= 0) {
          if (currentCombo >= 3) {
            floatingTexts.add(FloatingText(size.width/2, size.height/2, "COMBO x$currentCombo!", Colors.orangeAccent));
            score += currentCombo * 5; // Bonus points
          }
          currentCombo = 0;
        }
      }

      // Frenzy Mode Spawning
      if (frenzyTimer > 0) {
        frenzyTimer -= dt;
        frenzySpawnTimer -= dt;
        if (frenzySpawnTimer <= 0) {
          _spawnFrenzyFruit(size);
          frenzySpawnTimer = 0.15; // spawn very rapidly
        }
      }

      // Progression Spawn Logic
      spawnTimer -= dt * timeScale;
      if (spawnTimer <= 0 && frenzyTimer <= 0) {
        _spawnWave(size);
        
        // Progression System
        waveCount++;
        if (waveCount % 3 == 0) {
           difficultyMultiplier += 0.25;
        }
        
        if (difficultyMultiplier >= 5.0) {
           // VICTORY! Max difficulty survived
           _endGame(true);
           return;
        }

        // Wait time decreases as difficulty increases
        double waitTime = (1.0 + _rnd.nextDouble() * 2.0) / difficultyMultiplier;
        spawnTimer = waitTime.clamp(0.5, 3.0);
      }

      double currentGravity = baseGravity * (1.0 + (difficultyMultiplier - 1.0) * 0.2);

      // Update Items
      for (int i = activeItems.length - 1; i >= 0; i--) {
        var item = activeItems[i];
        item.x += item.vx * dt * timeScale;
        item.y += item.vy * dt * timeScale;
        item.vy += currentGravity * dt * timeScale;
        item.rotation += item.vr * dt * timeScale;
        
        if (item.y > size.height + 100 && item.vy > 0) {
          // DO NOT penalize dropped fruits per user request
          activeItems.removeAt(i);
        }
      }

      // Update Halves
      for (int i = halves.length - 1; i >= 0; i--) {
        var half = halves[i];
        half.x += half.vx * dt * timeScale;
        half.y += half.vy * dt * timeScale;
        half.vy += currentGravity * dt * timeScale;
        half.rotation += half.vr * dt * timeScale;
        if (half.y > size.height + 100) halves.removeAt(i);
      }

      // Update Particles
      for (int i = particles.length - 1; i >= 0; i--) {
        var p = particles[i];
        p.x += p.vx * dt * timeScale;
        p.y += p.vy * dt * timeScale;
        p.vy += currentGravity * dt * timeScale;
        p.life -= dt * 1.5 * timeScale; 
        if (p.life <= 0) particles.removeAt(i);
      }

      // Update Splatters
      for (int i = splatters.length - 1; i >= 0; i--) {
        splatters[i].life -= dt;
        if (splatters[i].life <= 0) splatters.removeAt(i);
      }

      // Update Floating Texts
      for (int i = floatingTexts.length - 1; i >= 0; i--) {
        floatingTexts[i].life -= dt;
        floatingTexts[i].y -= 30 * dt; 
        if (floatingTexts[i].life <= 0) floatingTexts.removeAt(i);
      }

      // Update Swipe Trail
      for (int i = swipePoints.length - 1; i >= 0; i--) {
        swipePoints[i].age += dt;
        if (swipePoints[i].age > 0.15) swipePoints.removeAt(i);
      }
    });
  }

  void _spawnWave(Size size) {
    int numItems = 2 + _rnd.nextInt(3 + difficultyMultiplier.toInt().clamp(1, 5)); 
    for (int i = 0; i < numItems; i++) {
      double startX = size.width * 0.15 + _rnd.nextDouble() * (size.width * 0.7);
      double startY = size.height + 50;
      double vx = (size.width / 2 - startX) * 1.2 + (_rnd.nextDouble() - 0.5) * 200 * difficultyMultiplier;
      
      double targetY = size.height * 0.1 + _rnd.nextDouble() * (size.height * 0.3);
      double dropDistance = startY - targetY;
      double currentGravity = baseGravity * (1.0 + (difficultyMultiplier - 1.0) * 0.2);
      double vy = -sqrt(2 * currentGravity * dropDistance);
      
      ItemType type = ItemType.values[_rnd.nextInt(4)]; 
      
      // Bomb probability drastically scaled up to deceive the player
      double bombChance = 0.05 + (difficultyMultiplier * 0.05); // Much higher plate ratio
      
      if (_rnd.nextDouble() < bombChance.clamp(0.0, 0.85)) {
        type = ItemType.glassPlate;
      } else if (score > 50 && _rnd.nextDouble() < 0.05) {
        type = ItemType.freeze;
      } else if (score > 100 && _rnd.nextDouble() < 0.05) {
        type = ItemType.frenzy;
      }
      
      if (type != ItemType.glassPlate) totalSpawned++;

      activeItems.add(GameObject(startX, startY, vx, vy, type, type == ItemType.glassPlate ? 90.0 : 80.0));
      
      // Deception trick: if we spawn a fruit, maybe spawn a plate extremely close to it immediately!
      if (type != ItemType.glassPlate && _rnd.nextDouble() < 0.05) {
         activeItems.add(GameObject(startX + (_rnd.nextBool() ? 40 : -40), startY + 20, vx + (_rnd.nextBool() ? 20 : -20), vy, ItemType.glassPlate, 90.0));
      }
    }
  }

  void _spawnFrenzyFruit(Size size) {
    double startX = _rnd.nextBool() ? -50 : size.width + 50;
    double startY = size.height * 0.3 + _rnd.nextDouble() * (size.height * 0.5);
    double vx = startX < 0 ? 300.0 + _rnd.nextDouble()*200 : -300.0 - _rnd.nextDouble()*200;
    double vy = -400.0 - _rnd.nextDouble() * 400;
    
    ItemType type = ItemType.values[_rnd.nextInt(4)];
    totalSpawned++;
    activeItems.add(GameObject(startX, startY, vx, vy, type, 70.0));
  }

  void _onPanStart(DragStartDetails details) {
    if (isGameOver) return;
    swipePoints.clear();
    swipePoints.add(SwipePoint(details.localPosition));
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (isGameOver) return;
    Offset currentPos = details.localPosition;
    
    if (swipePoints.isNotEmpty) {
      Offset lastPos = swipePoints.last.position;
      _checkSlices(lastPos, currentPos);
    }
    
    swipePoints.add(SwipePoint(currentPos));
  }

  void _onPanEnd(DragEndDetails details) {
    if (currentCombo > 0 && currentCombo < 3) {
       currentCombo = 0;
       comboTimer = 0;
    }
  }
  
  void _checkSlices(Offset p1, Offset p2) {
    for (int i = activeItems.length - 1; i >= 0; i--) {
      var item = activeItems[i];
      Rect bounds = Rect.fromCenter(center: Offset(item.x, item.y), width: item.size, height: item.size);
      
      if (_lineIntersectsRect(p1, p2, bounds)) {
        if (item.type == ItemType.glassPlate) {
          _shatterGlass(item);
          strikes++;
          screenShakeTimer = 0.5; // SCREEN SHAKE!
          currentCombo = 0;
          if (strikes >= 3) _endGame(false); // DEFEAT
        } else {
          score += 10;
          totalSliced++;
          currentCombo++;
          comboTimer = 0.5;
          
          if (item.type == ItemType.freeze) {
            timeScale = 0.2; // FREEZE!
            floatingTexts.add(FloatingText(item.x, item.y, "FREEZE!", Colors.lightBlueAccent));
          } else if (item.type == ItemType.frenzy) {
            frenzyTimer = 5.0; // FRENZY!
            floatingTexts.add(FloatingText(item.x, item.y, "FRENZY!", Colors.yellowAccent));
          } else {
             floatingTexts.add(FloatingText(item.x, item.y, "+10", Colors.white70));
          }
          
          _splitFruit(item);
        }
        activeItems.removeAt(i);
      }
    }
  }
  
  void _splitFruit(GameObject item) {
    halves.add(FruitHalf(item.x - 10, item.y, item.vx - 100, item.vy, item.type, item.size, true)..rotation = item.rotation);
    halves.add(FruitHalf(item.x + 10, item.y, item.vx + 100, item.vy, item.type, item.size, false)..rotation = item.rotation);
    
    Color juiceColor = Colors.redAccent;
    if (item.type == ItemType.banana) juiceColor = Colors.yellowAccent;
    if (item.type == ItemType.coconut) juiceColor = Colors.white;
    if (item.type == ItemType.freeze) juiceColor = Colors.cyanAccent;
    if (item.type == ItemType.frenzy) juiceColor = Colors.orangeAccent;
    
    splatters.add(Splatter(item.x, item.y, juiceColor, 60.0 + _rnd.nextDouble() * 40.0));

    for (int i = 0; i < 12; i++) {
      particles.add(Particle(
        item.x, item.y,
        item.vx * 0.5 + (_rnd.nextDouble() - 0.5) * 400,
        item.vy * 0.5 + (_rnd.nextDouble() - 0.5) * 400,
        juiceColor,
        6.0 + _rnd.nextDouble() * 10.0
      ));
    }
  }

  void _shatterGlass(GameObject item) {
    for (int i = 0; i < 20; i++) {
      particles.add(Particle(
        item.x, item.y,
        item.vx * 0.2 + (_rnd.nextDouble() - 0.5) * 800,
        item.vy * 0.2 + (_rnd.nextDouble() - 0.5) * 800,
        Colors.cyanAccent.withValues(alpha: 0.9),
        15.0 + _rnd.nextDouble() * 25.0,
        isGlass: true
      ));
    }
  }

  bool _lineIntersectsRect(Offset a, Offset b, Rect r) {
    if (r.contains(a) || r.contains(b)) return true;
    if (_lineIntersectsLine(a, b, r.topLeft, r.topRight)) return true;
    if (_lineIntersectsLine(a, b, r.topRight, r.bottomRight)) return true;
    if (_lineIntersectsLine(a, b, r.bottomRight, r.bottomLeft)) return true;
    if (_lineIntersectsLine(a, b, r.bottomLeft, r.topLeft)) return true;
    return false;
  }

  bool _lineIntersectsLine(Offset p1, Offset p2, Offset p3, Offset p4) {
    double denominator = (p4.dy - p3.dy) * (p2.dx - p1.dx) - (p4.dx - p3.dx) * (p2.dy - p1.dy);
    if (denominator == 0) return false;
    double ua = ((p4.dx - p3.dx) * (p1.dy - p3.dy) - (p4.dy - p3.dy) * (p1.dx - p3.dx)) / denominator;
    double ub = ((p2.dx - p1.dx) * (p1.dy - p3.dy) - (p2.dy - p1.dy) * (p1.dx - p3.dx)) / denominator;
    return (ua >= 0 && ua <= 1 && ub >= 0 && ub <= 1);
  }

  String _getEmoji(ItemType type) {
    switch (type) {
      case ItemType.apple: return '🍎';
      case ItemType.watermelon: return '🍉';
      case ItemType.banana: return '🍌';
      case ItemType.coconut: return '🥥';
      case ItemType.freeze: return '🧊';
      case ItemType.frenzy: return '🌟';
      default: return '';
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Offset shakeOffset = Offset.zero;
    if (screenShakeTimer > 0) {
      shakeOffset = Offset((_rnd.nextDouble() - 0.5) * 30, (_rnd.nextDouble() - 0.5) * 30);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29), 
      body: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        behavior: HitTestBehavior.opaque,
        child: Transform.translate(
          offset: shakeOffset,
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)]
                    )
                  ),
                )
              ),
              
              Positioned.fill(child: CustomPaint(painter: BackgroundPainter())),

              for (var s in splatters)
                Positioned(
                  left: s.x - s.size/2, top: s.y - s.size/2,
                  child: Opacity(
                    opacity: (s.life / 5.0).clamp(0.0, 1.0) * 0.6,
                    child: Container(
                      width: s.size, height: s.size,
                      decoration: BoxDecoration(
                        color: s.color,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: s.color, blurRadius: 20, spreadRadius: 10)]
                      ),
                    ),
                  ),
                ),
              
              for (var p in particles)
                Positioned(
                  left: p.x - p.size/2, top: p.y - p.size/2,
                  child: Opacity(
                    opacity: p.life.clamp(0.0, 1.0),
                    child: p.isGlass 
                      ? Transform.rotate(
                          angle: p.vx * p.life,
                          child: Icon(Icons.change_history, color: p.color, size: p.size)
                        )
                      : Container(
                          width: p.size, height: p.size,
                          decoration: BoxDecoration(color: p.color, shape: BoxShape.circle),
                        ),
                  ),
                ),

              for (var half in halves)
                Positioned(
                  left: half.x - half.size/2, top: half.y - half.size/2,
                  width: half.size, height: half.size,
                  child: Transform.rotate(
                    angle: half.rotation,
                    child: ClipRect(
                      clipper: HalfClipper(half.isLeft),
                      child: Center(
                        child: Text(_getEmoji(half.type), style: TextStyle(fontSize: half.size * 0.8)),
                      ),
                    ),
                  ),
                ),

              for (var item in activeItems)
                Positioned(
                  left: item.x - item.size/2, top: item.y - item.size/2,
                  width: item.size, height: item.size,
                  child: Transform.rotate(
                    angle: item.rotation,
                    child: item.type == ItemType.glassPlate
                      ? CustomPaint(painter: GlassPlatePainter())
                      : Center(
                          child: Text(_getEmoji(item.type), style: TextStyle(fontSize: item.size * 0.8)),
                        ),
                  ),
                ),

              Positioned.fill(child: CustomPaint(painter: SwipePainter(swipePoints))),

              if (screenShakeTimer > 0)
                Positioned.fill(child: Container(color: Colors.redAccent.withValues(alpha: 0.4))),
                
              for (var ft in floatingTexts)
                Positioned(
                  left: ft.x - 100, top: ft.y - 20,
                  width: 200, height: 40,
                  child: Opacity(
                    opacity: (ft.life / 1.5).clamp(0.0, 1.0),
                    child: Center(
                      child: Text(
                        ft.text,
                        style: TextStyle(
                          color: ft.color, fontSize: 32, fontWeight: FontWeight.bold,
                          shadows: [Shadow(color: ft.color, blurRadius: 15)]
                        ),
                      ),
                    ),
                  ),
                ),
              
              Positioned(
                top: 40, left: 20,
                child: Text(
                  "SCORE: $score\nDIFF: ${difficultyMultiplier}x",
                  style: const TextStyle(color: Colors.cyanAccent, fontSize: 24, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.cyan, blurRadius: 10)]),
                ),
              ),
              
              Positioned(
                top: 40, right: 20,
                child: Row(
                  children: [
                    for (int i=0; i<3; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Icon(
                          i < (3 - strikes) ? Icons.favorite : Icons.favorite_border,
                          color: i < (3 - strikes) ? Colors.pinkAccent : Colors.white54,
                          size: 40,
                        ),
                      ),
                  ],
                ),
              ),

              if (isGameOver)
                Center(
                  child: Text(
                    isVictory ? "STAGE CLEARED!" : "GAME OVER",
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: isVictory ? Colors.greenAccent : Colors.redAccent,
                      shadows: [Shadow(color: isVictory ? Colors.green : Colors.red, blurRadius: 20)],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class HalfClipper extends CustomClipper<Rect> {
  final bool isLeft;
  HalfClipper(this.isLeft);

  @override
  Rect getClip(Size size) {
    if (isLeft) {
      return Rect.fromLTRB(0, 0, size.width / 2, size.height);
    } else {
      return Rect.fromLTRB(size.width / 2, 0, size.width, size.height);
    }
  }
  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => true;
}

class GlassPlatePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.cyanAccent.withValues(alpha: 0.3)..style = PaintingStyle.fill;
    Paint borderPaint = Paint()..color = Colors.cyanAccent.withValues(alpha: 0.8)..style = PaintingStyle.stroke..strokeWidth = 3;
    Rect ovalRect = Rect.fromCenter(center: Offset(size.width/2, size.height/2), width: size.width * 0.9, height: size.height * 0.6);
    canvas.drawOval(ovalRect, paint);
    canvas.drawOval(ovalRect, borderPaint);
    Paint shinePaint = Paint()..color = Colors.white.withValues(alpha: 0.6)..style = PaintingStyle.stroke..strokeWidth = 4..strokeCap = StrokeCap.round;
    canvas.drawArc(ovalRect, -pi/4, -pi/3, false, shinePaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SwipePainter extends CustomPainter {
  final List<SwipePoint> points;
  SwipePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    for (int i = 0; i < points.length - 1; i++) {
      double life = 1.0 - (points[i].age / 0.15);
      if (life < 0) life = 0;
      Paint glowPaint = Paint()..color = Colors.cyanAccent.withValues(alpha: life * 0.6)..strokeWidth = 20.0 * life..strokeCap = StrokeCap.round;
      Paint corePaint = Paint()..color = Colors.white.withValues(alpha: life)..strokeWidth = 6.0 * life..strokeCap = StrokeCap.round;
      canvas.drawLine(points[i].position, points[i+1].position, glowPaint);
      canvas.drawLine(points[i].position, points[i+1].position, corePaint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint linePaint = Paint()..color = Colors.white12..strokeWidth = 1.0;
    for (double x = 0; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}




