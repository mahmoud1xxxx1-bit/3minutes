import 'package:flutter/material.dart';

class PigeonPainter extends CustomPainter {
  final bool isSolid;
  final Color color; // Ignored, we use gradient
  PigeonPainter(this.color, {this.isSolid = false});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    // A beautiful diagonal gradient from Semi-Transparent White to Semi-Transparent Black
    // This ensures visibility on BOTH pitch-black and pure-white backgrounds!
    
    final paint = Paint()..style = PaintingStyle.fill;
    if (isSolid) {
      paint.color = color;
    } else {
      paint.shader = const LinearGradient(
        colors: [Color(0x73FFFFFF), Color(0x73000000)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    }
    
      
    final path = Path();
    path.moveTo(size.width * 0.7, size.height * 0.3); 
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.3, size.width * 0.5, size.height * 0.4); 
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.5, size.width * 0.1, size.height * 0.6); 
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.7, size.width * 0.4, size.height * 0.7); 
    path.quadraticBezierTo(size.width * 0.4, size.height * 0.85, size.width * 0.45, size.height * 0.9); 
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.85, size.width * 0.55, size.height * 0.8); 
    path.quadraticBezierTo(size.width * 0.8, size.height * 0.7, size.width * 0.9, size.height * 0.5); 
    path.lineTo(size.width * 0.95, size.height * 0.45); 
    path.lineTo(size.width * 0.85, size.height * 0.4); 
    path.quadraticBezierTo(size.width * 0.8, size.height * 0.3, size.width * 0.7, size.height * 0.3); 
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
