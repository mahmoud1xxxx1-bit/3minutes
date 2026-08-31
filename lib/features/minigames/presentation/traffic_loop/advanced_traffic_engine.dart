// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures, non_constant_identifier_names, empty_catches, library_private_types_in_public_api, no_leading_underscores_for_local_identifiers
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

enum CarLane { entrance, loop }
enum CarType { player, obstacle }

class Car {
  Car({
    required this.id,
    required this.color,
    required this.type,
    required this.lane,
    required this.s,
    required this.velocity,
  });

  final int id;
  final Color color;
  final CarType type;
  CarLane lane;
  
  double s;
  double velocity;
  
  Offset position = Offset.zero;
  double heading = 0.0;
  
  bool isMerging = false;
  bool counted = false;
  double brakeAlpha = 0.0;
  double positionError = 0.0;
  bool isBraking = false;
  bool isCrashed = false;
  bool hasTriggeredNearMiss = false;
}

class DestroyedCar {
  DestroyedCar({
    required this.position, 
    required this.heading, 
    required this.color,
    required this.velocity,
    required this.spinVelocity,
  });
  Offset position;
  double heading;
  Color color;
  Offset velocity;
  double spinVelocity;
}

class Particle {
  Particle({required this.position, required this.velocity, required this.color});
  Offset position;
  Offset velocity;
  Color color;
}

class SkidMark {
  SkidMark(this.position, this.heading, this.alpha);
  final Offset position;
  final double heading;
  final double alpha;
}

class WeatherParticle {
  WeatherParticle(this.position, this.velocity, this.color, this.size);
  Offset position;
  Offset velocity;
  Color color;
  double size;
}

class FlawlessTrafficEngine {
  FlawlessTrafficEngine({required this.goal, required this.seed, required this.trackId, required this.round}) {
    _random = Random(seed);
    _initPaths();
    _spawnObstacles();
    _spawnQueue();
  }

  final int goal;
  final int seed;
  final int trackId;
  final int round; 
  late final Random _random;

  late Path loopPath;
  late Path entrancePath;
  late PathMetric loopMetric;
  late PathMetric entranceMetric;
  late double stopLineS;
  late double mergeLoopS;
  double cameraZoom = 1.0;

  final List<Car> cars = [];
  final List<DestroyedCar> destroyedCars = [];
  final List<Particle> particles = [];
  final List<SkidMark> skids = [];
  final List<WeatherParticle> weather = [];

  double nearMissTimer = 0.0;
  double grayscaleFraction = 0.0;
  double grayscaleTimer = 0.0;
  int crashCount = 0;
  
  double totalTime = 0.0;
  double lastMergeTime = -10.0;
  int comboCount = 0;
  double comboTimer = 0.0;

  bool get isCrashed => grayscaleTimer > 0; // The game is considered in "cinematic mode" when timer > 0
  int correct = 0;
  int mistakes = 0;
  int _carIdCounter = 0;
  
  double crashFlash = 0.0;
  double lineGlow = 0.0;
  Color lineGlowColor = Colors.blueAccent;
  
  double get idm_v0 {
    if (round == 1) return 220.0;
    if (round == 2) return 245.0;
    return 270.0;
  }
  
  final double idm_T = 0.6;
  final double idm_a = 600.0;
  final double idm_b = 600.0;
  final double idm_s0 = 55.0;
  final double hitRadius = 14.0; 

  void _initPaths() {
    Path baseLoop;
    if (trackId == 1) {
      baseLoop = Path()..addRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: const Offset(400, 250), width: 400, height: 200), const Radius.circular(100)));
    } else if (trackId == 2) {
      baseLoop = Path()..addRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: const Offset(400, 250), width: 600, height: 150), const Radius.circular(75)));
    } else if (trackId == 3) {
      baseLoop = Path()..addOval(Rect.fromCenter(center: const Offset(400, 250), width: 300, height: 300));
    } else if (trackId == 4) {
      // Flawless Infinity (Figure-8)
      baseLoop = Path()
        ..moveTo(400, 250)
        ..cubicTo(450, 50, 650, 50, 650, 250)
        ..cubicTo(650, 450, 450, 450, 400, 250)
        ..cubicTo(350, 50, 150, 50, 150, 250)
        ..cubicTo(150, 450, 350, 450, 400, 250);
    } else if (trackId == 5) {
      // Smooth Kidney Bean Shape (No sharp corners)
      baseLoop = Path()
        ..moveTo(250, 150)
        ..cubicTo(400, 150, 400, 250, 550, 250)
        ..arcToPoint(const Offset(550, 400), radius: const Radius.circular(75), clockwise: true)
        ..cubicTo(400, 400, 400, 300, 250, 300)
        ..arcToPoint(const Offset(250, 150), radius: const Radius.circular(75), clockwise: true);
    } else if (trackId == 6) {
      // 6: Massive Smooth Rounded Triangle
      baseLoop = Path()
        ..moveTo(400, 50) 
        ..cubicTo(650, 50, 700, 250, 600, 400) 
        ..cubicTo(500, 550, 300, 550, 200, 400) 
        ..cubicTo(100, 250, 150, 50, 400, 50); 
    } else if (trackId == 7) {
      // 7: Massive Smooth Diamond / Kite
      baseLoop = Path()
        ..moveTo(400, 50) 
        ..cubicTo(600, 50, 750, 200, 750, 250) 
        ..cubicTo(750, 300, 600, 450, 400, 450) 
        ..cubicTo(200, 450, 50, 300, 50, 250) 
        ..cubicTo(50, 200, 200, 50, 400, 50); 
    } else if (trackId == 8) {
      // 8: Massive Bell / Trapezoid (Open and smooth)
      baseLoop = Path()
        ..moveTo(400, 450) 
        ..cubicTo(700, 450, 750, 450, 700, 300) 
        ..cubicTo(650, 150, 550, 100, 400, 100) 
        ..cubicTo(250, 100, 150, 150, 100, 300) 
        ..cubicTo(50, 450, 100, 450, 400, 450); 
    } else if (trackId == 9) {
      // 9: Massive Dome / Arch (Open and smooth)
      baseLoop = Path()
        ..moveTo(400, 450) 
        ..cubicTo(600, 450, 700, 450, 700, 300) 
        ..cubicTo(700, 100, 600, 100, 400, 100) 
        ..cubicTo(200, 100, 100, 100, 100, 300) 
        ..cubicTo(100, 450, 200, 450, 400, 450); 
    } else if (trackId == 10) {
      // 10: Massive Egg (Track of the Future)
      baseLoop = Path()
        ..moveTo(400, 50) 
        ..cubicTo(600, 50, 750, 300, 650, 450) 
        ..cubicTo(550, 600, 250, 600, 150, 450) 
        ..cubicTo(50, 300, 200, 50, 400, 50); 
    } else if (trackId == 11) {
      // 11: Massive Rounded Hexagon
      baseLoop = Path()
        ..moveTo(250, 450)
        ..cubicTo(400, 450, 400, 450, 550, 450) 
        ..cubicTo(700, 450, 750, 350, 750, 250) 
        ..cubicTo(750, 150, 700, 50, 550, 50) 
        ..cubicTo(400, 50, 400, 50, 250, 50) 
        ..cubicTo(100, 50, 50, 150, 50, 250) 
        ..cubicTo(50, 350, 100, 450, 250, 450); 
    } else if (trackId == 12) {
      // 12: Massive Rounded Teardrop (Guitar Pick)
      baseLoop = Path()
        ..moveTo(400, 450)
        ..cubicTo(750, 450, 750, 250, 500, 100)
        ..cubicTo(450, 70, 350, 70, 300, 100)
        ..cubicTo(50, 250, 50, 450, 400, 450);
    } else if (trackId == 13) {
      // 13: Massive Hourglass / Bone
      baseLoop = Path()
        ..moveTo(400, 350) 
        ..cubicTo(500, 350, 550, 450, 650, 450)
        ..cubicTo(800, 450, 800, 50, 650, 50)
        ..cubicTo(550, 50, 500, 150, 400, 150) 
        ..cubicTo(300, 150, 250, 50, 150, 50)
        ..cubicTo(0, 50, 0, 450, 150, 450)
        ..cubicTo(250, 450, 300, 350, 400, 350);
    } else if (trackId == 14) {
      // 14: Massive Crescent Moon (Banana)
      baseLoop = Path()
        ..moveTo(400, 450) 
        ..cubicTo(700, 450, 750, 250, 700, 150) 
        ..cubicTo(650, 50, 550, 250, 400, 250) 
        ..cubicTo(250, 250, 150, 50, 100, 150) 
        ..cubicTo(50, 250, 100, 450, 400, 450); 
    } else if (trackId == 15) {
      // 15: Massive Squircle (Super-ellipse)
      baseLoop = Path()
        ..moveTo(400, 450)
        ..cubicTo(650, 450, 750, 400, 750, 250)
        ..cubicTo(750, 100, 650, 50, 400, 50)
        ..cubicTo(150, 50, 50, 100, 50, 250)
        ..cubicTo(50, 400, 150, 450, 400, 450);
    } else if (trackId == 16) {
      // 16: Massive Shield
      baseLoop = Path()
        ..moveTo(400, 450) 
        ..cubicTo(600, 450, 700, 300, 700, 150) 
        ..cubicTo(700, 50, 600, 50, 400, 50) 
        ..cubicTo(200, 50, 100, 50, 100, 150) 
        ..cubicTo(100, 300, 200, 450, 400, 450); 
    } else if (trackId == 17) {
      // 17: Massive Indented Triangle (Heart/Bat)
      baseLoop = Path()
        ..moveTo(400, 450) 
        ..cubicTo(600, 450, 600, 400, 700, 350) 
        ..cubicTo(800, 300, 700, 100, 600, 100) 
        ..cubicTo(500, 100, 450, 200, 400, 200) 
        ..cubicTo(350, 200, 300, 100, 200, 100) 
        ..cubicTo(100, 100, 0, 300, 100, 350) 
        ..cubicTo(200, 400, 200, 450, 400, 450); 
    } else if (trackId == 18) {
      // 18: Massive Diagonal Drop
      baseLoop = Path()
        ..moveTo(400, 450)
        ..cubicTo(700, 450, 750, 350, 700, 200) 
        ..cubicTo(650, 50, 250, 50, 150, 150) 
        ..cubicTo(50, 250, 100, 450, 400, 450); 
    } else if (trackId == 19) {
      // 19: Asymmetric Peaks
      baseLoop = Path()
        ..moveTo(400, 450)
        ..cubicTo(550, 450, 650, 450, 700, 350)
        ..cubicTo(750, 250, 700, 150, 600, 150) 
        ..cubicTo(500, 150, 450, 250, 400, 250) 
        ..cubicTo(350, 250, 300, 50, 200, 50) 
        ..cubicTo(100, 50, 50, 250, 100, 350)
        ..cubicTo(150, 450, 250, 450, 400, 450);
    } else {
      // 20: Massive Cloud
      baseLoop = Path()
        ..moveTo(400, 450) 
        ..cubicTo(600, 450, 700, 450, 700, 300) 
        ..cubicTo(700, 150, 600, 150, 550, 200) 
        ..cubicTo(500, 250, 450, 250, 400, 150) 
        ..cubicTo(350, 50, 250, 50, 200, 150) 
        ..cubicTo(150, 250, 100, 250, 100, 300) 
        ..cubicTo(100, 350, 200, 450, 400, 450); 
    }

    double baseP = baseLoop.computeMetrics().first.length;
    int extraSpace = round == 1 ? 10 : 16;
    double targetP = (5 + goal + extraSpace) * 55.0;
    double scale = targetP / baseP;

    Matrix4 matrix = Matrix4.identity()
      ..translate(400.0, 250.0)
      ..scale(scale, scale)
      ..translate(-400.0, -250.0);

    loopPath = baseLoop.transform(matrix.storage);
    loopMetric = loopPath.computeMetrics().first;

    double maxBottomY = 0.0;
    double trackAngleAtMerge = 0.0;
    for(double ts = 0; ts < loopMetric.length; ts += 2.0) {
       Tangent t = loopMetric.getTangentForOffset(ts)!;
       Offset p = t.position;
       if ((p.dx - 400).abs() < 25.0 && p.dy > maxBottomY) {
          maxBottomY = p.dy;
          trackAngleAtMerge = t.vector.direction;
       }
    }

    bool mergeRight = cos(trackAngleAtMerge) > 0;

    entrancePath = Path();
    if (mergeRight) {
      entrancePath
        ..moveTo(320, maxBottomY + 300)
        ..lineTo(320, maxBottomY + 80)
        ..cubicTo(320, maxBottomY + 40, 355, maxBottomY, 400, maxBottomY);
    } else {
      entrancePath
        ..moveTo(480, maxBottomY + 300)
        ..lineTo(480, maxBottomY + 80)
        ..cubicTo(480, maxBottomY + 40, 445, maxBottomY, 400, maxBottomY); 
    }

    entranceMetric = entrancePath.computeMetrics().first;
    stopLineS = entranceMetric.length - 110.0;

    Rect loopBounds = loopPath.getBounds();
    
    double maxW = 760.0; // Max width allowed on 800px screen
    double maxH = 480.0; // Max height allowed on 600px screen
    
    double zoomX = maxW / loopBounds.width;
    double zoomY = maxH / loopBounds.height;
    cameraZoom = min(1.0, min(zoomX, zoomY));

    double minDst = double.infinity;
    for (double ts = 0; ts < loopMetric.length; ts += 1.0) {
      double d = (loopMetric.getTangentForOffset(ts)!.position - entranceMetric.getTangentForOffset(entranceMetric.length)!.position).distance;
      if (d < minDst) {
        minDst = d;
        mergeLoopS = ts;
      }
    }
  }

  void _spawnObstacles() {
    int obstacleCount = 5; 
    
    List<Color> obsColors;
    if (round == 1) {
      obsColors = [const Color(0xFFFFFF00), const Color(0xFFFFB300)];
    } else if (round == 2) obsColors = [const Color(0xFF00FFCC), const Color(0xFF00FF66)];
    else obsColors = [const Color(0xFFFF0055), const Color(0xFFFF0000)];

    double spacing = loopMetric.length / obstacleCount;
    for (int i = 0; i < obstacleCount; i++) {
      double startS = (i * spacing) + _random.nextDouble() * 20.0;
      final tangent = loopMetric.getTangentForOffset(startS)!;
      cars.add(Car(
        id: ++_carIdCounter,
        color: obsColors[_random.nextInt(obsColors.length)],
        type: CarType.obstacle,
        lane: CarLane.loop,
        s: startS,
        velocity: idm_v0,
      )..position = tangent.position
       ..heading = tangent.angle);
    }
  }

  void _spawnQueue() {
    List<Color> playerColors;
    if (round == 1) {
      playerColors = [const Color(0xFF00AAFF), const Color(0xFF00FFFF)];
    } else if (round == 2) playerColors = [const Color(0xFFFF00FF), const Color(0xFFAA00FF)];
    else playerColors = [const Color(0xFFFFFFFF), const Color(0xFFCCCCCC)];

    int queueCount = cars.where((c) => c.lane == CarLane.entrance).length;
    for (int i = queueCount; i < 5; i++) {
      double startS = max(0.0, stopLineS - (i * idm_s0));
      final tangent = entranceMetric.getTangentForOffset(startS)!;
      cars.add(Car(
        id: ++_carIdCounter,
        color: playerColors[_random.nextInt(playerColors.length)],
        type: CarType.player,
        lane: CarLane.entrance,
        s: startS,
        velocity: 0.0,
      )..position = tangent.position
       ..heading = tangent.angle);
    }
  }

  bool tap() {
    if (correct >= goal) return false;
    
    Car? frontCar;
    double maxS = -1.0;
    for (var c in cars) {
      if (c.lane == CarLane.entrance && c.s > maxS) {
        maxS = c.s;
        frontCar = c;
      }
    }
    
    if (frontCar != null && !frontCar.isMerging) {
      frontCar.isMerging = true;
      return true;
    }
    return false;
  }

  Car? _getLeadCar(Car car) {
    if (car.lane == CarLane.loop) return null;

    Car? lead;
    double minGap = double.infinity;
    
    for (var other in cars) {
      if (other.id == car.id) continue;
      if (other.lane != CarLane.entrance) continue;
      
      double gap = other.s - car.s;
      if (gap > 0.1 && gap < minGap) {
        minGap = gap;
        lead = other;
      }
    }
    return lead;
  }

  void _addSkidMark(Offset pos, double heading, double alpha) {
    if (skids.isEmpty || (skids.last.position - pos).distance > 8.0) {
      skids.add(SkidMark(pos, heading, alpha));
      if (skids.length > 500) skids.removeAt(0); 
    }
  }

  void update(double dt) {
    if (dt > 0.05) dt = 0.05;

    double simDt = grayscaleTimer > 0 ? dt * 0.40 : dt;

    for (var w in weather) {
      w.position += w.velocity * simDt;
    }
    weather.removeWhere((w) => w.position.dx < -100 || w.position.dx > 900 || w.position.dy < -100 || w.position.dy > 700);
    
    while (weather.length < 30) {
      if (trackId <= 5) {
        weather.add(WeatherParticle(Offset(_random.nextDouble() * 1000 - 100, -50), Offset(-50 - _random.nextDouble() * 50, 200 + _random.nextDouble() * 200), Colors.white.withValues(alpha: 0.3), 1.0));
      } else if (trackId <= 10) {
        weather.add(WeatherParticle(Offset(_random.nextDouble() * 1000 - 100, _random.nextDouble() * 800 - 100), Offset((_random.nextDouble() - 0.5) * 20, (_random.nextDouble() - 0.5) * 20), Colors.purpleAccent.withValues(alpha: 0.4), 1.0 + _random.nextDouble() * 2.0));
      } else if (trackId <= 15) {
        weather.add(WeatherParticle(Offset(_random.nextDouble() * 1000 - 100, 650), Offset((_random.nextDouble() - 0.5) * 50, -50 - _random.nextDouble() * 50), Colors.orangeAccent.withValues(alpha: 0.6), 2.0 + _random.nextDouble() * 2.0));
      } else {
        weather.add(WeatherParticle(Offset(_random.nextDouble() * 1000 - 100, _random.nextDouble() * 800 - 100), Offset(0, 10 + _random.nextDouble() * 20), Colors.greenAccent.withValues(alpha: 0.4), 1.0 + _random.nextDouble() * 2.0));
      }
    }

    totalTime += dt;
    if (comboTimer > 0) {
      comboTimer -= dt;
      if (comboTimer < 0) comboTimer = 0;
    }

    crashFlash -= dt;
    if (grayscaleTimer > 0) {
      grayscaleTimer -= dt;
      grayscaleFraction = min(1.0, grayscaleFraction + dt * 2.0); // 0.5s fade to grayscale
    } else {
      grayscaleFraction = max(0.0, grayscaleFraction - dt * 2.0); // fade out smoothly
    }

    if (nearMissTimer > 0) {
      nearMissTimer -= dt;
      if (nearMissTimer < 0) nearMissTimer = 0;
    }

    if (crashFlash < 0) crashFlash = 0.0;

    lineGlow -= dt * 2.0;
    if (lineGlow < 0) lineGlow = 0.0;
    
    for (var p in particles) {
      if (p.velocity.distance > 5.0) {
        p.position += p.velocity * simDt;
        p.velocity *= 0.96; 
      }
    }

    for (var dCar in destroyedCars) {
      if (dCar.velocity.distance > 1.0) {
        dCar.position += dCar.velocity * simDt;
        double friction = pow(0.01, simDt).toDouble(); 
        dCar.velocity *= friction;
        dCar.heading += dCar.spinVelocity * simDt;
        dCar.spinVelocity *= friction;
        _addSkidMark(dCar.position, dCar.heading, 0.4);
      }
    }

    bool needsQueueSpawn = false;

    for (var car in cars) {
      Car? lead = _getLeadCar(car);
      double sGap = double.infinity;
      double vLead = idm_v0;
      
      if (lead != null) {
        sGap = lead.s - car.s;
        vLead = lead.velocity;
      }

      if (car.lane == CarLane.entrance && !car.isMerging) {
        double distToStop = (stopLineS + idm_s0) - car.s;
        if (distToStop < sGap) {
          sGap = max(0.1, distToStop);
          vLead = 0.0;
        }
      }

      double accel = 0.0;
      double v = car.velocity;
      
      if (car.lane == CarLane.loop || car.isMerging) {
        accel = (idm_v0 - v) * 5.0; 
        if (car.isMerging) {
          _addSkidMark(car.position, car.heading, 0.15); 
        }
      } else {
        if (sGap < 800.0) {
          double deltaV = v - vLead;
          double sStar = idm_s0 + v * idm_T + (v * deltaV) / (2 * sqrt(idm_a * idm_b));
          accel = idm_a * (1 - pow(v / idm_v0, 4) - pow(sStar / max(sGap, 0.1), 2));
        } else {
          accel = idm_a * (1 - pow(v / idm_v0, 4));
        }
      }

      if (accel < -10.0 || (car.lane == CarLane.entrance && car.velocity < 5.0)) {
        car.brakeAlpha += simDt * 10.0;
      } else {
        car.brakeAlpha -= simDt * 10.0;
      }
      car.brakeAlpha = car.brakeAlpha.clamp(0.0, 1.0);

      if (car.lane == CarLane.loop && !car.hasTriggeredNearMiss && sGap > 32.0) {
        double clearGap = sGap - 32.0;
        if (clearGap < 15.0 && car.velocity > 20.0) {
          double distFromMerge = car.s - mergeLoopS;
          if (distFromMerge < 0) distFromMerge += loopMetric.length;
          if (distFromMerge < 150.0) { // recently merged
            car.hasTriggeredNearMiss = true;
            nearMissTimer = 2.0;
          }
        }
      }

      car.velocity += accel * simDt;
      if (car.velocity < 0) car.velocity = 0;
      
      car.s += car.velocity * simDt;

      if (car.lane == CarLane.entrance && car.s >= entranceMetric.length) {
        car.lane = CarLane.loop;
        car.s = mergeLoopS + (car.s - entranceMetric.length);
        car.isMerging = false;
        needsQueueSpawn = true;
      }
      else if (car.lane == CarLane.loop) {
        car.s = car.s % loopMetric.length;
        if (car.type == CarType.player && !car.counted && car.velocity > 50) {
          car.counted = true;
          correct++;
          lineGlow = 1.0;
          lineGlowColor = Colors.lightBlueAccent;
          
          if (totalTime - lastMergeTime < 1.2) {
             comboCount++;
             if (comboCount >= 3) {
                 comboTimer = 3.0; // combo trail lasts 3s
             }
          } else {
             comboCount = 1;
          }
          lastMergeTime = totalTime;
        }
      }

      PathMetric currentMetric = car.lane == CarLane.entrance ? entranceMetric : loopMetric;
      double evalS = car.s;
      if (car.lane == CarLane.loop) evalS = evalS % loopMetric.length;
      
      final tangent = currentMetric.getTangentForOffset(evalS);
      if (tangent != null) {
        car.position = tangent.position;
        
        double nextS = evalS + 2.0;
        if (car.lane == CarLane.loop) {
          nextS = nextS % loopMetric.length;
        } else if (nextS > entranceMetric.length) nextS = entranceMetric.length;
        
        final nextTangent = currentMetric.getTangentForOffset(nextS);
        if (nextTangent != null && (nextTangent.position - car.position).distance > 0.1) {
          Offset dir = nextTangent.position - car.position;
          car.heading = atan2(dir.dy, dir.dx);
        }
      }
    }

    if (needsQueueSpawn) _spawnQueue();
    _checkCollisions();
  }

  void _checkCollisions() {
    Set<int> toDestroy = {};

    for (int i = 0; i < cars.length; i++) {
      for (int j = i + 1; j < cars.length; j++) {
        final c1 = cars[i];
        final c2 = cars[j];
        
        if (c1.lane == CarLane.entrance && c2.lane == CarLane.entrance) continue;
        if (c1.lane == CarLane.entrance && !c1.isMerging && c2.lane == CarLane.loop) continue;
        if (c2.lane == CarLane.entrance && !c2.isMerging && c1.lane == CarLane.loop) continue;

        final dist = (c1.position - c2.position).distance;
        if (dist < hitRadius * 2) {
          toDestroy.add(c1.id);
          toDestroy.add(c2.id);
        }
      }
    }

    if (toDestroy.isNotEmpty) {
      crashFlash = 1.0;
      lineGlow = 1.0;
      lineGlowColor = Colors.redAccent;
      
      crashCount++;
      grayscaleTimer = crashCount == 1 ? 3.0 : 2.0;
      
      bool needsQueueSpawn = false;

      for (var carId in toDestroy) {
        var car = cars.firstWhere((c) => c.id == carId);
        
        // Calculate precise outward Normal to guarantee they fly OFF the track sideways!
        Offset tangentVec = Offset(cos(car.heading), sin(car.heading));
        Offset normal1 = Offset(-tangentVec.dy, tangentVec.dx);
        Offset normal2 = Offset(tangentVec.dy, -tangentVec.dx);
        Offset toCenter = const Offset(400, 250) - car.position;
        
        // Pick the normal that points away from the center of the screen
        Offset outwardNormal = (normal1.dx * toCenter.dx + normal1.dy * toCenter.dy) < 0 ? normal1 : normal2;
        
        // Cinematic slow massive push - Reduced distance!
        Offset outwardVel = outwardNormal * (100.0 + _random.nextDouble() * 40.0);
        Offset burstVel = tangentVec * (car.velocity * 0.1);
        
        Color burntColor = Color.lerp(car.color, Colors.black, 0.7)!;
        destroyedCars.add(DestroyedCar(
           position: car.position,
           heading: car.heading,
           color: burntColor,
           velocity: burstVel + outwardVel,
           spinVelocity: (_random.nextDouble() > 0.5 ? 1 : -1) * (5.0 + _random.nextDouble() * 5.0),
        ));
        
        _spawnExplosion(car.position, car.color, burstVel + outwardVel, car.heading);
        
        if (car.type == CarType.player && !car.counted) {
          mistakes++;
          if ((cars.length - toDestroy.length) < 5) {
            needsQueueSpawn = true;
          }
        }
      }
      cars.removeWhere((c) => toDestroy.contains(c.id));
      if (needsQueueSpawn) _spawnQueue();
    }
  }

  void _spawnExplosion(Offset pos, Color color, Offset burstVel, double heading) {
    for (int i = 0; i < 40; i++) {
      final angle = _random.nextDouble() * pi * 2;
      final speed = 100.0 + _random.nextDouble() * 300.0;
      particles.add(Particle(
        position: pos,
        velocity: burstVel * 0.3 + Offset(cos(angle) * speed, sin(angle) * speed),
        color: color,
      ));
    }
  }

  bool get isRoundComplete => correct >= goal;
}
