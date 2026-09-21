import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_theme.dart';
import 'core/navigation/game_orientation.dart';
import 'core/theme/cosmic_background.dart';
import 'core/theme/design_tokens.dart';
import 'features/minigames/presentation/level_devil/firebase/level_devil_auth.dart';
import 'features/minigames/presentation/level_devil/lvllo_lobby_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Never block the first frame on Firebase or any remote/plugin startup.
  // The game must always render a real screen first.
  runApp(const LvlloApp());

  await GameOrientation.enterPortrait();
}

class LvlloApp extends StatefulWidget {
  const LvlloApp({super.key});

  @override
  State<LvlloApp> createState() => _LvlloAppState();
}

class _LvlloAppState extends State<LvlloApp> {
  bool _firebaseReady = false;
  bool _firebaseFailed = false;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(const Duration(seconds: 6));
      if (!mounted) return;
      setState(() => _firebaseReady = true);
    } catch (error) {
      debugPrint('LVL LOOL Firebase unavailable: $error');
      if (!mounted) return;
      setState(() => _firebaseFailed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LVL LOOL',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: _EntryGate(
        firebaseReady: _firebaseReady,
        firebaseFailed: _firebaseFailed,
      ),
    );
  }
}

class _EntryGate extends StatelessWidget {
  const _EntryGate({
    required this.firebaseReady,
    required this.firebaseFailed,
  });

  final bool firebaseReady;
  final bool firebaseFailed;

  @override
  Widget build(BuildContext context) {
    if (firebaseFailed) {
      // Offline-first fallback: the player can enter the game immediately.
      return const LvlloLobbyScreen();
    }

    if (!firebaseReady) {
      return const _Splash();
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _Splash();
        }
        return snapshot.data == null ? const _Login() : const LvlloLobbyScreen();
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CosmicBackground(
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _LogoMark(size: 100),
            SizedBox(height: 22),
            Text('LVL LOOL', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 4)),
            SizedBox(height: 8),
            Text('LOADING THE NIGHTMARE...', style: TextStyle(color: GameColors.muted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2)),
          ]),
        ),
      ),
    );
  }
}

class _Login extends StatefulWidget {
  const _Login();
  @override State<_Login> createState() => _LoginState();
}

class _LoginState extends State<_Login> {
  bool loading = false;

  Future<void> _signIn() async {
    setState(() => loading = true);
    try {
      await LevelDevilAuth.signInWithGoogle();
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign in failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CosmicBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 780),
              child: CosmicPanel(
                glow: true,
                padding: const EdgeInsets.symmetric(horizontal: 38, vertical: 34),
                child: LayoutBuilder(builder: (_, c) {
                  final compact = c.maxWidth < 600;
                  final brand = Column(mainAxisSize: MainAxisSize.min, children: const [
                    _LogoMark(size: 118),
                    SizedBox(height: 18),
                    Text('LVL LOOL', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: 5)),
                    SizedBox(height: 7),
                    Text('THE TROLL PLATFORMER', style: TextStyle(color: GameColors.accentBright, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  ]);
                  final action = Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    const Text('READY TO RAGE?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    const Text('Enter a deterministic world of traps, timing and muscle memory.', style: TextStyle(color: GameColors.muted, fontSize: 12, height: 1.4)),
                    const SizedBox(height: 22),
                    CosmicPrimaryButton(
                      onPressed: loading ? null : _signIn,
                      child: loading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: GameColors.backgroundDeep))
                          : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.login_rounded), SizedBox(width: 9), Text('SIGN IN WITH GOOGLE')]),
                    ),
                    const SizedBox(height: 12),
                    const Center(child: Text('Your progress and economy stay on this device/account.', style: TextStyle(color: GameColors.muted, fontSize: 10))),
                  ]);
                  if (compact) return Column(children: [brand, const SizedBox(height: 28), action]);
                  return Row(children: [Expanded(child: brand), const SizedBox(width: 46), Expanded(child: action)]);
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark({required this.size});
  final double size;
  @override Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, gradient: GameColors.cosmicGradient, boxShadow: GameShadows.primaryGlow),
    child: Center(child: Container(
      width: size * .62, height: size * .62,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: GameColors.backgroundDeep),
      child: const Icon(Icons.warning_amber_rounded, color: GameColors.accentBright, size: 48),
    )),
  );
}
