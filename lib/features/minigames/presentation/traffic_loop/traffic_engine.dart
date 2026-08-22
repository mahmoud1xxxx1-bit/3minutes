import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

enum CarState { queue, entering, looping, exiting, destroyed }

class Car {
  Car({required this.id, required this.color}) : state = CarState.queue;

  final int id;
  final Color color;
  CarState state;
  double distance = 0.0;
  int laps = 0;
  
  Offset position = Offset.zero;
  double rotation = 0.0;
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
    _spawnQueue();
  }

  final int goal;
  final int seed;
  late final Random _random;

  late Path loopPath;
  late Path entrancePath;
  late Path exitPath;

  late PathMetric loopMetric;
  late PathMetric entranceMetric;
  late PathMetric exitMetric;

  final List<Car> cars = [];
  final List<Particle> particles = [];

  int correct = 0;
  int mistakes = 0;
  int _carIdCounter = 0;
  
  final double carSpeed = 200.0; // logical pixels per second
  final double carLength = 40.0;
  final double carWidth = 24.0;
  final double hitRadius = 25.0; // Crash radius

  void _initPaths() {
    // 800x600 coordinate system
    
    // Entrance: bottom to center-bottom
    entrancePath = Path()
      ..moveTo(400, 700)
      ..lineTo(400, 450);
    entranceMetric = entrancePath.computeMetrics().first;

    // Loop: starts at (400, 450), goes left, up, right, down, back to (400, 450)
    loopPath = Path()
      ..moveTo(400, 450)
      ..arcToPoint(const Offset(200, 450), radius: const Radius.circular(100), clockwise: true) // left bottom
      ..lineTo(200, 150)
      ..arcToPoint(const Offset(400, 150), radius: const Radius.circular(100), clockwise: true) // left top
      ..lineTo(400, 150)
      ..arcToPoint(const Offset(600, 150), radius: const Radius.circular(100), clockwise: true) // right top
      ..lineTo(600, 450)
      ..arcToPoint(const Offset(400, 450), radius: const Radius.circular(100), clockwise: true); // right bottom
    loopMetric = loopPath.computeMetrics().first;

    // Exit: center-top to top
    exitPath = Path()
      ..moveTo(400, 150)
      ..lineTo(400, -100);
    exitMetric = exitPath.computeMetrics().first;
  }

  void _spawnQueue() {
    final colors = [
      Colors.redAccent, Colors.pinkAccent, Colors.orangeAccent, 
      Colors.blueAccent, Colors.greenAccent, Colors.yellowAccent
    ];
    // Keep queue filled to 5 cars
    int queueCount = cars.where((c) => c.state == CarState.queue).length;
    for (int i = queueCount; i < 5; i++) {
      cars.add(Car(
        id: ++_carIdCounter,
        color: colors[_random.nextInt(colors.length)]
      ));
    }
    _updateQueuePositions();
  }

  void _updateQueuePositions() {
    int index = 0;
    for (var car in cars) {
      if (car.state == CarState.queue) {
        // Position them along the entrance path, spaced out
        car.distance = max(0.0, entranceMetric.length - 50.0 - (index * 60.0));
        _updateCarTransform(car, entranceMetric, car.distance);
        index++;
      }
    }
  }

  void _updateCarTransform(Car car, PathMetric metric, double distance) {
    final tangent = metric.getTangentForOffset(distance);
    if (tangent != null) {
      car.position = tangent.position;
      car.rotation = tangent.angle;
    }
  }

  bool tap() {
    // Find the first queue car and launch it
    final firstQueue = cars.where((c) => c.state == CarState.queue).firstOrNull;
    if (firstQueue != null) {
      firstQueue.state = CarState.entering;
      _spawnQueue();
      return true;
    }
    return false;
  }

  void update(double dt) {
    // Update particles
    for (var p in particles) {
      p.position += p.velocity * dt;
      p.life -= dt * 1.5;
    }
    particles.removeWhere((p) => p.life <= 0);

    // Update cars
    for (int i = cars.length - 1; i >= 0; i--) {
      var car = cars[i];
      if (car.state == CarState.destroyed) {
        cars.removeAt(i);
        continue;
      }
      
      if (car.state == CarState.queue) continue;

      car.distance += carSpeed * dt;

      if (car.state == CarState.entering) {
        if (car.distance >= entranceMetric.length) {
          car.state = CarState.looping;
          car.distance = 0.0;
        } else {
          _updateCarTransform(car, entranceMetric, car.distance);
        }
      }

      if (car.state == CarState.looping) {
        if (car.distance >= loopMetric.length) {
          car.laps++;
          car.distance -= loopMetric.length;
        }
        
        // Check if car should exit
        // We exit at distance roughly halfway (where x=400, y=150)
        // Let's find exactly where that is on the loop metric
        // The loop starts at (400, 450). It goes to (200,450) -> (200,150) -> (400,150)
        // This is exactly when it reaches (400, 150).
        // Let's hardcode the exit threshold based on manual calculation, or just check bounds.
        if (car.laps >= 1 && car.position.dy <= 155 && car.position.dy >= 145 && car.position.dx > 390 && car.position.dx < 410) {
          car.state = CarState.exiting;
          car.distance = 0.0;
        } else {
          _updateCarTransform(car, loopMetric, car.distance);
        }
      }

      if (car.state == CarState.exiting) {
        if (car.distance >= exitMetric.length) {
          car.state = CarState.destroyed;
          correct++;
        } else {
          _updateCarTransform(car, exitMetric, car.distance);
        }
      }
    }

    _checkCollisions();
  }

  void _checkCollisions() {
    // Only check active moving cars
    final active = cars.where((c) => c.state != CarState.queue && c.state != CarState.destroyed).toList();
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
          mistakes++;
        }
      }
    }
  }

  void _spawnExplosion(Offset pos, Color color) {
    for (int i = 0; i < 40; i++) {
      final angle = _random.nextDouble() * pi * 2;
      final speed = 50.0 + _random.nextDouble() * 200.0;
      particles.add(Particle(
        position: pos,
        velocity: Offset(cos(angle) * speed, sin(angle) * speed),
        color: color,
      ));
    }
  }

  bool get isRoundComplete => correct >= goal;
}
