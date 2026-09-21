// Diagnostic APK build.
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DiagnosticApp());
}

class DiagnosticApp extends StatelessWidget {
  const DiagnosticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFF090014),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, size: 110, color: Color(0xFF00E5FF)),
              SizedBox(height: 28),
              Text(
                'LVL LOOL',
                style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: 6),
              ),
              SizedBox(height: 12),
              Text(
                'FIRST FRAME DIAGNOSTIC',
                style: TextStyle(color: Color(0xFF00E5FF), fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 3),
              ),
              SizedBox(height: 18),
              Text(
                'Flutter standard Android host test',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFB8AFC7), fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
