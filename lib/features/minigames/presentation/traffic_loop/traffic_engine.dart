import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

enum CarState { queue, entering, looping, destroyed }
enum CarType { player, obstacle }

class Car {
  Car({required this.id, required this.color, required this.type, this.state = CarState.queue});

  final int id;
  final Color color;
  final CarType type;
  CarState state;
  double distance = 0.0;
  
  Offset position = Offset.zero;
  double rotation = 0.0;
  bool counted = false;
}

class Particle {
  Particle({required this.position, required this.velocity, required this.color});
  Offset position;
  Offset velocity;
  Color color;
  double life = 1.0;
}

class TrafficEngine {
  TrafficEngine({required this.goal, required this.seed}) {
    _initPaths();
    _random = Random(seed);
    _spawnObstacles();
    _spawnQueue();
  }

  final int goal;
  final int seed;
  late final Random _random;

  late Path loopPath;
  late Path entrancePath;

  late PathMetric loopMetric;
  late PathMetric entranceMetric;

  final List<Car> cars = [];
  final List<Particle> particles = [];

  int correct = 0;
  int mistakes = 0;
  int _carIdCounter = 0;
  
  final double carSpeed = 250.0; // Faster speed for higher difficulty
  final double carLength = 36.0;
  final double carWidth = 20.0;
  final double hitRadius = 22.0;

  void _initPaths() {
    // Entrance: from bottom to the merge point
    entrancePath = Path()
      ..moveTo(400, 700)
      ..lineTo(400, 450);
    entranceMetric = entrancePath.computeMetrics().first;

    // Loop: A track that circulates forever
    loopPath = Path()
      ..moveTo(400, 450)
      ..arcToPoint(const Offset(200, 450), radius: const Radius.circular(120), clockwise: true)
      ..lineTo(200, 150)
      ..arcToPoint(const Offset(400, 150), radius: const Radius.circular(120), clockwise: true)
      ..lineTo(400, 150)
      ..arcToPoint(const Offset(600, 150), radius: const Radius.circular(120), clockwise: true)
      ..lineTo(600, 450)
      ..arcToPoint(const Offset(400, 450), radius: const Radius.circular(120), clockwise: true);
    loopMetric = loopPath.computeMetrics().first;
  }

  void _spawnObstacles() {
    // Generate 3 to 5 obstacle cars already in the loop based on the round (goal)
    int obstacleCount = goal == 10 ? 3 : (goal == 15 ? 4 : 5);
    final colors = [Colors.yellowAccent, Colors.orangeAccent];
    
    double spacing = loopMetric.length / obstacleCount;
    for (int i = 0; i < obstacleCount; i++) {
      var car = Car(
        id: ++_carIdCounter,
        color: colors[_random.nextInt(colors.length)],
        type: CarType.obstacle,
        state: CarState.looping,
      );
      // Randomize initial position slightly but keep them spaced
      car.distance = (i * spacing) + _random.nextDouble() * 50.0;
      _updateCarTransform(car, loopMetric, car.distance);
      cars.add(car);
    }
  }

  void _spawnQueue() {
    // The player controls blue/pink cars
    final colors = [Colors.lightBlueAccent, Colors.pinkAccent];
    int queueCount = cars.where((c) => c.state == CarState.queue).length;
    for (int i = queueCount; i < 5; i++) {
      cars.add(Car(
        id: ++_carIdCounter,
        color: colors[_random.nextInt(colors.length)],
        type: CarType.player,
        state: CarState.queue,
      ));
    }
    _updateQueuePositions();
  }

  void _updateQueuePositions() {
    int index = 0;
    for (var car in cars) {
      if (car.state == CarState.queue) {
        car.distance = max(0.0, entranceMetric.length - 40.0 - (index * 50.0));
        _updateCarTransform(car, entranceMetric, car.distance);
        index++;
      }
    }
  }

  void _updateCarTransform(Car car, PathMetric metric, double distance) {
    // Handle looping around the path length
    double d = distance % metric.length;
    final tangent = metric.getTangentForOffset(d);
    if (tangent != null) {
      car.position = tangent.position;
      car.rotation = tangent.angle;
    }
  }

  bool tap() {
    if (correct >= goal) return false;
    
    final firstQueue = cars.where((c) => c.state == CarState.queue).firstOrNull;
    if (firstQueue != null) {
      firstQueue.state = CarState.entering;
      _spawnQueue();
      return true;
    }
    return false;
  }

  void update(double dt) {
    for (var p in particles) {
      p.position += p.velocity * dt;
      p.life -= dt * 2.0;
    }
    particles.removeWhere((p) => p.life <= 0);

    for (int i = cars.length - 1; i >= 0; i--) {
      var car = cars[i];
      if (car.state == CarState.destroyed || car.state == CarState.queue) continue;

      car.distance += carSpeed * dt;

      if (car.state == CarState.entering) {
        if (car.distance >= entranceMetric.length) {
          car.state = CarState.looping;
          car.distance = 0.0; // Start at the beginning of the loop
        } else {
          _updateCarTransform(car, entranceMetric, car.distance);
        }
      }

      if (car.state == CarState.looping) {
        // Continuous loop
        car.distance = car.distance % loopMetric.length;
        _updateCarTransform(car, loopMetric, car.distance);
        
        // Count it as correct if it survived the merge distance (e.g. 50 pixels into the loop)
        if (car.type == CarType.player && !car.counted && car.distance > 50.0 && car.distance < 100.0) {
          car.counted = true;
          correct++;
        }
      }
    }

    _checkCollisions();
  }

  void _checkCollisions() {
    final active = cars.where((c) => c.state == CarState.entering || c.state == CarState.looping).toList();
    Set<int> toDestroy = {};

    for (int i = 0; i < active.length; i++) {
      for (int j = i + 1; j < active.length; j++) {
        final c1 = active[i];
        final c2 = active[j];
        final dist = (c1.position - c2.position).distance;
        if (dist < hitRadius * 2) {
          toDestroy.add(c1.id);
          toDestroy.add(c2.id);
        }
      }
    }

    if (toDestroy.isNotEmpty) {
      for (var car in cars) {
        if (toDestroy.contains(car.id)) {
          car.state = CarState.destroyed;
          _spawnExplosion(car.position, car.color);
          // Only penalize mistakes for player cars (so 1 crash between player and obstacle = 1 mistake)
          // If two player cars crash, it counts as 2 mistakes.
          if (car.type == CarType.player && !car.counted) {
            mistakes++;
          }
        }
      }
      // Cleanup destroyed
      cars.removeWhere((c) => c.state == CarState.destroyed);
    }
  }

  void _spawnExplosion(Offset pos, Color color) {
    for (int i = 0; i < 30; i++) {
      final angle = _random.nextDouble() * pi * 2;
      final speed = 50.0 + _random.nextDouble() * 150.0;
      particles.add(Particle(
        position: pos,
        velocity: Offset(cos(angle) * speed, sin(angle) * speed),
        color: color,
      ));
    }
  }

  bool get isRoundComplete => correct >= goal;
}
