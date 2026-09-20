
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase/level_devil_auth.dart';
import '../../../../main_level_devil_app.dart';

class LevelDevilLoginScreen extends StatefulWidget {
  const LevelDevilLoginScreen({super.key});

  @override
  State<LevelDevilLoginScreen> createState() => _LevelDevilLoginScreenState();
}

class _LevelDevilLoginScreenState extends State<LevelDevilLoginScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Check if user is already logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (FirebaseAuth.instance.currentUser != null) {
          _navigateToHome();
        }
      } catch (e) {
        print("Firebase auth check failed: $e");
      }
    });
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => SeasonsMenuScreen()),
    );
  }

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final user = await LevelDevilAuth.signInWithGoogle();
      if (user != null && mounted) {
        _navigateToHome();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), duration: const Duration(seconds: 5)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF350A0A), Color(0xFF07080A)],
            center: Alignment.center,
            radius: 1.2,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: BackgroundSquaresPainter(),
              ),
            ),
            Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Glitchy/Glowing Title
              Text(
                'LVL LOOL',
                style: TextStyle(
                  fontSize: 84,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 12,
                  shadows: [
                    const Shadow(color: Colors.redAccent, blurRadius: 40, offset: Offset(0, 0)),
                    const Shadow(color: Colors.red, blurRadius: 10, offset: Offset(3, 3)),
                    Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 0, offset: const Offset(5, 5)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'PREPARE TO RAGE',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white54,
                  letterSpacing: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 80),
              
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.redAccent)
                  : Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(color: Colors.redAccent.withOpacity(0.2), blurRadius: 30, spreadRadius: 2, offset: const Offset(0, 8)),
                        ],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _handleSignIn,
                        icon: const Icon(Icons.login, color: Colors.white, size: 28),
                        label: const Text(
                          'SIGN IN WITH GOOGLE',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF14151C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(color: Colors.redAccent.withOpacity(0.6), width: 2),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
            ],
          ),
            ),
          ],
        ),
      ),
    );
  }
}


class BackgroundSquaresPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42); // Fixed seed so it doesn't jitter on rebuilds
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final squareSize = 40.0 + random.nextDouble() * 100.0;
      final rotation = random.nextDouble() * pi;
      
      final opacity = 0.05 + random.nextDouble() * 0.1;
      paint.color = Colors.redAccent.withOpacity(opacity);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: squareSize, height: squareSize), paint);
      
      // Draw inner filled square sometimes
      if (random.nextBool()) {
        final fillPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.black.withOpacity(0.2);
        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: squareSize, height: squareSize), fillPaint);
      }
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

