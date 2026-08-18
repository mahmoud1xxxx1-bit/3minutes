import 'package:flutter/material.dart';

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
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Google sign-in failed. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Text(
                '3 MINUTES',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                'Two players. One clock.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              if (_error != null) ...[
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 12),
              ],
              FilledButton.icon(
                onPressed: _busy ? null : _signIn,
                icon: _busy
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login),
                label: Text(_busy ? 'Signing in...' : 'Continue with Google'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
