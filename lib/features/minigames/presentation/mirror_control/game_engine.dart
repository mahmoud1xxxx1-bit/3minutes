// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures, non_constant_identifier_names, empty_catches, library_private_types_in_public_api, no_leading_underscores_for_local_identifiers
import 'dart:ui';
import '../../../../core/random/deterministic_rng.dart';

class GameEngine {
  GameEngine({required int seed}) {
    _rng = DeterministicRng(seed);
    _generateLevel();
  }

  late final DeterministicRng _rng;

  // Fixed logical coordinate system (0 to 1000)
  static const double fieldSize = 1000.0;
  static const double playerRadius = 15.0;
  static const double chaserRadius = 15.0;
  static const double targetRadius = 20.0;
  
  // Speeds (units per second)
  static const double playerSpeed = 350.0;
  static const double chaserMaxSpeed = 200.0; // ~57% of player speed

  // State
  Offset playerPos = const Offset(100, 100);
  Offset chaserPos = const Offset(900, 900);
  double time = 0.0;
  Offset playerVelocity = Offset.zero;
  Offset chaserVelocity = Offset.zero;
  bool chaserInWall = false;
  double chaserWallDelay = 0.0;
  
  final List<Rect> obstacles = [];
  final List<Offset> targets = [];
  int currentTargetIndex = 0;
  Offset? exitGate;

  // Mechanics
  int mistakes = 0;
  bool isCompleted = false;
  
  // Stun timer
  double chaserStunTimer = 0.0;
  static const double stunDuration = 5.0;
  static const double recoveryDuration = 0.5;

  void _generateLevel() {
    obstacles.clear();
    targets.clear();
    
    // We have 8 distinct, beautifully crafted architectural layouts.
    int layoutType = _rng.nextInt(8);
    
    // Slight random modifiers to make the same layout feel unique each time
    double mx = (_rng.nextInt(40) - 20).toDouble();
    double my = (_rng.nextInt(40) - 20).toDouble();
    
    switch(layoutType) {
      case 0: // The Colosseum (Concentric rectangles with gaps)
        obstacles.add(Rect.fromLTWH(200+mx, 200+my, 600, 40));
        obstacles.add(Rect.fromLTWH(200+mx, 760+my, 600, 40));
        obstacles.add(Rect.fromLTWH(200+mx, 240+my, 40, 200));
        obstacles.add(Rect.fromLTWH(200+mx, 560+my, 40, 200));
        obstacles.add(Rect.fromLTWH(760+mx, 240+my, 40, 200));
        obstacles.add(Rect.fromLTWH(760+mx, 560+my, 40, 200));
        obstacles.add(Rect.fromLTWH(400+mx, 400+my, 200, 200)); // Inner core
        break;
      case 1: // The Grid (4x4 pillars)
        for(int r=0; r<4; r++) {
          for(int c=0; c<4; c++) {
            if (r==0 && c==0) continue; // Safe spawn
            if (r==3 && c==3) continue; // Safe spawn
            obstacles.add(Rect.fromLTWH(200 + c*170 + mx, 200 + r*170 + my, 70, 70));
          }
        }
        break;
      case 2: // The Cross Vault
        obstacles.add(Rect.fromLTWH(450+mx, 150+my, 100, 250)); // Top vertical
        obstacles.add(Rect.fromLTWH(450+mx, 600+my, 100, 250)); // Bottom vertical
        obstacles.add(Rect.fromLTWH(150+mx, 450+my, 250, 100)); // Left horizontal
        obstacles.add(Rect.fromLTWH(600+mx, 450+my, 250, 100)); // Right horizontal
        // Corners
        obstacles.add(Rect.fromLTWH(250+mx, 250+my, 100, 100));
        obstacles.add(Rect.fromLTWH(650+mx, 250+my, 100, 100));
        obstacles.add(Rect.fromLTWH(250+mx, 650+my, 100, 100));
        obstacles.add(Rect.fromLTWH(650+mx, 650+my, 100, 100));
        break;
      case 3: // Zig-Zag Corridors
        obstacles.add(Rect.fromLTWH(0, 250+my, 700+mx, 60));
        obstacles.add(Rect.fromLTWH(300+mx, 500+my, 700, 60));
        obstacles.add(Rect.fromLTWH(0, 750+my, 700+mx, 60));
        break;
      case 4: // Symmetrical H-Block
        obstacles.add(Rect.fromLTWH(300+mx, 200+my, 60, 600)); // Left leg
        obstacles.add(Rect.fromLTWH(640+mx, 200+my, 60, 600)); // Right leg
        obstacles.add(Rect.fromLTWH(360+mx, 470+my, 280, 60)); // Middle bridge
        break;
      case 5: // Diamond Center
        obstacles.add(Rect.fromLTWH(400+mx, 150+my, 200, 60)); // Top
        obstacles.add(Rect.fromLTWH(400+mx, 790+my, 200, 60)); // Bottom
        obstacles.add(Rect.fromLTWH(150+mx, 400+my, 60, 200)); // Left
        obstacles.add(Rect.fromLTWH(790+mx, 400+my, 60, 200)); // Right
        obstacles.add(Rect.fromLTWH(440+mx, 440+my, 120, 120)); // Core
        obstacles.add(Rect.fromLTWH(280+mx, 280+my, 60, 60));
        obstacles.add(Rect.fromLTWH(660+mx, 280+my, 60, 60));
        obstacles.add(Rect.fromLTWH(280+mx, 660+my, 60, 60));
        obstacles.add(Rect.fromLTWH(660+mx, 660+my, 60, 60));
        break;
      case 6: // The Double Helix (Staggered blocks)
        for(int i=0; i<6; i++) {
          obstacles.add(Rect.fromLTWH(150 + i*120 + mx, 250 + (i%2)*150 + my, 80, 80));
          obstacles.add(Rect.fromLTWH(150 + i*120 + mx, 600 - (i%2)*150 + my, 80, 80));
        }
        break;
      case 7: // The Maze (Classic C-shapes)
        obstacles.add(Rect.fromLTWH(200+mx, 200+my, 600, 60)); // Top
        obstacles.add(Rect.fromLTWH(200+mx, 260+my, 60, 400)); // Left side
        obstacles.add(Rect.fromLTWH(200+mx, 660+my, 400, 60)); // Bottom partial
        obstacles.add(Rect.fromLTWH(740+mx, 400+my, 60, 400)); // Right bottom
        obstacles.add(Rect.fromLTWH(500+mx, 400+my, 240, 60)); // Middle shelf
        break;
    }

    // Generate targets, ensuring they don't spawn inside obstacles
    while (targets.length < 5) {
      double x = (_rng.nextInt(1000) / 1000.0) * (fieldSize - 100) + 50;
      double y = (_rng.nextInt(1000) / 1000.0) * (fieldSize - 100) + 50;
      final pos = Offset(x, y);
      
      bool valid = true;
      for (final obs in obstacles) {
        if (obs.inflate(45).contains(pos)) valid = false; // generous margin
      }
      
      // Don't spawn on top of start/end positions
      if ((pos - const Offset(100, 100)).distance < 100) valid = false;
      if ((pos - const Offset(900, 900)).distance < 100) valid = false;
      
      if (valid) targets.add(pos);
    }
  }

  void update(double dt, Offset inputVector) {
    if (isCompleted) return;
    time += dt;

    // 1. Update Player
    if (inputVector != Offset.zero) {
      Offset desiredMove = inputVector * playerSpeed * dt;
      playerVelocity = desiredMove / dt;
      playerPos = _slideCollide(playerPos, desiredMove, playerRadius);
    } else {
      playerVelocity = Offset.zero;
    }

    // 2. Target Collection
    if (currentTargetIndex < targets.length) {
      final target = targets[currentTargetIndex];
      if ((playerPos - target).distance < playerRadius + targetRadius) {
        currentTargetIndex++;
        if (currentTargetIndex == targets.length) _spawnExitGate();
      }
    }

    // 3. Exit Gate Collection
    if (exitGate != null) {
      if ((playerPos - exitGate!).distance < playerRadius + targetRadius) {
        isCompleted = true;
      }
    }

    // 4. Update Chaser
    if (chaserStunTimer > 0) {
      chaserStunTimer -= dt;
      if (chaserStunTimer < 0) chaserStunTimer = 0;
    }

    if (chaserStunTimer <= recoveryDuration) {
      double currentSpeed = chaserMaxSpeed;
      if (chaserStunTimer > 0) {
        double recoveryProgress = 1.0 - (chaserStunTimer / recoveryDuration);
        currentSpeed = chaserMaxSpeed * recoveryProgress;
      }

      Offset toPlayer = playerPos - chaserPos;
      if (toPlayer.distance > 0) {
        Offset move = (toPlayer / toPlayer.distance) * currentSpeed * dt;
        chaserVelocity = move / dt;
        
        Offset newChaserPos = chaserPos + move;
        if (newChaserPos.dx < chaserRadius) newChaserPos = Offset(chaserRadius, newChaserPos.dy);
        if (newChaserPos.dx > fieldSize - chaserRadius) newChaserPos = Offset(fieldSize - chaserRadius, newChaserPos.dy);
        if (newChaserPos.dy < chaserRadius) newChaserPos = Offset(newChaserPos.dx, chaserRadius);
        if (newChaserPos.dy > fieldSize - chaserRadius) newChaserPos = Offset(newChaserPos.dx, fieldSize - chaserRadius);
        
        bool currentlyInWall = false;
        for (final obs in obstacles) {
           if (obs.inflate(-2.0).contains(chaserPos)) { currentlyInWall = true; break; }
        }
        
        if (currentlyInWall) {
             chaserPos = newChaserPos;
             chaserWallDelay = 0.0;
        } else {
             bool hitsWall = false;
             for (final obs in obstacles) {
                 if (obs.inflate(chaserRadius).contains(newChaserPos)) { hitsWall = true; break; }
             }
             
             if (hitsWall) {
                 if (chaserWallDelay > 0.0) {
                     chaserWallDelay -= dt;
                     chaserPos = _slideCollide(chaserPos, move, chaserRadius);
                 } else if (chaserWallDelay == 0.0) {
                     chaserWallDelay = 1.0; // 1 second delay!
                     chaserPos = _slideCollide(chaserPos, move, chaserRadius);
                 } else {
                     chaserPos = newChaserPos; // Enters wall!
                 }
             } else {
                 chaserPos = newChaserPos;
                 chaserWallDelay = 0.0;
             }
        }
      } else {
        chaserVelocity = Offset.zero;
      }
    }

    if (chaserStunTimer == 0 && (playerPos - chaserPos).distance < playerRadius + chaserRadius) {
      mistakes++;
      chaserStunTimer = stunDuration + recoveryDuration;
    }

    chaserInWall = false;
    for (final obs in obstacles) {
      if (obs.inflate(-2.0).contains(chaserPos)) {
        chaserInWall = true;
        break;
      }
    }
  }

  void _spawnExitGate() {
    // Try corners
    List<Offset> corners = [
      const Offset(100, 100),
      const Offset(900, 900),
      const Offset(100, 900),
      const Offset(900, 100),
      const Offset(500, 100),
      const Offset(500, 900),
      const Offset(100, 500),
      const Offset(900, 500),
      const Offset(500, 500),
    ];
    
    // Sort by distance to player (furthest first)
    corners.sort((a, b) => (playerPos - b).distanceSquared.compareTo((playerPos - a).distanceSquared));
    
    for (var corner in corners) {
      bool valid = true;
      for (var obs in obstacles) {
        if (obs.inflate(45).contains(corner)) {
          valid = false;
          break;
        }
      }
      if (valid) {
        exitGate = corner;
        return;
      }
    }
    // Fallback if somehow all are blocked
    exitGate = corners.first;
  }

  Offset _slideCollide(Offset pos, Offset move, double radius) {
    Offset newPos = pos + move;

    // Boundary constraints
    if (newPos.dx < radius) newPos = Offset(radius, newPos.dy);
    if (newPos.dx > fieldSize - radius) newPos = Offset(fieldSize - radius, newPos.dy);
    if (newPos.dy < radius) newPos = Offset(newPos.dx, radius);
    if (newPos.dy > fieldSize - radius) newPos = Offset(newPos.dx, fieldSize - radius);

    // Box constraints (Slide against walls)
    // A simple continuous collision approach for AABB vs Circle
    for (final obs in obstacles) {
      final expanded = obs.inflate(radius);
      if (expanded.contains(newPos)) {
        // Determine which edge we hit by checking the previous position
        bool fromLeft = pos.dx <= expanded.left;
        bool fromRight = pos.dx >= expanded.right;
        bool fromTop = pos.dy <= expanded.top;
        bool fromBottom = pos.dy >= expanded.bottom;

        if (fromLeft) {
          newPos = Offset(expanded.left, newPos.dy);
        } else if (fromRight) newPos = Offset(expanded.right, newPos.dy);
        else if (fromTop) newPos = Offset(newPos.dx, expanded.top);
        else if (fromBottom) newPos = Offset(newPos.dx, expanded.bottom);
      }
    }

    return newPos;
  }
}
