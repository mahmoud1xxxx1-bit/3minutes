import 'package:flutter/material.dart';

import '../../../core/theme/cosmic_background.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../data/auth_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _signIn() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.authService.signInWithGoogle();
    } on AuthSignInException catch (error) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() => _error = '${l10n.googleSignInFailed}\n${error.code}');
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = AppLocalizations.of(context).googleSignInFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CosmicBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(GameSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Center(
                  child: SizedBox.square(
                    dimension: 184,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [Color(0x3326E3EE), Color(0x007957F5)],
                            ),
                          ),
                        ),
                        Container(
                          width: 142,
                          height: 142,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: GameColors.cosmicGradient,
                            boxShadow: GameShadows.primaryGlow,
                          ),
                          padding: const EdgeInsets.all(3),
                          child: const DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: GameColors.backgroundDeep,
                            ),
                            child: Center(
                              child: Text(
                                '3',
                                style: TextStyle(
                                  color: GameColors.textStrong,
                                  fontSize: 68,
                                  height: 1,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: GameSpacing.lg),
                Text(
                  l10n.appName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                ),
                const SizedBox(height: GameSpacing.sm),
                Text(
                  l10n.signInTagline,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: GameColors.textSoft,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                      ),
                ),
                const Spacer(),
                if (_error != null) ...[
                  CosmicPanel(
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: GameColors.danger),
                        const SizedBox(width: GameSpacing.sm),
                        Expanded(
                          child: Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: GameColors.danger),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: GameSpacing.md),
                ],
                CosmicPrimaryButton(
                  onPressed: _busy ? null : _signIn,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_busy)
                        const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        const Icon(Icons.login_rounded),
                      const SizedBox(width: GameSpacing.sm),
                      Text(_busy ? l10n.signingIn : l10n.continueWithGoogle),
                    ],
                  ),
                ),
                const SizedBox(height: GameSpacing.sm),
                Text(
                  '3 MINUTES',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: GameColors.muted,
                        letterSpacing: 4,
                      ),
                ),
                const SizedBox(height: GameSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
