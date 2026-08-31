import 'dart:math';
import 'package:flutter/material.dart';

enum TrollEntityType { player, block, spike, door, particle }

class RectD {
  double x, y, w, h;
  RectD(this.x, this.y, this.w, this.h);
  
  double get left => x;
  double get right => x + w;
  double get top => y;
  double get bottom => y + h;
  
  RectD clone() => RectD(x, y, w, h);
  
  bool intersects(RectD other) {
    return left < other.right && right > other.left &&
           top < other.bottom && bottom > other.top;
  }
  
  Rect toRect() => Rect.fromLTWH(x, y, w, h);
}

class TrollEntity {
  String id;
  TrollEntityType type;
  RectD rect;
  Color color;
  bool isSolid;
  bool isVisible;
  bool activePhysics;
  double vy;
  bool isInverted;

  TrollEntity({
    required this.id,
    required this.type,
    required this.rect,
    this.color = Colors.white,
    this.isSolid = true,
    this.isVisible = true,
    this.activePhysics = false,
    this.vy = 0,
    this.isInverted = false,
  });

  double vx = 0;
}

class Particle {
  double x, y, vx, vy, life, maxLife;
  Color color;
  Particle(this.x, this.y, this.vx, this.vy, this.life, this.color) : maxLife = life;
}

// ---------------- Traps State Machine ----------------

abstract class TrollTrap {
  void update(TrollEngine engine, double dt);
}

// Drops floor blocks when player enters a trigger zone BEFORE the blocks.
class FallingPlatformTrap extends TrollTrap {
  final RectD triggerArea;
  final List<String> targetIds;
  List<TrollEntity>? _cachedEntities;
  bool triggered = false;
  
  FallingPlatformTrap(this.triggerArea, this.targetIds);

  @override
  void update(TrollEngine engine, double dt) {
    if (triggered) return;
    
    if (_cachedEntities == null) {
      _cachedEntities = [];
      for (var id in targetIds) {
        var e = engine.entities.where((e) => e.id == id).firstOrNull;
        if (e != null) _cachedEntities!.add(e);
      }
    }
    
    if (triggerArea.intersects(engine.player.rect)) {
      triggered = true;
      for (var block in _cachedEntities!) {
        block.activePhysics = true;
        block.vy = 200; // Fall!
      }
    }
  }
}

// Spikes that suddenly appear ON the floor when you get near, disappear when you back away.
class AppearingSpikesTrap extends TrollTrap {
  final RectD triggerArea;
  final List<String> targetIds;
  List<TrollEntity>? _cachedEntities;
  bool isUp = false;
  
  AppearingSpikesTrap(this.triggerArea, this.targetIds);

  @override
  void update(TrollEngine engine, double dt) {
    if (_cachedEntities == null) {
      _cachedEntities = [];
      for (var id in targetIds) {
        var e = engine.entities.where((e) => e.id == id).firstOrNull;
        if (e != null) _cachedEntities!.add(e);
      }
    }

    bool inZone = triggerArea.intersects(engine.player.rect);
    if (inZone && !isUp) {
      isUp = true;
      for (var spike in _cachedEntities!) {
        spike.isVisible = true; // Suddenly appear!
      }
    } else if (!inZone && isUp) {
      isUp = false;
      for (var spike in _cachedEntities!) {
        spike.isVisible = false; // Disappear when backed away!
      }
    }
  }
}

// Blocks that suddenly appear to block your jump!
class AppearingWallTrap extends TrollTrap {
  final RectD triggerArea;
  final List<String> targetIds;
  List<TrollEntity>? _cachedEntities;
  bool isUp = false;
  
  AppearingWallTrap(this.triggerArea, this.targetIds);

  @override
  void update(TrollEngine engine, double dt) {
    if (_cachedEntities == null) {
      _cachedEntities = [];
      for (var id in targetIds) {
        var e = engine.entities.where((e) => e.id == id).firstOrNull;
        if (e != null) _cachedEntities!.add(e);
      }
    }

    bool inZone = triggerArea.intersects(engine.player.rect);
    if (inZone && !isUp) {
      isUp = true;
      for (var block in _cachedEntities!) {
        block.isVisible = true;
        block.isSolid = true;
      }
    } else if (!inZone && isUp) {
      isUp = false;
      for (var block in _cachedEntities!) {
        block.isVisible = false;
        block.isSolid = false;
      }
    }
  }
}

class ThwompCeilingTrap extends TrollTrap {
  final RectD triggerArea;
  final List<String> targetIds;
  Map<TrollEntity, double> cachedEntities = {}; // Cache entity -> originalY
  final double dropHeight;
  bool triggered = false; 
  
  ThwompCeilingTrap(this.triggerArea, this.targetIds, this.dropHeight);

  @override
  void update(TrollEngine engine, double dt) {
    if (targetIds.isEmpty) return;
    
    // Cache entities and their original Ys on first tick
    if (cachedEntities.isEmpty) {
      for (var id in targetIds) {
        var e = engine.entities.where((e) => e.id == id).firstOrNull;
        if (e != null) {
          cachedEntities[e] = e.rect.y;
        }
      }
    }
    
    if (!triggered && triggerArea.intersects(engine.player.rect)) {
      triggered = true;
    }
    
    if (triggered) {
      for (var entry in cachedEntities.entries) {
        var entity = entry.key;
        double thisOriginalY = entry.value;
        
        entity.rect.y += 2400 * dt; // Slam down even faster!
        if (entity.rect.y > thisOriginalY + dropHeight) {
          entity.rect.y = thisOriginalY + dropHeight;
        }
      }
    }
  }
}

class RunningDoorTrap extends TrollTrap {
  final RectD triggerArea;
  final String doorId;
  TrollEntity? _cachedDoor;
  final double moveDistanceX;
  bool isMoving = false;
  bool triggered = false;
  double targetX = 0;
  
  RunningDoorTrap(this.triggerArea, this.doorId, this.moveDistanceX);

  @override
  void update(TrollEngine engine, double dt) {
    _cachedDoor ??= engine.entities.where((e) => e.id == doorId).firstOrNull;
    var door = _cachedDoor;
    if (door == null) return;

    if (!triggered && triggerArea.intersects(engine.player.rect)) {
      triggered = true;
      isMoving = true;
      targetX = door.rect.x + moveDistanceX;
    }

    if (isMoving) {
      double dir = (targetX - door.rect.x).sign;
      door.rect.x += dir * 700 * dt; 
      if (dir > 0 && door.rect.x >= targetX) {
        door.rect.x = targetX;
        isMoving = false;
      } else if (dir < 0 && door.rect.x <= targetX) {
        door.rect.x = targetX;
        isMoving = false;
      }
    }
  }
}

// ---------------- NEW C2 TRAPS ----------------

// Fake Solid Trap: Looks like a solid block, but becomes non-solid and slightly transparent when touched.
class FakeSolidTrap extends TrollTrap {
  final RectD triggerArea;
  final List<String> targetIds;
  List<TrollEntity>? _cachedEntities;
  bool triggered = false;
  
  FakeSolidTrap(this.triggerArea, this.targetIds);

  @override
  void update(TrollEngine engine, double dt) {
    if (triggered) return;
    
    if (_cachedEntities == null) {
      _cachedEntities = [];
      for (var id in targetIds) {
        var e = engine.entities.where((e) => e.id == id).firstOrNull;
        if (e != null) _cachedEntities!.add(e);
      }
    }
    
    if (triggerArea.intersects(engine.player.rect)) {
      triggered = true;
      for (var block in _cachedEntities!) {
        block.isSolid = false;
        block.color = block.color.withValues(alpha: 0.3); // Reveal the fake!
      }
    }
  }
}

// Erratic Patrol Spike: Moves back and forth but changes its bounds randomly every time it turns!
class ErraticPatrolSpikeTrap extends TrollTrap {
  final String spikeId;
  TrollEntity? _cachedSpike;
  final double speed;
  double leftBound = -1;
  double rightBound = -1;
  int direction = 1;
  
  ErraticPatrolSpikeTrap(this.spikeId, this.speed);

  @override
  void update(TrollEngine engine, double dt) {
    _cachedSpike ??= engine.entities.where((e) => e.id == spikeId).firstOrNull;
    var spike = _cachedSpike;
    if (spike == null) return;
    
    if (leftBound == -1) {
      // Initial bounds
      leftBound = spike.rect.x - (Random().nextDouble() * 3 + 1) * 40.0;
      rightBound = spike.rect.x + (Random().nextDouble() * 3 + 2) * 40.0;
    }
    
    spike.rect.x += speed * direction * dt;
    if (direction == 1 && spike.rect.x >= rightBound) {
      spike.rect.x = rightBound;
      direction = -1;
      // Assign a new unpredictable left bound (2 to 6 blocks back)
      leftBound = spike.rect.x - (Random().nextDouble() * 4 + 2) * 40.0;
    } else if (direction == -1 && spike.rect.x <= leftBound) {
      spike.rect.x = leftBound;
      direction = 1;
      // Assign a new unpredictable right bound (2 to 6 blocks forward)
      rightBound = spike.rect.x + (Random().nextDouble() * 4 + 2) * 40.0;
    }
  }
}

// Reverse Controls Trap: Permanently reverses the player's controls when stepping in the zone!
class ReverseControlsTrap extends TrollTrap {
  final RectD triggerArea;
  bool triggered = false;
  
  ReverseControlsTrap(this.triggerArea);

  @override
  void update(TrollEngine engine, double dt) {
    if (triggered) return;
    if (triggerArea.intersects(engine.player.rect)) {
      triggered = true;
      engine.invertedControls = !engine.invertedControls;
      // Spawn some purple particles to indicate curse!
      engine._spawnParticles(engine.player.rect.x + 15, engine.player.rect.y + 15, 30, const Color(0xFF9900FF));
    }
  }
}

// --- NEW C3 TRAPS ---

class JumpTriggeredDropTrap extends TrollTrap {
  final List<String> blockIds;
  List<TrollEntity> _blocks = [];
  bool triggered = false;
  
  JumpTriggeredDropTrap(this.blockIds);

  @override
  void update(TrollEngine engine, double dt) {
    if (_blocks.isEmpty) {
      _blocks = engine.entities.where((e) => blockIds.contains(e.id)).toList();
    }
    if (triggered) {
      for (var b in _blocks) {
        b.rect.y += 1000 * dt;
      }
      return;
    }
    
    // Check if player is standing on any of these blocks
    bool standingOnIt = false;
    RectD playerFoot = RectD(engine.player.rect.x + 5, engine.player.rect.bottom, engine.player.rect.w - 10, 2);
    for (var b in _blocks) {
      if (b.rect.intersects(playerFoot)) {
        standingOnIt = true;
        break;
      }
    }
    
    // If standing on it and tried to jump
    if (standingOnIt && engine.jumpBufferTimer > 0) {
      triggered = true;
      for (var b in _blocks) {
        b.isSolid = false;
      }
      engine.jumpBufferTimer = 0; 
      engine.coyoteTimer = 0;
    }
  }
}

class TrollSpringTrap extends TrollTrap {
  final String springId;
  TrollEntity? _spring;
  bool triggered = false;

  TrollSpringTrap(this.springId);

  @override
  void update(TrollEngine engine, double dt) {
    _spring ??= engine.entities.where((e) => e.id == springId).firstOrNull;
    var s = _spring;
    if (s == null) return;

    if (!triggered) {
      RectD expanded = RectD(s.rect.x - 2, s.rect.y - 2, s.rect.w + 4, s.rect.h + 4);
      if (expanded.intersects(engine.player.rect)) {
        triggered = true;
        s.type = TrollEntityType.spike;
        s.color = const Color(0xFFFF3366);
        s.rect = RectD(s.rect.x, s.rect.y + 20, s.rect.w, s.rect.h - 20); 
        s.isSolid = false;
      }
    }
  }
}

class AggressiveDoorTrap extends TrollTrap {
  final String doorId;
  TrollEntity? _door;
  bool triggered = false;

  AggressiveDoorTrap(this.doorId);

  @override
  void update(TrollEngine engine, double dt) {
    _door ??= engine.entities.where((e) => e.id == doorId).firstOrNull;
    var d = _door;
    if (d == null) return;

    if (!triggered && (engine.player.rect.x - d.rect.x).abs() < 200) {
      triggered = true;
      d.type = TrollEntityType.spike; 
      d.color = const Color(0xFFFF3366);
    }

    if (triggered) {
      d.rect.x -= 800 * dt; 
    }
  }
}

class SpotlightToggleTrap extends TrollTrap {
  final String triggerId;
  TrollEntity? _trigger;
  bool triggered = false;

  SpotlightToggleTrap(this.triggerId);

  @override
  void update(TrollEngine engine, double dt) {
    _trigger ??= engine.entities.where((e) => e.id == triggerId).firstOrNull;
    var t = _trigger;
    if (t == null) return;

    if (!triggered && (engine.player.rect.x - t.rect.x).abs() < 20) {
      triggered = true;
      engine.isSpotlightLevel = !engine.isSpotlightLevel;
      engine._spawnParticles(t.rect.x, t.rect.y + 20, 40, engine.isSpotlightLevel ? const Color(0xFF222222) : const Color(0xFFEEEEEE));
    }
  }
}

class TimeFreezeToggleTrap extends TrollTrap {
  final String triggerId;
  TrollEntity? _trigger;
  bool triggered = false;

  TimeFreezeToggleTrap(this.triggerId);

  @override
  void update(TrollEngine engine, double dt) {
    _trigger ??= engine.entities.where((e) => e.id == triggerId).firstOrNull;
    var t = _trigger;
    if (t == null) return;

    if (!triggered && (engine.player.rect.x - t.rect.x).abs() < 20) {
      triggered = true;
      engine.isTimeFreezeLevel = !engine.isTimeFreezeLevel;
      engine._spawnParticles(t.rect.x, t.rect.y + 20, 40, const Color(0xFF00AAFF)); // Ice blue particles
    }
  }
}

// ---------------- Engine Core ----------------

class TrollEngine {
  TrollEngine({this.round = 1}) {
    _loadLevel(round);
  }

  int round; 
  bool invertedControls = false;
  
  final double logicalWidth = 800;
  final double logicalHeight = 600;
  final double gs = 40.0; // Grid size
  double maxMapWidth = 800.0;
  double cameraX = 0;
  
  late TrollEntity player;
  List<TrollEntity> entities = [];
  List<TrollTrap> traps = [];
  List<Particle> particles = [];
  
  // Game State
  bool isDead = false;
  bool roundWon = false;
  bool allComplete = false;
  double transitionTimer = 0;
  double deathTimer = 0;
  
  // Score Tracking
  int correctCount = 0;
  int errorCount = 0;

  // Advanced Level Mechanics
  bool isSpotlightLevel = false;
  bool isWrapLevel = false;
  bool isTimeFreezeLevel = false;
  bool isLavaLevel = false;
  double lavaY = 800.0;
  bool isLowGravityLevel = false;
  bool isFlappyLevel = false;
  bool isTinyLevel = false;
  bool isDashLevel = false;
  bool hasDashed = false;
  bool isWindLevel = false;
  bool isIceLevel = false;
  bool isBlinkLevel = false;
  double blinkTimer = 0.0;
  bool isMirrorLevel = false;

  bool isGravityInverted = false;
  bool isBouncyLevel = false;
  bool isGhostLevel = false;
  bool isConveyorLevel = false;
  bool isChasedLevel = false;
  
  List<Offset> ghostHistory = [];
  double chaseWallX = -200;
  double chaseWallSpeed = 250;

  // Physics config
  final double gravity = 2500.0;
  final double moveAcceleration = 3500.0;
  final double friction = 2500.0;
  final double maxMoveSpeed = 380.0;
  final double jumpForce = -950.0; 
  
  // Input State
  bool movingLeft = false;
  bool movingRight = false;
  bool jumping = false;
  
  // Pro Mechanics
  double coyoteTimer = 0;
  double jumpBufferTimer = 0;
  bool _isGrounded = false;
  
  // Player Animation state
  double playerFaceDir = 1.0; 
  double playerScale = 1.0;

  void _spawnParticles(double px, double py, int count, Color c) {
    final rand = Random();
    for (int i = 0; i < count; i++) {
      double angle = rand.nextDouble() * 2 * pi;
      double speed = rand.nextDouble() * 400 + 100;
      particles.add(Particle(
        px, py,
        cos(angle) * speed, sin(angle) * speed,
        0.5 + rand.nextDouble() * 0.5,
        c
      ));
    }
  }

  void killPlayer() {
    if (isDead || roundWon) return;
    isDead = true;
    errorCount++;
    _spawnParticles(player.rect.x + player.rect.w/2, player.rect.y + player.rect.h/2, 40, const Color(0xFF00FFCC));
    deathTimer = 1.0;
  }

  void nextRound() {
    correctCount++;
    if (correctCount >= 3) {
      allComplete = true; // They finished this chapter!
    } else {
      round++;
      _loadLevel(round);
    }
  }

  void _loadLevel(int id) {
    entities.clear();
    traps.clear();
    particles.clear();
    isDead = false;
    roundWon = false;
    invertedControls = false; // Reset controls on new round
    transitionTimer = 0;
    movingLeft = false;
    movingRight = false;
    jumping = false;
    playerFaceDir = 1.0;
    playerScale = 1.0;
    coyoteTimer = 0;
    jumpBufferTimer = 0;
    cameraX = 0;
    isSpotlightLevel = false;
    isWrapLevel = false;
    isTimeFreezeLevel = false;
    isLavaLevel = false;
    lavaY = 800;
    isLowGravityLevel = false;
    isFlappyLevel = false;
    isTinyLevel = false;
    isDashLevel = false;
    hasDashed = false;
    isWindLevel = false;
    isIceLevel = false;
    isBlinkLevel = false;
    blinkTimer = 0;
    isMirrorLevel = false;

    isGravityInverted = false;
    isBouncyLevel = false;
    isGhostLevel = false;
    isConveyorLevel = false;
    isChasedLevel = false;
    ghostHistory.clear();
    chaseWallX = -200;

    int mapCols = 180; // Shorter map, tighter pacing!
    int currentCol = 15; // Track where traps are placed
    List<List<String>> grid = List.generate(15, (r) => List.generate(mapCols, (c) => '.'));

    // Base floor at row 13 and 14
    for (int c = 0; c < mapCols; c++) {
      grid[13][c] = 'X';
      grid[14][c] = 'X';
    }
    
    grid[12][2] = 'P';

    void addThwomp(int col) {
      for (int c = col; c < col + 4; c++) {
        grid[4][c] = 'X';
        grid[5][c] = 'v';
      }
      traps.add(ThwompCeilingTrap(
        RectD((col - 3) * gs, 10 * gs, 10 * gs, 5 * gs), 
        List.generate(4, (i) => "b_4_${col+i}") + List.generate(4, (i) => "s_5_${col+i}"),
        7 * gs 
      ));
    }

    void addAppearingSpikes(int col) {
      for (int c = col; c < col + 3; c++) {
        grid[12][c] = 'h';
      }
      traps.add(AppearingSpikesTrap(
        RectD((col - 3) * gs, 10 * gs, 9 * gs, 5 * gs), 
        List.generate(3, (i) => "s_12_${col+i}")
      ));
    }
    
    void addAppearingWall(int col) {
      for (int r = 10; r <= 12; r++) {
        grid[r][col] = 'W'; // W for hidden wall
      }
      traps.add(AppearingWallTrap(
        RectD((col - 4) * gs, 10 * gs, 8 * gs, 5 * gs), 
        ["b_10_$col", "b_11_$col", "b_12_$col"]
      ));
    }

    void addFallingFloor(int col, int width, {bool immediate = false}) {
      traps.add(FallingPlatformTrap(
        immediate 
          ? RectD(col * gs, 10 * gs, width * gs, 5 * gs) 
          : RectD((col - 3) * gs, 10 * gs, 2 * gs, 5 * gs),
        List.generate(width, (i) => "b_13_${col+i}") + List.generate(width, (i) => "b_14_${col+i}")
      ));
    }

    void addRunningDoor(int distanceAfterTrap, int moveDistance) {
      int doorCol = currentCol + distanceAfterTrap;
      if (doorCol >= mapCols - 5) doorCol = mapCols - 6; // Safety bounds
      
      if (isGravityInverted) {
        grid[4][doorCol] = 'D'; // Place on ceiling
      } else {
        grid[12][doorCol] = 'D'; // Place on floor
      }
      
      traps.add(RunningDoorTrap(
        RectD((doorCol - 6) * gs, isGravityInverted ? 0 : 7 * gs, 6 * gs, 6 * gs), 
        "door", 
        moveDistance * gs
      ));
      
      for (int c = doorCol + 5; c < mapCols; c++) {
        if (!isGravityInverted) {
          grid[13][c] = '.';
          grid[14][c] = '.';
        } else {
          grid[2][c] = '.';
          grid[3][c] = '.';
        }
      }
    }

    // NEW C2 HELPERS
    void addFakeSolid(int col, int width) {
      for (int c = col; c < col + width; c++) {
        grid[13][c] = 'X'; 
        grid[14][c] = 'X'; 
      }
      traps.add(FakeSolidTrap(
        RectD(col * gs, 10 * gs, width * gs, 5 * gs), 
        List.generate(width, (i) => "b_13_${col+i}") + List.generate(width, (i) => "b_14_${col+i}")
      ));
    }

// deleted
// deleted
// deleted
// deleted
// deleted

    void addErraticSpike(int col) {
      grid[12][col] = 's'; 
      traps.add(ErraticPatrolSpikeTrap("s_12_$col", 220)); 
    }

    // NEW C3 HELPERS
    void addJumpTriggeredDrop(int col, int width) {
      for (int c = col; c < col + width; c++) {
        grid[13][c] = 'X'; 
        grid[14][c] = 'X'; 
      }
      traps.add(JumpTriggeredDropTrap(
        List.generate(width, (i) => "b_13_${col+i}") + List.generate(width, (i) => "b_14_${col+i}")
      ));
    }

    void addTrollSpring(int col) {
      grid[12][col] = 'S'; 
      traps.add(TrollSpringTrap("S_12_$col"));
    }

    void addAggressiveDoor(int col) {
      grid[11][col] = 'A'; // Aggressive door
      traps.add(AggressiveDoorTrap("A_11_$col"));
    }

    void addSpotlightToggle(int col) {
      grid[12][col] = 'L'; // Spotlight Trigger
      traps.add(SpotlightToggleTrap("L_12_$col"));
    }

    void addTimeFreezeToggle(int col) {
      grid[12][col] = 'T'; // Time Freeze Trigger
      traps.add(TimeFreezeToggleTrap("T_12_$col"));
    }

    // Tighter pacing: EXACTLY 3 traps per round. Total length ~80 blocks.
    if (id >= 1 && id <= 3) {
      currentCol = 15;
      for (int trapCount = 0; trapCount < 3; trapCount++) {
         addAppearingSpikes(currentCol); currentCol += 6;
         if (id >= 2) { addFallingFloor(currentCol, 3, immediate: true); currentCol += 6; }
         if (id == 3) { addAppearingWall(currentCol); currentCol += 6; }
         currentCol += 8;
      }
      addRunningDoor(10, 0);
    } else if (id >= 4 && id <= 6) {
      currentCol = 15;
      for (int trapCount = 0; trapCount < 3; trapCount++) {
         addErraticSpike(currentCol); currentCol += 6;
         if (id >= 5) { addThwomp(currentCol); currentCol += 6; }
         if (id == 6) { addFakeSolid(currentCol, 4); currentCol += 6; }
         currentCol += 8;
      }
      addRunningDoor(10, 0);
    } else if (id >= 7 && id <= 9) {
      currentCol = 15;
      for (int trapCount = 0; trapCount < 3; trapCount++) {
         addJumpTriggeredDrop(currentCol, 6); // Wider trap area
         grid[12][currentCol + 2] = 's'; // A spike forcing them to jump WHILE on the trap!
         currentCol += 8;
         if (id >= 8) { addTrollSpring(currentCol); currentCol += 6; }
         if (id == 9) { addAggressiveDoor(currentCol); currentCol += 6; }
         currentCol += 6;
      }
      addRunningDoor(10, 0);
    } else if (id >= 10 && id <= 12) {
      if (id == 11) {
        isSpotlightLevel = true; // dark start
      } else {
        isSpotlightLevel = false;
      }
      if (id == 12) { isWrapLevel = true; isSpotlightLevel = false; }
      currentCol = 15;
      for (int trapCount = 0; trapCount < 3; trapCount++) {
         addSpotlightToggle(currentCol); currentCol += 6;
         addThwomp(currentCol); currentCol += 6;
         if (id >= 11) { addSpotlightToggle(currentCol); currentCol += 6; addErraticSpike(currentCol); currentCol += 6; }
         currentCol += 4;
      }
      addRunningDoor(10, 0);
    } else if (id >= 13 && id <= 15) {
      isTimeFreezeLevel = (id >= 14);
      currentCol = 15;
      for (int trapCount = 0; trapCount < 3; trapCount++) {
         addTimeFreezeToggle(currentCol); currentCol += 6;
         addThwomp(currentCol); currentCol += 6;
         if (id >= 14) { addFakeSolid(currentCol, 4); currentCol += 6; }
         if (id == 15) { addAppearingSpikes(currentCol); currentCol += 6; }
         currentCol += 4;
      }
      addRunningDoor(10, 0);
    } else if (id >= 16 && id <= 18) {
      isGravityInverted = true;
      for (int c = 0; c < mapCols; c++) { grid[2][c] = 'X'; grid[3][c] = 'X'; }
      grid[13][2] = '.'; grid[14][2] = '.';
      currentCol = 15;
      for (int trapCount = 0; trapCount < 3; trapCount++) {
         grid[4][currentCol] = 'v'; traps.add(ErraticPatrolSpikeTrap("s_4_$currentCol", 220)); currentCol += 8;
         if (id >= 17) { traps.add(FakeSolidTrap(RectD((currentCol - 2) * gs, 3 * gs, 7 * gs, 5 * gs), List.generate(4, (i) => "b_2_${currentCol+i}") + List.generate(4, (i) => "b_3_${currentCol+i}"))); currentCol += 8; }
         if (id == 18) { for (int c = currentCol; c < currentCol + 3; c++) { grid[4][c] = 'v'; } traps.add(AppearingSpikesTrap(RectD((currentCol - 2) * gs, 3 * gs, 7 * gs, 5 * gs), List.generate(3, (i) => "s_4_${currentCol+i}"))); currentCol += 8; }
         currentCol += 4;
      }
      addRunningDoor(10, 0);
    } else if (id >= 19 && id <= 21) {
      isBouncyLevel = true;
      currentCol = 15;
      for (int trapCount = 0; trapCount < 3; trapCount++) {
         addThwomp(currentCol); currentCol += 8;
         if (id >= 20) { addJumpTriggeredDrop(currentCol, 4); currentCol += 8; }
         if (id == 21) { addErraticSpike(currentCol); currentCol += 8; }
         currentCol += 4;
      }
      addRunningDoor(10, 0);
    } else if (id >= 22 && id <= 24) {
      isGhostLevel = true;
      currentCol = 15;
      for (int trapCount = 0; trapCount < 3; trapCount++) {
         addFallingFloor(currentCol, 4); currentCol += 8;
         if (id >= 23) { addAppearingSpikes(currentCol); currentCol += 8; }
         if (id == 24) { addFakeSolid(currentCol, 3); currentCol += 8; }
         currentCol += 4;
      }
      addRunningDoor(10, 0);
    } else if (id >= 25 && id <= 27) {
      isConveyorLevel = true;
      for (int c = 10; c < mapCols; c++) {
        if (id == 27) { grid[13][c] = '>'; grid[14][c] = '>'; }
        else if (c % 15 < 7) { grid[13][c] = '>'; grid[14][c] = '>'; }
        else { grid[13][c] = '<'; grid[14][c] = '<'; }
      }
      currentCol = 15;
      for (int trapCount = 0; trapCount < 3; trapCount++) {
         addThwomp(currentCol); currentCol += 8;
         if (id >= 26) { addErraticSpike(currentCol); currentCol += 8; }
         if (id == 27) { addAggressiveDoor(currentCol); currentCol += 8; }
         currentCol += 4;
      }
      addRunningDoor(10, 0);
    } else if (id >= 28 && id <= 30) {
      isChasedLevel = true; chaseWallX = -200; chaseWallSpeed = 220 + (id-28)*15;
      currentCol = 15;
      for (int trapCount = 0; trapCount < 3; trapCount++) {
         addFakeSolid(currentCol, 4); currentCol += 8;
         if (id >= 29) { addThwomp(currentCol); currentCol += 8; }
         if (id == 30) { addErraticSpike(currentCol); currentCol += 8; }
         currentCol += 4;
      }
      addRunningDoor(10, 0);
    } else if (id >= 31 && id <= 33) {
      isLavaLevel = true; 
      lavaY = 700; // starts exactly below screen
      
      // Remove default floor to make it a jumping puzzle
      for (int c = 0; c < mapCols; c++) { grid[13][c] = '.'; grid[14][c] = '.'; }
      
      // Solid starting platform (Row 13 and 14)
      for (int c = 0; c < 6; c++) {
          grid[13][c] = 'X'; grid[14][c] = 'X';
      }
      
      // RESTORE PLAYER SPAWN!
      grid[12][2] = 'P';
      
      currentCol = 6;
      
      for (int trapCount = 0; trapCount < 3; trapCount++) {
         // Gap of 3 blocks
         currentCol += 3;
         
         // Platform 1 (3 blocks wide, row 13)
         grid[13][currentCol] = 'X'; grid[13][currentCol+1] = 'X'; grid[13][currentCol+2] = 'X';
         grid[14][currentCol] = 'X'; grid[14][currentCol+1] = 'X'; grid[14][currentCol+2] = 'X';
         if (id >= 32) {
             grid[12][currentCol+1] = 's'; // Spike in the middle
         }
         currentCol += 3;
         
         // Gap of 3 blocks
         currentCol += 3;
         
         // Platform 2 (3 blocks wide, row 13)
         grid[13][currentCol] = 'X'; grid[13][currentCol+1] = 'X'; grid[13][currentCol+2] = 'X';
         grid[14][currentCol] = 'X'; grid[14][currentCol+1] = 'X'; grid[14][currentCol+2] = 'X';
         if (id == 33) {
             grid[12][currentCol+1] = 's'; traps.add(ErraticPatrolSpikeTrap("s_12_${currentCol+1}", 200)); 
         }
         currentCol += 3;
         
         // Gap of 2 blocks before next
         currentCol += 2;
      }
      
      // Ending runway
      for (int c = currentCol; c < currentCol + 15; c++) {
          grid[13][c] = 'X'; grid[14][c] = 'X';
      }
      addRunningDoor(5, 0);
    } else if (id >= 34 && id <= 36) {
      isLowGravityLevel = true;
      currentCol = 15;
      for (int trapCount = 0; trapCount < 3; trapCount++) {
         int gap = (id == 34) ? 8 : 12; 
         for (int i=0; i<gap; i++) { grid[13][currentCol+i] = '.'; grid[14][currentCol+i] = '.'; }
         currentCol += gap;
         
         for (int i=0; i<4; i++) {
           grid[13][currentCol+i] = 'X';
         }
         if (id >= 35) addErraticSpike(currentCol);
         if (id == 36) addFallingFloor(currentCol, 4, immediate: true);
         currentCol += 8;
      }
      addRunningDoor(10, 0);
    } else if (id >= 37 && id <= 39) {
      isFlappyLevel = true;
      currentCol = 15;
      for (int trapCount = 0; trapCount < 3; trapCount++) {
         int gap = 15; 
         for (int i=0; i<gap; i++) { grid[13][currentCol+i] = '.'; grid[14][currentCol+i] = '.'; }
         
         if (id >= 38) { grid[7][currentCol+5] = 'X'; grid[8][currentCol+5] = 'X'; }
         if (id == 39) { grid[10][currentCol+10] = 'X'; grid[11][currentCol+10] = 'X'; }
         
         currentCol += gap;
         for (int i=0; i<4; i++) {
           grid[13][currentCol+i] = 'X';
         }
         currentCol += 6;
      }
      addRunningDoor(10, 0);
    } else if (id >= 40 && id <= 42) {
      isTinyLevel = true;
      currentCol = 15;
      for (int trapCount = 0; trapCount < 3; trapCount++) {
         for (int r = 10; r <= 12; r++) {
           grid[r][currentCol] = 'X';
         }
         grid[12][currentCol] = '.'; 
         currentCol += 4;
         
         if (id >= 41) addAppearingSpikes(currentCol);
         currentCol += 6;
         if (id == 42) addThwomp(currentCol);
         currentCol += 6;
      }
      addRunningDoor(10, 0);
    } else if (id >= 43 && id <= 45) {
      isDashLevel = true;
      currentCol = 15;
      for (int trapCount = 0; trapCount < 3; trapCount++) {
         int gap = (id == 43) ? 9 : (id == 44) ? 10 : 12; 
         for (int i=0; i<gap; i++) { grid[13][currentCol+i] = '.'; grid[14][currentCol+i] = '.'; }
         currentCol += gap;
         
         for (int i=0; i<10; i++) {
           grid[13][currentCol+i] = 'X';
         } 
         if (id >= 44) addFallingFloor(currentCol, 10, immediate: true);
         if (id == 45) grid[12][currentCol + 6] = 's'; 
         currentCol += 11;
      }
      addRunningDoor(10, 0);
    } else if (id >= 46 && id <= 48) {
      isWindLevel = true; 
      currentCol = 15;
      for (int trapCount = 0; trapCount < 3; trapCount++) {
         int gap = 3; 
         for (int i=0; i<gap; i++) { grid[13][currentCol+i] = '.'; grid[14][currentCol+i] = '.'; }
         currentCol += gap;
         
         for (int i=0; i<4; i++) {
           grid[13][currentCol+i] = 'X';
         }
         if (id >= 47) addJumpTriggeredDrop(currentCol, 2);
         if (id == 48) addErraticSpike(currentCol);
         currentCol += 6;
      }
      addRunningDoor(10, 0);
    } else if (id >= 49 && id <= 51) {
      isIceLevel = true;
      currentCol = 15;
      for (int trapCount = 0; trapCount < 3; trapCount++) {
         int gap = 4;
         for (int i=0; i<gap; i++) { grid[13][currentCol+i] = '.'; grid[14][currentCol+i] = '.'; }
         currentCol += gap;
         
         for (int i=0; i<8; i++) {
           grid[13][currentCol+i] = 'X';
         } 
         if (id >= 50) grid[12][currentCol + 3] = 's'; 
         if (id == 51) grid[12][currentCol + 6] = 's'; 
         currentCol += 10;
      }
      addRunningDoor(10, 0);
    } else if (id >= 52 && id <= 54) {
      isBlinkLevel = true; 
      currentCol = 15;
      for (int trapCount = 0; trapCount < 3; trapCount++) {
         int gap = 3; 
         for (int i=0; i<gap; i++) { grid[13][currentCol+i] = '.'; grid[14][currentCol+i] = '.'; }
         currentCol += gap;
         
         for (int i=0; i<6; i++) {
           grid[13][currentCol+i] = 'X';
         } 
         if (id >= 53) grid[12][currentCol + 2] = 's'; 
         if (id == 54) grid[12][currentCol + 4] = 's'; 
         currentCol += 8;
      }
      addRunningDoor(10, 0);
    } else if (id >= 55 && id <= 57) {
      isMirrorLevel = true; 
      currentCol = 15;
      for (int trapCount = 0; trapCount < 3; trapCount++) {
         int gap = 3;
         for (int i=0; i<gap; i++) { grid[13][currentCol+i] = '.'; grid[14][currentCol+i] = '.'; }
         currentCol += gap;
         
         for (int i=0; i<5; i++) {
           grid[13][currentCol+i] = 'X';
         }
         if (id >= 56) grid[12][currentCol + 2] = 's'; 
         if (id == 57) grid[12][currentCol + 4] = 's'; 
         currentCol += 7;
      }
      addRunningDoor(10, 0);
    } else if (id >= 58 && id <= 60) {
      isIceLevel = true;
      isLowGravityLevel = true;
      isChasedLevel = true; chaseWallX = -200; chaseWallSpeed = (id == 60) ? 320 : 250;
      currentCol = 15;
      for (int trapCount = 0; trapCount < 3; trapCount++) {
         addErraticSpike(currentCol);
         currentCol += 8;
         if (id >= 59) { addThwomp(currentCol); currentCol += 8; }
         if (id == 60) { addFakeSolid(currentCol, 4); currentCol += 8; }
         currentCol += 4;
      }
      addRunningDoor(10, 0);
    }

    List<String> mapStrings = [];
    for (int r = 0; r < 15; r++) {
      mapStrings.add(grid[r].join(''));
    }
    
    
    _parseMap(mapStrings);
    
    if (isTinyLevel) {
      player.rect.w = 20;
      player.rect.h = 20;
      player.rect.y += 15; // adjust to floor
    }

  }

  void _parseMap(List<String> map) {
    maxMapWidth = map[0].length * gs;
    for (int row = 0; row < map.length; row++) {
      for (int col = 0; col < map[row].length; col++) {
        String char = map[row][col];
        double x = col * gs;
        double y = row * gs;
        
        if (char == 'S') { // Troll Spring
          entities.add(TrollEntity(
            id: 'S_${row}_$col', type: TrollEntityType.block,
            rect: RectD(x, y + 20, gs, gs - 20),
            color: const Color(0xFF00FF00), // Bright green
            isSolid: true, // Acts as a block at first
          ));
        } else if (char == 'A') { // Aggressive Door
          entities.add(TrollEntity(
            id: 'A_${row}_$col', type: TrollEntityType.door,
            rect: RectD(x, y - 20, gs, gs + 20),
            color: const Color(0xFFFFD700), // Looks like a door!
            isSolid: false,
          ));
        } else if (char == 'P') {
          player = TrollEntity(
            id: 'player', type: TrollEntityType.player,
            rect: RectD(x + 5, y + 5, 30, 35),
            color: const Color(0xFF00FFCC),
          );
        } else if (char == 'r') {
          entities.add(TrollEntity(
            id: 'r_${row}_$col', type: TrollEntityType.block,
            rect: RectD(x, y, gs, gs), isSolid: false, isVisible: false
          ));
        } else if (char == 'L') {
          entities.add(TrollEntity(
            id: 'L_${row}_$col', type: TrollEntityType.block,
            rect: RectD(x + 15, y - 3 * gs, 10, 4 * gs),
            color: const Color(0x66FFFFFF),
            isSolid: false, isVisible: true
          ));
        } else if (char == 'T') {
          entities.add(TrollEntity(
            id: 'T_${row}_$col', type: TrollEntityType.block,
            rect: RectD(x + 15, y - 3 * gs, 10, 4 * gs),
            color: const Color(0x6600AAFF),
            isSolid: false, isVisible: true
          ));
        } else if (char == '>') {
          entities.add(TrollEntity(
            id: 'b_${row}_$col', type: TrollEntityType.block,
            rect: RectD(x, y, gs, gs),
            color: const Color(0xFF00FF00),
          ));
        } else if (char == '<') {
          entities.add(TrollEntity(
            id: 'b_${row}_$col', type: TrollEntityType.block,
            rect: RectD(x, y, gs, gs),
            color: const Color(0xFFFF0000),
          ));
        } else if (char == 'b') { // Hidden wall block
          entities.add(TrollEntity(
            id: 'b_${row}_$col', type: TrollEntityType.block,
            rect: RectD(x, y, gs, gs),
            color: const Color(0xFF333333),
            isSolid: false,
            isVisible: false,
          ));
        } else if (char == 'X') {
          entities.add(TrollEntity(
            id: 'b_${row}_$col', type: TrollEntityType.block,
            rect: RectD(x, y, gs, gs),
            color: const Color(0xFF2C2F33),
          ));
        } else if (char == 'W') { // Hidden wall block
          entities.add(TrollEntity(
            id: 'b_${row}_$col', type: TrollEntityType.block,
            rect: RectD(x, y, gs, gs),
            color: const Color(0xFF333333),
            isSolid: false,
            isVisible: false,
          ));
        } else if (char == 'h') { // Hidden spike on ground
          entities.add(TrollEntity(
            id: 's_${row}_$col', type: TrollEntityType.spike,
            rect: RectD(x, y + 20, gs, gs - 20), // Short spike
            color: const Color(0xFFFF3366),
            isSolid: false,
            isVisible: false, // Starts hidden!
          ));
        } else if (char == 's') { // Normal visible spike on ground
          entities.add(TrollEntity(
            id: 's_${row}_$col', type: TrollEntityType.spike,
            rect: RectD(x, y + 20, gs, gs - 20), // Short spike
            color: const Color(0xFFFF3366),
            isSolid: false,
          ));
        } else if (char == 'v') { // Inverted spike under ceiling
          entities.add(TrollEntity(
            id: 's_${row}_$col', type: TrollEntityType.spike,
            rect: RectD(x, y, gs, gs - 20),
            color: const Color(0xFFFF3366),
            isSolid: false,
            isInverted: true,
          ));
        } else if (char == 'D') {
          entities.add(TrollEntity(
            id: 'door', type: TrollEntityType.door,
            rect: RectD(x, y - 20, 40, 60),
            color: const Color(0xFFFFD700),
            isSolid: false,
          ));
        }
      }
    }
  }

  void update(double dt) {
    if (dt > 0.05) dt = 0.05;
    
    final double maxFallSpeed = 900.0;
    
    // Camera Logic
    if ( !isDead) {
      double targetCameraX = player.rect.x - logicalWidth / 2 + player.rect.w / 2;
      if (targetCameraX < 0) targetCameraX = 0;
      if (targetCameraX > maxMapWidth - logicalWidth) targetCameraX = maxMapWidth - logicalWidth;
      cameraX += (targetCameraX - cameraX) * 5 * dt; // Smooth follow
    }

    // Particles
    for (int i = particles.length - 1; i >= 0; i--) {
      var p = particles[i];
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.vy += gravity * 0.5 * dt;
      p.life -= dt;
      if (p.life <= 0) particles.removeAt(i);
    }

    if (isDead) {
      playerScale = max(0.0, playerScale - dt * 4);
      deathTimer -= dt;
      if (deathTimer <= 0) {
        _loadLevel(round); // Respawn in SAME round
      }
      return;
    }
    
    if (roundWon) {
      transitionTimer += dt;
      if (transitionTimer >= 1.0) {
        nextRound();
      }
      return;
    }
    if (allComplete) return;

    bool playerIsMoving = player.vx.abs() > 5 || player.vy.abs() > 5 || movingLeft || movingRight || jumping;

    // Update Traps
    for (var t in traps) {
      if (isTimeFreezeLevel && !playerIsMoving) continue;
      t.update(this, dt);
    }

    // --- Pro Platformer Physics ---
    
    double currentJumpForce = jumpForce;
    double currentGravity = 2500.0;
    double currentAccel = moveAcceleration;
    double currentFriction = friction;
    
    if (isLowGravityLevel) {
       currentGravity = 800.0;
       currentJumpForce = -650.0;
    }
    if (isIceLevel) {
       currentFriction = 300.0; // Slippery
       currentAccel = 800.0;
    }
    if (isFlappyLevel) {
       currentJumpForce = -500.0;
    }

    if (jumping) {
      jumpBufferTimer = 0.15; // Queue jump
      jumping = false;
    } else {
      jumpBufferTimer -= dt;
    }

    if (_isGrounded) {
      coyoteTimer = 0.15;
      hasDashed = false; // Reset dash on ground
    } else {
      coyoteTimer -= dt;
    }
    
    if (isFlappyLevel) {
       // Infinite mid-air jumps
       coyoteTimer = 1.0; 
    }

    if (jumpBufferTimer > 0 && coyoteTimer > 0) {
      player.vy = isGravityInverted ? -currentJumpForce : currentJumpForce;
      coyoteTimer = 0;
      jumpBufferTimer = 0;
    } else if (isDashLevel && jumpBufferTimer > 0 && coyoteTimer <= 0 && !hasDashed) {
      // Air Dash mechanic
      hasDashed = true;
      player.vx = playerFaceDir * 1500.0; 
      player.vy = 0;
      jumpBufferTimer = 0;
    }

    // INVERTED CONTROLS LOGIC
    bool actualMoveLeft = invertedControls ? movingRight : movingLeft;
    bool actualMoveRight = invertedControls ? movingLeft : movingRight;

    if (actualMoveLeft) {
      playerFaceDir = invertedControls ? 1.0 : -1.0;
      player.vx -= currentAccel * dt;
      if (player.vx < -maxMoveSpeed && !(isDashLevel && hasDashed)) player.vx = -maxMoveSpeed;
    } else if (actualMoveRight) {
      playerFaceDir = invertedControls ? -1.0 : 1.0;
      player.vx += currentAccel * dt;
      if (player.vx > maxMoveSpeed && !(isDashLevel && hasDashed)) player.vx = maxMoveSpeed;
    } else {
      if (player.vx > 0) {
        player.vx -= currentFriction * dt;
        if (player.vx < 0) player.vx = 0;
      } else if (player.vx < 0) {
        player.vx += currentFriction * dt;
        if (player.vx > 0) player.vx = 0;
      }
    }
    
    if (isWindLevel) {
       player.vx -= 300.0 * dt; // Wind pushes left constantly
    }

    if (isGravityInverted) {
      player.vy -= currentGravity * dt; // Fall UP
    } else {
      player.vy += currentGravity * dt; // Fall DOWN
    }
    
    if (player.vy > maxFallSpeed) player.vy = maxFallSpeed;
    if (player.vy < -maxFallSpeed) player.vy = -maxFallSpeed;

    _isGrounded = false;
    
    if (isGhostLevel) {
       if (ghostHistory.isEmpty) {
         if (movingLeft || movingRight || jumping) {
           ghostHistory.add(Offset(player.rect.x, player.rect.y));
         }
       } else {
         ghostHistory.add(Offset(player.rect.x, player.rect.y));
         int maxHistory = (2.0 / 0.016).round();
         if (ghostHistory.length > maxHistory) {
           ghostHistory.removeAt(0);
         }
         if (ghostHistory.length >= maxHistory && !isDead) {
           RectD ghostRect = RectD(ghostHistory.first.dx, ghostHistory.first.dy, player.rect.w, player.rect.h);
           if (ghostRect.intersects(player.rect)) {
             killPlayer();
           }
         }
       }
    }

    // Move X
    player.rect.x += player.vx * dt;
    _resolveCollisions(true);

    // Move Y
    player.rect.y += player.vy * dt;
    _resolveCollisions(false);
    
    if (isConveyorLevel && _isGrounded) {
      for (var e in entities) {
        if (e.isSolid && e.rect.top == player.rect.bottom &&
            player.rect.right > e.rect.left && player.rect.left < e.rect.right) {
           if (e.color == const Color(0xFF00FF00)) player.rect.x += 350 * dt; 
           if (e.color == const Color(0xFFFF0000)) player.rect.x -= 350 * dt; 
        }
      }
    }
    
    if (isBouncyLevel && _isGrounded) {
       player.vy = isGravityInverted ? 700 : -700; // BOUNCE!
       _spawnParticles(player.rect.x + 10, player.rect.bottom, 10, const Color(0xFF00FFCC));
    }
    
    
    if (_isGrounded) {
       hasDashed = false;
    }
    
    if (isLavaLevel) {
       // Retreat lava if player is near the end!
       if (player.rect.x > maxMapWidth - (25 * gs)) {
           lavaY += 300 * dt; // Retreats extremely fast!
       } else {
           lavaY -= 10 * dt; 
       }
       if (player.rect.bottom > lavaY) {
          killPlayer();
       }
    }
    
    if (isBlinkLevel) {
       blinkTimer += dt;
    }

    if (isChasedLevel) {
       chaseWallX += chaseWallSpeed * dt;
       if (player.rect.x < chaseWallX) {
         killPlayer();
       }
    }
    
    if (player.rect.y > 700 || player.rect.y < -300) { // Check both bounds for inverted gravity
      if (isWrapLevel) {
        player.rect.y = player.rect.y > 700 ? -50 : 650;
        player.vy = 0;
      } else {
        killPlayer();
      }
    }

    for (var e in entities) {
      if (isTimeFreezeLevel && !playerIsMoving) continue;
      if (e.activePhysics) {
        e.vy += gravity * dt;
        e.rect.y += e.vy * dt;
        
        if (player.rect.bottom >= e.rect.top && 
            player.rect.bottom <= e.rect.top + 15 &&
            player.rect.right > e.rect.left && 
            player.rect.left < e.rect.right && player.vy > 0) {
           player.rect.y = e.rect.top - player.rect.h;
           _isGrounded = true;
           player.vy = e.vy;
        }
      }
    }

    // Hitboxes (shrink player hitbox slightly to prevent unfair deaths)
    RectD shrinkHitbox = RectD(player.rect.x + 8, player.rect.y + 10, player.rect.w - 16, player.rect.h - 15);
    
    for (var e in entities) {
      if (e.type == TrollEntityType.spike && e.isVisible) {
        if (shrinkHitbox.intersects(e.rect)) {
          killPlayer();
        }
      } else if (e.type == TrollEntityType.door) {
        if (player.rect.intersects(e.rect)) {
          roundWon = true;
          playerScale = 0.0; // disappear into door
          _spawnParticles(e.rect.x + 20, e.rect.y + 30, 20, const Color(0xFFFFD700));
        }
      }
    }
  }

  void _resolveCollisions(bool isAxisX) {
    for (var e in entities) {
      if (!e.isSolid) continue;
      
      if (player.rect.intersects(e.rect)) {
        if (isAxisX) {
          if (player.vx > 0) {
            player.rect.x = e.rect.left - player.rect.w;
          } else if (player.vx < 0) {
            player.rect.x = e.rect.right;
          }
          player.vx = 0;
        } else {
          if (player.vy > 0) {
            player.rect.y = e.rect.top - player.rect.h;
            if (!isGravityInverted) _isGrounded = true;
          } else if (player.vy < 0) {
            player.rect.y = e.rect.bottom;
            if (isGravityInverted) _isGrounded = true;
          }
          player.vy = 0;
        }
      }
    }
  }
}
