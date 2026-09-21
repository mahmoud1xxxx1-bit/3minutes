import 'dart:ui';
import 'l10n.dart';
import 'l10n.dart';
import 'l10n.dart';
import 'dart:async';
import 'features/minigames/presentation/level_devil/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dart:async';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'features/minigames/presentation/level_devil/troll_game.dart';
import 'store_screen.dart';
import 'store_screen.dart';
import 'store_screen.dart';
import 'global_game_ui.dart';
import 'economy_manager.dart';

import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:flutter/services.dart';

import 'package:flutter/services.dart';

class RewardClaimAnimation extends StatefulWidget {
  final int gold;
  final int gems;
  const RewardClaimAnimation({Key? key, required this.gold, required this.gems}) : super(key: key);

  @override
  State<RewardClaimAnimation> createState() => _RewardClaimAnimationState();
}

class _RewardClaimAnimationState extends State<RewardClaimAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2).chain(CurveTween(curve: Curves.easeOut)), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 80),
    ]).animate(_ctrl);

    _ctrl.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) Navigator.pop(context);
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          int currentGold = (widget.gold * _ctrl.value).toInt();
          int currentGems = (widget.gems * _ctrl.value).toInt();
          return ScaleTransition(
            scale: _scaleAnim,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF151822),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.amber, width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.amber.withValues(alpha: 0.3), blurRadius: 40, spreadRadius: 10)
                ]
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('REWARD UNLOCKED!', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildItem(Icons.monetization_on, Colors.amber, currentGold),
                      const SizedBox(width: 32),
                      _buildItem(Icons.diamond_rounded, Colors.cyanAccent, currentGems),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_ctrl.isCompleted)
                    const Text('Saved to your balance!', style: TextStyle(color: Colors.greenAccent, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItem(IconData icon, Color color, int value) {
    return Column(
      children: [
        Icon(icon, color: color, size: 48),
        const SizedBox(height: 8),
        Text('+$value', style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class MailboxDialog extends StatefulWidget {
  const MailboxDialog({super.key});

  @override
  State<MailboxDialog> createState() => _MailboxDialogState();
}

class _MailboxDialogState extends State<MailboxDialog> {
  List<dynamic> _mails = [];

  @override
  void initState() {
    super.initState();
    _loadMails();
  }

  Future<void> _loadMails() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> rawMails = prefs.getStringList('ld_mailbox') ?? [];
    setState(() {
      _mails = rawMails.map((m) => jsonDecode(m)).toList();
    });
  }

  Future<void> _claimMail(int index) async {
    if (index < 0 || index >= _mails.length) return;
    final mail = _mails[index];
    if (mail['claimed'] == true) return;
    if (mail['type'] == 'vip_lives') {
      final mailId = mail['id']?.toString() ?? '';
      final claimed = mailId.isNotEmpty
          ? await EconomyManager.claimVipLifeMailById(mailId)
          : await EconomyManager.claimVipLifeMail(index);
      if (!claimed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This 30-life reward unlocks when your current lives reach zero.')),
        );
      }
      await _loadMails();
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ld_gems', (prefs.getInt('ld_gems') ?? 0) + ((mail['gems'] ?? 0) as int));
    await prefs.setInt('ld_gold', (prefs.getInt('ld_gold') ?? 0) + ((mail['gold'] ?? 0) as int));
    final rawMails = prefs.getStringList('ld_mailbox') ?? [];
    if (index >= 0 && index < rawMails.length) {
      final updatedMail = jsonDecode(rawMails[index]) as Map<String, dynamic>;
      updatedMail['claimed'] = true;
      rawMails[index] = jsonEncode(updatedMail);
      await prefs.setStringList('ld_mailbox', rawMails);
    }
    await _loadMails();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340, maxHeight: 400),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF0F111A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white24, width: 2),
        ),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mail, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Text('MAILBOX', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _mails.isEmpty
                  ? const Center(child: Text('No new mail.', style: TextStyle(color: Colors.white54, fontSize: 16)))
                  : ListView.builder(
                      itemCount: _mails.length,
                      itemBuilder: (context, index) {
                        final m = _mails[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m['title'], style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(m['body'], style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        if (m['type'] == 'vip_lives') ...[
                                          const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 18),
                                          const SizedBox(width: 5),
                                          Text('+' + (m['lives'] ?? 30).toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        ] else ...[
                                          const Icon(Icons.diamond_rounded, color: Colors.cyanAccent, size: 16),
                                          const SizedBox(width: 4),
                                          Text('+' + (m['gems'] ?? 0).toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                          const SizedBox(width: 12),
                                          const Icon(Icons.monetization_on, color: Colors.amber, size: 16),
                                          const SizedBox(width: 4),
                                          Text('+' + (m['gold'] ?? 0).toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        ],
                                      ],
                                    ),
                                  ),
                                  m['claimed'] == true
                                      ? const Padding(
                                          padding: EdgeInsets.only(right: 8.0),
                                          child: Text('CLAIMED', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                                        )
                                      : ElevatedButton(
                                          onPressed: () => _claimMail(index),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: m['type'] == 'vip_lives' ? Colors.redAccent : Colors.green,
                                            foregroundColor: Colors.white,
                                            minimumSize: const Size(60, 32),
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          child: const Text('CLAIM'),
                                        ),
                                ],
                              )
                      },
                    ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CLOSE', style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      ),
    );
  }
}

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch(e) {}
    
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    final prefs = await SharedPreferences.getInstance();
    globalLanguageNotifier.value = prefs.getString('ld_lang') ?? 'en'; 
    runApp(const LevelDevilApp());
  }

class LevelDevilApp extends StatelessWidget {
  const LevelDevilApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: globalLanguageNotifier,
      builder: (context, lang, child) {
        return MaterialApp(
          title: 'LVL LOOL',
          debugShowCheckedModeBanner: false,
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch, PointerDeviceKind.stylus, PointerDeviceKind.unknown},
          ),
          builder: (context, child) {
            return Directionality(
              textDirection: lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
              child: child ?? const SizedBox(),
            );
          },
          theme: ThemeData.dark().copyWith(