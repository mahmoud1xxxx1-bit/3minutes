import 'package:flutter/material.dart';

/// TEMPORARY RENDER-ENGINE DIAGNOSTIC
///
/// This entrypoint intentionally contains ZERO Firebase, Ads, SharedPreferences,
/// custom theme, assets, platform channels, or application startup logic.
/// The only question this build answers is:
/// "Can Flutter render a first frame on the Android emulator/device?"
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LvlloRenderDiagnostic());
}

class LvlloRenderDiagnostic extends StatelessWidget {
  const LvlloRenderDiagnostic({super.key});

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
              Icon(
                Icons.check_circle_rounded,
                size: 110,
                color: Color(0xFF00E5FF),
              ),
              SizedBox(height: 28),
              Text(
                'LVL LOOL',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'FLUTTER RENDER TEST',
                style: TextStyle(
                  color: Color(0xFF00E5FF),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                ),
              ),
              SizedBox(height: 18),
              Text(
                'If you can see this screen, the Android\nFlutter engine can render correctly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFB8AFC7),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
