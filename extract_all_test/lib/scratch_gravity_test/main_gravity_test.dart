import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(const MaterialApp(
    home: GravityRunnerScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class Obstacle {
  Rect rect;
  bool isDestroyed = false;
  Obstacle(this.rect);
}

enum ItemType { heart, ammo }
class Collectible {
  Rect rect;
  ItemType type;
  bool isCollected = false;
  Collectible(this.rect, this.type);
}

class Bullet {
  double x;
  double y;
  bool active = true;
  Bullet(this.x, this.y);
}

class GravityRunnerScreen extends StatefulWidget {
  const GravityRunnerScreen({Key? key}) : super(key: key);
  @override
  _GravityRunnerScreenState createState() => _GravityRunnerScreenState();
}

class _GravityRunnerScreenState extends State<GravityRunnerScreen> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double playerY = 1.0; 
  double velocityY = 0.0;
  int gravity = 1; 
  double scrollX = 0;
  
  bool isGameOver = false;
  bool isGameWon = false;
  bool hasStarted = false;
  
  double runTime = 0.0;
  double currentSpeed = 3.2; 

  int lives = 3;
  int ammo = 3;
  double invincibilityTimer = 0.0;

  List<Obstacle> obstacles = [];
  List<Collectible> collectibles = [];
  List<Bullet> bullets = [];
  Rect goalRect = Rect.zero;

  Duration? lastTime;

  @override
  void initState() {
    super.initState();
    _generateLevel();
    _ticker = createTicker(_update)..start();
  }

  void _generateLevel() {
    obstacles.clear();
    collectibles.clear();
    bullets.clear();
    
    // Level is 60 seconds long
    double totalDistance = 60.0 * 3.5; 
    double currentX = 10.0;
    Random rnd = Random();
    
    List<ItemType> itemsToSpawn = [
      ItemType.heart, ItemType.heart, ItemType.heart,
      ItemType.ammo, ItemType.ammo, ItemType.ammo
    ];
    itemsToSpawn.shuffle(rnd);

    while (currentX < totalDistance) {
      bool isFloor = rnd.nextBool();
      // Reduced obstacle width to 0.25
      obstacles.add(Obstacle(Rect.fromLTWH(currentX, isFloor ? 0.8 : 0.0, 0.25, 0.2)));
      
      if (itemsToSpawn.isNotEmpty && rnd.nextDouble() < 0.15) {
         bool itemOnFloor = !isFloor; 
         collectibles.add(Collectible(
           Rect.fromLTWH(currentX + 1.5, itemOnFloor ? 0.85 : 0.05, 0.1, 0.1), 
           itemsToSpawn.removeLast()
         ));
      }
      currentX += 1.8 + rnd.nextDouble() * 2.5; // Gap between obstacles
    }
    
    for(var item in itemsToSpawn) {
      collectibles.add(Collectible(Rect.fromLTWH(currentX, rnd.nextBool() ? 0.85 : 0.05, 0.1, 0.1), item));
      currentX += 1.5;
    }

    goalRect = Rect.fromLTWH(totalDistance + 10, 0.0, 0.2, 1.0);
  }

  void _update(Duration elapsed) {
    if (lastTime == null) {
      lastTime = elapsed;
      return;
    }
    double dt = (elapsed.inMicroseconds - lastTime!.inMicroseconds) / 1000000.0;
    lastTime = elapsed;
    if (dt > 0.1) dt = 0.1; 

    if (isGameOver || isGameWon) return;
    if (!hasStarted) return; 

    setState(() {
      runTime += dt;
      currentSpeed = 3.2 + (runTime / 20.0) * 0.5;

      if (invincibilityTimer > 0) {
        invincibilityTimer -= dt;
      }

      velocityY += gravity * 45.0 * dt; 
      playerY += velocityY * dt;

      if (playerY >= 1.0) { playerY = 1.0; velocityY = 0; } 
      else if (playerY <= 0.0) { playerY = 0.0; velocityY = 0; }

      scrollX += currentSpeed * dt;

      Rect playerRect = Rect.fromLTWH(scrollX + 1.0, playerY - (playerY * 0.1), 0.1, 0.1); 

      if (playerRect.overlaps(goalRect)) {
        isGameWon = true;
      }

      for (var obs in obstacles) {
        if (!obs.isDestroyed && playerRect.overlaps(obs.rect)) {
          if (invincibilityTimer <= 0) {
             lives--;
             invincibilityTimer = 1.5; 
             if (lives <= 0) {
                isGameOver = true;
             }
          }
        }
      }

      for (var col in collectibles) {
        if (!col.isCollected && playerRect.overlaps(col.rect)) {
          col.isCollected = true;
          if (col.type == ItemType.heart) {
            lives++;
          } else {
            ammo++;
          }
        }
      }

      for (var b in bullets) {
        if (!b.active) continue;
        b.x += 12.0 * dt; 
        Rect bulletRect = Rect.fromLTWH(b.x, b.y - 0.05, 0.2, 0.1);
        
        for (var obs in obstacles) {
           if (!obs.isDestroyed && bulletRect.overlaps(obs.rect)) {
              obs.isDestroyed = true;
              b.active = false;
              break;
           }
        }
      }
      bullets.removeWhere((b) => !b.active || b.x > scrollX + 20.0);
    });
  }

  void _flipGravity() {
    if (isGameOver || isGameWon) {
      setState(() {
        isGameOver = false; isGameWon = false; hasStarted = false;
        scrollX = 0; playerY = 1.0; gravity = 1; velocityY = 0; runTime = 0;
        lives = 3; ammo = 3; invincibilityTimer = 0.0;
        _generateLevel();
      });
      return;
    }
    setState(() {
      if (!hasStarted) hasStarted = true;
      gravity *= -1;
      velocityY = gravity * 16.0; 
    });
  }

  void _shoot() {
    if (!hasStarted || isGameOver || isGameWon) return;
    if (ammo > 0) {
      setState(() {
        ammo--;
        bullets.add(Bullet(scrollX + 1.1, playerY));
      });
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double unit = size.height * 0.6; 
    double offsetY = size.height * 0.2; 
    double playerScreenX = size.width * 0.2; 
    
    bool isVisible = true;
    if (invincibilityTimer > 0) {
       isVisible = (invincibilityTimer * 10).toInt() % 2 == 0;
    }

    return Scaffold(
      backgroundColor: Colors.black, 
      body: GestureDetector(
        onTap: _flipGravity,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: size.width, height: size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight, end: Alignment.bottomLeft,
              colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)], 
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: size.width * 0.1, top: size.height * 0.1,
                child: Container(
                  width: 150, height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [Colors.orangeAccent, Colors.deepOrange]),
                    boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.5), blurRadius: 40)],
                  ),
                ),
              ),
              Positioned(
                left: 0, right: 0, top: offsetY, height: unit,
                child: Container(
                  color: Colors.black26,
                  child: Stack(
                    children: [
                      for (double x = -((scrollX * unit) % 100); x < size.width; x += 100)
                        Positioned(
                          left: x, top: 0, bottom: 0,
                          child: Container(width: 1, color: Colors.white12),
                        ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0, right: 0, top: offsetY - 5, height: 5,
                child: Container(decoration: BoxDecoration(color: Colors.cyanAccent.withOpacity(0.8), boxShadow: const [BoxShadow(color: Colors.cyanAccent, blurRadius: 10)])),
              ),
              Positioned(
                left: 0, right: 0, top: offsetY + unit, height: 5,
                child: Container(decoration: BoxDecoration(color: Colors.cyanAccent.withOpacity(0.8), boxShadow: const [BoxShadow(color: Colors.cyanAccent, blurRadius: 10)])),
              ),

              for (var b in bullets)
                (() {
                  double screenX = playerScreenX + (b.x - (scrollX + 1.0)) * unit;
                  double screenY = offsetY + b.y * unit - (0.05 * unit);
                  if (screenX > size.width) return const SizedBox.shrink();
                  return Positioned(
                    left: screenX, top: screenY, width: 0.3 * unit, height: 0.05 * unit,
                    child: Container(
                       decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [BoxShadow(color: Colors.yellow, blurRadius: 10)]
                       ),
                    ),
                  );
                })(),

              for (var obs in obstacles)
                if (!obs.isDestroyed)
                  (() {
                    double screenX = playerScreenX + (obs.rect.left - (scrollX + 1.0)) * unit;
                    double screenY = offsetY + obs.rect.top * unit;
                    double screenW = obs.rect.width * unit;
                    double screenH = obs.rect.height * unit;
                    if (screenX + screenW < -50 || screenX > size.width + 50) return const SizedBox.shrink();
                    return Positioned(
                      left: screenX, top: screenY, width: screenW, height: screenH,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.redAccent, Colors.orange],
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.white70, width: 2),
                        ),
                        child: const Center(child: Icon(Icons.warning_amber_rounded, color: Colors.white54, size: 24)),
                      ),
                    );
                  })(),

              (() {
                  double screenX = playerScreenX + (goalRect.left - (scrollX + 1.0)) * unit;
                  if (screenX > size.width + 50) return const SizedBox.shrink();
                  return Positioned(
                    left: screenX, top: offsetY, width: goalRect.width * unit, height: goalRect.height * unit,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.5)),
                      child: const Center(child: Icon(Icons.flag, color: Colors.white, size: 40)),
                    )
                  );
              })(),

              for (var col in collectibles)
                if (!col.isCollected)
                  (() {
                    double screenX = playerScreenX + (col.rect.left - (scrollX + 1.0)) * unit;
                    double screenY = offsetY + col.rect.top * unit;
                    if (screenX + 50 < 0 || screenX > size.width + 50) return const SizedBox.shrink();
                    return Positioned(
                      left: screenX, top: screenY, width: 40, height: 40,
                      child: col.type == ItemType.heart 
                         ? const Icon(Icons.favorite, color: Colors.pinkAccent, size: 30)
                         : const Icon(Icons.flash_on, color: Colors.yellowAccent, size: 30),
                    );
                  })(),

              if (isVisible)
                Positioned(
                  left: playerScreenX,
                  top: offsetY + playerY * unit - (playerY * 0.1 * unit),
                  width: 0.1 * unit, height: 0.1 * unit,
                  child: Transform.scale(
                    scaleY: gravity == 1 ? 1.0 : -1.0, 
                    child: Container(
                      decoration: BoxDecoration(
                        color: isGameOver ? Colors.redAccent : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: isGameOver ? Colors.red : Colors.cyanAccent, blurRadius: 20, spreadRadius: 5)],
                      ),
                      child: Center(
                        child: Icon(
                          isGameOver ? Icons.local_fire_department : Icons.rocket_launch_rounded, 
                          color: isGameOver ? Colors.yellow : Colors.blueAccent, 
                          size: 30
                        ),
                      ),
                    ),
                  ),
                ),

              Positioned(
                top: 20, left: 20,
                child: Row(
                  children: [
                    for(int i=0; i<lives; i++) const Icon(Icons.favorite, color: Colors.pinkAccent, size: 32),
                    const SizedBox(width: 20),
                    for(int i=0; i<ammo; i++) const Icon(Icons.flash_on, color: Colors.yellowAccent, size: 32),
                  ],
                ),
              ),

              if (!hasStarted && !isGameOver && !isGameWon)
                const Center(
                  child: Text(
                    "TAP TO START",
                    style: TextStyle(fontSize: 40, color: Colors.cyanAccent, fontWeight: FontWeight.bold, letterSpacing: 4, shadows: [Shadow(color: Colors.cyan, blurRadius: 15)]),
                  ),
                ),
              if (isGameOver)
                const Center(
                  child: Text(
                    "CRASHED!\nTAP TO RETRY",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 50, color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 4, shadows: [Shadow(color: Colors.red, blurRadius: 15)]),
                  ),
                ),
              if (isGameWon)
                const Center(
                  child: Text(
                    "STAGE CLEARED!\nTAP TO REPLAY",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 50, color: Colors.greenAccent, fontWeight: FontWeight.bold, letterSpacing: 4, shadows: [Shadow(color: Colors.green, blurRadius: 15)]),
                  ),
                ),

              if (hasStarted && !isGameOver && !isGameWon)
                Positioned(
                  bottom: 40, right: 40,
                  child: GestureDetector(
                    onTap: _shoot,
                    child: Container(
                       padding: const EdgeInsets.all(20),
                       decoration: BoxDecoration(
                         color: Colors.orangeAccent.withOpacity(0.8),
                         shape: BoxShape.circle,
                         boxShadow: const [BoxShadow(color: Colors.orange, blurRadius: 10)]
                       ),
                       child: const Icon(Icons.flash_on, color: Colors.white, size: 40),
                    ),
                  ),
                ),
                
              if (hasStarted && !isGameOver && !isGameWon)
                Positioned(
                  top: 30, right: 30,
                  child: Text(
                    "TIME: " + (60.0 - runTime).clamp(0.0, 60.0).toStringAsFixed(1) + "s",
                    style: const TextStyle(color: Colors.amberAccent, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
