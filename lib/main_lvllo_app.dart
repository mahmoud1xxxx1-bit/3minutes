import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/cosmic_background.dart';
import 'core/theme/design_tokens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProjectUiDiagnostic());
}

class ProjectUiDiagnostic extends StatelessWidget {
  const ProjectUiDiagnostic({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: Scaffold(
        body: CosmicBackground(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 118,
                  height: 118,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: GameColors.cosmicGradient,
                    boxShadow: GameShadows.primaryGlow,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: GameColors.accentBright,
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'LVL LOOL',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 5,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'PROJECT UI / NO PLUGINS',
                  style: TextStyle(
                    color: GameColors.accentBright,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
