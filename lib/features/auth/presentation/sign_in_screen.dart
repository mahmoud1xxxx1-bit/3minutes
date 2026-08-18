import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../data/auth_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({
    super.key,
    required this.authService,
  });

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(GameSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: AlignmentDirectional.topStart,
                      end: AlignmentDirectional.bottomEnd,
                      colors: [Color(0xFF34CDEB), Color(0xFF197EA8)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: GameColors.accent.withValues(alpha: 0.18),
                        blurRadius: 34,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '3',
                      style: TextStyle(
                        color: GameColors.background,
                        fontSize: 52,
                        height: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: GameSpacing.lg),
              Text(
                l10n.appName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
              ),
              const SizedBox(height: GameSpacing.sm),
              Text(
                l10n.signInTagline,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: GameColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(GameSpacing.md),
                  decoration: BoxDecoration(
                    color: GameColors.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(GameRadii.card),
                    border: Border.all(
                      color: GameColors.danger.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: GameColors.danger),
                  ),
                ),
                const SizedBox(height: GameSpacing.md),
              ],
              FilledButton.icon(
                onPressed: _busy ? null : _signIn,
                icon: _busy
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login_rounded),
                label: Text(
                  _busy ? l10n.signingIn : l10n.continueWithGoogle,
                ),
              ),
              const SizedBox(height: GameSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
