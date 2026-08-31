import 'dart:math' as math;
import 'package:flutter/material.dart';

class NeonArcadeBackground extends StatefulWidget {
  const NeonArcadeBackground({super.key, required this.child});
  final Widget child;

  @override
  State<NeonArcadeBackground> createState() => _NeonArcadeBackgroundState();
}

class _NeonArcadeBackgroundState extends State<NeonArcadeBackground> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return CustomPaint(
          painter: _ArcadePainter(_ctrl.value),
          child: widget.child,
        );
      },
    );
  }
}

class _ArcadePainter extends CustomPainter {
  final double progress;
  _ArcadePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF0F0C29));
    
    final paint = Paint()
      ..color = Colors.pinkAccent.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
      
    double horizon = size.height * 0.4;
    
    // Draw vertical perspective lines
    for (int i = 0; i <= 10; i++) {
      double startX = size.width * (i / 10.0);
      canvas.drawLine(Offset(startX, size.height), Offset(size.width / 2, horizon), paint);
    }
    
    // Draw horizontal moving lines
    for (int i = 0; i < 15; i++) {
      double y = horizon + math.pow((i + progress) / 15, 2) * (size.height - horizon);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    
    // Add a glowing sun at the horizon
    final sunRect = Rect.fromCircle(center: Offset(size.width / 2, horizon), radius: size.width * 0.15);
    final sunPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.yellowAccent, Colors.pinkAccent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(sunRect);
    
    // Draw the sun with clipping so it looks like it's setting on the horizon grid
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, horizon));
    canvas.drawArc(sunRect, math.pi, math.pi, true, sunPaint);
    canvas.restore();
    
    // Add grid reflection below sun
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, horizon, size.width, size.height));
    canvas.drawArc(sunRect, 0, math.pi, true, sunPaint..color = sunPaint.color.withValues(alpha: 0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ArcadePainter oldDelegate) => oldDelegate.progress != progress;
}
