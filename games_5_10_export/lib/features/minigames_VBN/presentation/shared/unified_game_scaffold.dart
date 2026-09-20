import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'minigame_environment.dart';

class UnifiedGameScaffold extends StatefulWidget {
  const UnifiedGameScaffold({super.key, required this.child});
  final Widget child;

  @override
  State<UnifiedGameScaffold> createState() => _UnifiedGameScaffoldState();
}

class _UnifiedGameScaffoldState extends State<UnifiedGameScaffold> with TickerProviderStateMixin {
  final List<_FeedbackParticle> _particles = [];
  late AnimationController _shakeController;
  late AnimationController _flashController;
  bool _isSuccessFlash = true;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _flashController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final env = MinigameEnvironment.of(context);
    env.feedbackStream.listen(_handleFeedback);
  }

  void _handleFeedback(MinigameFeedbackEvent event) {
    if (!mounted) return;
    
    _isSuccessFlash = event.isSuccess;
    _flashController.forward(from: 0.0);

    if (!event.isSuccess) {
      _shakeController.forward(from: 0.0);
    }
    
    // Spawn particles around the center or tap position
    setState(() {
      final random = math.Random();
      for (int i = 0; i < (event.isSuccess ? 15 : 10); i++) {
        double angle = random.nextDouble() * math.pi * 2;
        double speed = random.nextDouble() * 5 + 3;
        _particles.add(_FeedbackParticle(
          x: event.position.dx == 0 ? MediaQuery.of(context).size.width/2 : event.position.dx,
          y: event.position.dy == 0 ? MediaQuery.of(context).size.height/2 : event.position.dy,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed,
          color: event.isSuccess ? Colors.greenAccent : Colors.redAccent,
          isStar: event.isSuccess,
          life: 1.0,
        ));
      }
    });
    _updateParticles();
  }

  void _updateParticles() {
    if (!mounted) return;
    bool hasAlive = false;
    setState(() {
      for (var p in _particles) {
        p.x += p.vx;
        p.y += p.vy;
        p.life -= 0.03;
        if (p.life > 0) hasAlive = true;
      }
      _particles.removeWhere((p) => p.life <= 0);
    });
    if (hasAlive) {
      Future.delayed(const Duration(milliseconds: 16), _updateParticles);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final env = MinigameEnvironment.of(context);

    return AnimatedBuilder(
      animation: Listenable.merge([env, _shakeController, _flashController]),
      builder: (context, _) {
        double shakeOffset = math.sin(_shakeController.value * math.pi * 6) * 8 * (1 - _shakeController.value);
        
        return Container(
          // Clean, modern, elegant gradient background
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0F172A), // Deep slate
                Color(0xFF1E1B4B), // Deep violet
                Color(0xFF312E81), // Indigo
              ],
            ),
          ),
          child: Stack(
            children: [
              SafeArea(
                child: Transform.translate(
                  offset: Offset(shakeOffset, 0),
                  child: Column(
                    children: [
                      // HUD: Elegant and compact
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  env.title,
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                if (env.combo > 1)
                                  Text(
                                    '?? x${env.combo}',
                                    style: const TextStyle(color: Colors.orangeAccent, fontSize: 18, fontWeight: FontWeight.w900),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.stars, color: Colors.amber, size: 28),
                                const SizedBox(width: 8),
                                Text(
                                  env.score.toString().padLeft(4, '0'),
                                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: env.timeProgress.clamp(0.0, 1.0),
                                      minHeight: 14,
                                      backgroundColor: Colors.white12,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        env.timeProgress > 0.8 ? Colors.redAccent : Colors.greenAccent,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // UNIFIED GAME BOARD FRAME
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2), // Dark unified play area
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 2),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 15, spreadRadius: 2)
                            ],
                          ),
                          clipBehavior: Clip.hardEdge,
                          // Center the game so it doesn't stretch weirdly if it has its own AspectRatio
                          child: SizedBox.expand(child: widget.child),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Top-Center Success/Error Flash Overlay
              if (_flashController.isAnimating)
                Positioned(
                  top: 80,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: FadeTransition(
                      opacity: Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _flashController, curve: Curves.easeOut)),
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.8, end: 1.2).animate(CurvedAnimation(parent: _flashController, curve: Curves.easeOutBack)),
                        child: Icon(
                          _isSuccessFlash ? Icons.check_circle : Icons.cancel,
                          color: _isSuccessFlash ? Colors.greenAccent.withValues(alpha: 0.4) : Colors.redAccent.withValues(alpha: 0.4),
                          size: 80,
                        ),
                      ),
                    ),
                  ),
                ),

              // Feedback Particles Overlay
              ..._particles.map((p) => Positioned(
                left: p.x - 10,
                top: p.y - 10,
                child: Opacity(
                  opacity: p.life.clamp(0.0, 1.0),
                  child: Icon(
                    p.isStar ? Icons.star : Icons.close,
                    color: p.color,
                    size: 24,
                  ),
                ),
              )),
            ],
          ),
        );
      }
    );
  }
}

class _FeedbackParticle {
  double x, y, vx, vy, life;
  Color color;
  bool isStar;
  _FeedbackParticle({required this.x, required this.y, required this.vx, required this.vy, required this.color, required this.isStar, required this.life});
}


