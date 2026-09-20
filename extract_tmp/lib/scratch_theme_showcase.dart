import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ThemeShowcase(),
  ));
}

class ThemeShowcase extends StatefulWidget {
  const ThemeShowcase({super.key});
  @override
  State<ThemeShowcase> createState() => _ThemeShowcaseState();
}

class _ThemeShowcaseState extends State<ThemeShowcase> {
  final PageController _controller = PageController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            children: const [
              NeonArcadeTheme(),
              MagicalFantasyTheme(),
              GameShowTheme(),
            ],
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
                  onPressed: () => _controller.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('??????', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 40),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
                  onPressed: () => _controller.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('??????', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            )
          )
        ],
      ),
    );
  }
}

// ==========================================
// 1. Neon Arcade Theme
// ==========================================
class NeonArcadeTheme extends StatefulWidget { const NeonArcadeTheme({super.key}); @override State<NeonArcadeTheme> createState() => _NeonArcadeThemeState(); }
class _NeonArcadeThemeState extends State<NeonArcadeTheme> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return CustomPaint(
          painter: ArcadePainter(_ctrl.value),
          child: _buildHUD('NEON ARCADE', Colors.cyanAccent, Colors.pinkAccent),
        );
      }
    );
  }
}
class ArcadePainter extends CustomPainter {
  final double progress;
  ArcadePainter(this.progress);
  @override void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF0F0C29));
    final paint = Paint()..color = Colors.pinkAccent.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 2;
    // Draw perspective grid
    double horizon = size.height * 0.4;
    for (int i = 0; i <= 10; i++) {
      double startX = size.width * (i / 10.0);
      canvas.drawLine(Offset(startX, size.height), Offset(size.width / 2, horizon), paint);
    }
    for (int i = 0; i < 15; i++) {
      double y = horizon + math.pow((i + progress) / 15, 2) * (size.height - horizon);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override bool shouldRepaint(covariant CustomPainter old) => true;
}

// ==========================================
// 2. Magical Fantasy Theme
// ==========================================
class MagicalFantasyTheme extends StatefulWidget { const MagicalFantasyTheme({super.key}); @override State<MagicalFantasyTheme> createState() => _MagicalFantasyThemeState(); }
class _MagicalFantasyThemeState extends State<MagicalFantasyTheme> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat(); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return CustomPaint(
          painter: MagicPainter(_ctrl.value),
          child: _buildHUD('MAGICAL FANTASY', Colors.amberAccent, const Color(0xFF2E7D32)),
        );
      }
    );
  }
}
class MagicPainter extends CustomPainter {
  final double time;
  MagicPainter(this.time);
  @override void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = const LinearGradient(colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(rect));
    final random = math.Random(123);
    for (int i = 0; i < 40; i++) {
      double x = random.nextDouble() * size.width;
      double baseY = random.nextDouble() * size.height;
      double y = baseY - (time * 100 * (random.nextDouble() + 0.5));
      y = y % size.height;
      double pulse = math.sin((time * math.pi * 2) + random.nextDouble() * 10);
      canvas.drawCircle(Offset(x, y), 2 + pulse, Paint()..color = Colors.amber.withOpacity(0.6 + pulse * 0.2)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
    }
  }
  @override bool shouldRepaint(covariant CustomPainter old) => true;
}

// ==========================================
// 3. Game Show Theme
// ==========================================
class GameShowTheme extends StatefulWidget { const GameShowTheme({super.key}); @override State<GameShowTheme> createState() => _GameShowThemeState(); }
class _GameShowThemeState extends State<GameShowTheme> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return CustomPaint(
          painter: ShowPainter(_ctrl.value),
          child: _buildHUD('GAME SHOW', Colors.yellow, Colors.redAccent),
        );
      }
    );
  }
}
class ShowPainter extends CustomPainter {
  final double swing;
  ShowPainter(this.swing);
  @override void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF4A0000));
    
    // Spotlights
    Paint spot1 = Paint()..shader = const RadialGradient(colors: [Color(0xAAFFFDE7), Color(0x00FFFDE7)]).createShader(Rect.fromCircle(center: Offset(size.width/2, size.height/2), radius: size.height));
    canvas.save();
    canvas.translate(size.width * 0.2, -50);
    canvas.rotate(0.2 + swing * 0.2);
    canvas.drawPath(Path()..moveTo(0,0)..lineTo(-200, size.height)..lineTo(200, size.height)..close(), spot1);
    canvas.restore();

    canvas.save();
    canvas.translate(size.width * 0.8, -50);
    canvas.rotate(-0.2 - swing * 0.2);
    canvas.drawPath(Path()..moveTo(0,0)..lineTo(-200, size.height)..lineTo(200, size.height)..close(), spot1);
    canvas.restore();
    
    // Curtains
    final curtainPaint = Paint()..color = const Color(0xFF8B0000);
    canvas.drawPath(Path()..moveTo(0,0)..quadraticBezierTo(size.width * 0.1, size.height/2, 0, size.height)..close(), curtainPaint);
    canvas.drawPath(Path()..moveTo(size.width,0)..quadraticBezierTo(size.width * 0.9, size.height/2, size.width, size.height)..close(), curtainPaint);
  }
  @override bool shouldRepaint(covariant CustomPainter old) => true;
}

// ==========================================
// Helper HUD
// ==========================================
Widget _buildHUD(String title, Color mainColor, Color secondaryColor) {
  return SafeArea(
    child: Column(
      children: [
        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: mainColor, width: 3),
            boxShadow: [BoxShadow(color: mainColor.withOpacity(0.5), blurRadius: 15, spreadRadius: 5)],
          ),
          child: Column(
            children: [
              Text(title, style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 3)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [Icon(Icons.star, color: mainColor, size: 30), const SizedBox(width: 10), Text('SCORE: 1,250', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))]),
                  Container(
                    width: 200, height: 15,
                    decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(10)),
                    child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: 0.6, child: Container(decoration: BoxDecoration(color: secondaryColor, borderRadius: BorderRadius.circular(10)))),
                  ),
                ],
              )
            ],
          ),
        ),
        const Expanded(child: Center(child: Text('????? ????? ????? ???\n(Game Area)', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 24, fontWeight: FontWeight.bold)))),
      ],
    ),
  );
}
