import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/cosmic_background.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../global_game_ui.dart';
import '../../../../core/theme/game_bottom_nav.dart';
import '../../../../store_screen.dart';
import 'level_devil_hub_screen.dart';

class LvlloLobbyScreen extends StatefulWidget {
  const LvlloLobbyScreen({super.key});
  @override State<LvlloLobbyScreen> createState() => _LvlloLobbyScreenState();
}

class _LvlloLobbyScreenState extends State<LvlloLobbyScreen> {
  int tab = 0, lives = 10, maxLives = 10, gems = 0, gold = 0, mail = 0;

  @override void initState() { super.initState(); _refresh(); }

  Future<void> _refresh() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      lives = prefs.getInt('ld_lives') ?? 10;
      maxLives = prefs.getBool('ld_vip') == true ? 30 : 10;
      gems = prefs.getInt('ld_gems') ?? 0;
      gold = prefs.getInt('ld_gold') ?? 0;
      mail = prefs.getInt('ld_unread_mail') ?? 0;
    });
  }

  void _worlds() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LevelDevilHubScreen())).then((_) => _refresh());
  }

  void _store() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StoreScreen())).then((_) => _refresh());
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CosmicBackground(child: IndexedStack(index: tab, children: [_home(), const LevelDevilHubScreen(), StoreScreen(key: ValueKey(gems.toString() + gold.toString()))])),
      bottomNavigationBar: GameBottomNav(
        currentIndex: tab,
        onSelected: (i) { setState(() => tab = i); _refresh(); },
        items: const [
          GameBottomNavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'HOME'),
          GameBottomNavItem(icon: Icons.public_outlined, activeIcon: Icons.public_rounded, label: 'WORLDS'),
          GameBottomNavItem(icon: Icons.storefront_outlined, activeIcon: Icons.storefront_rounded, label: 'STORE'),
        ],
      ),
    );
  }

  Widget _home() {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 16), sliver: SliverToBoxAdapter(child: _header())),
          SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 20), sliver: SliverToBoxAdapter(child: _hero())),
          SliverPadding(padding: const EdgeInsets.fromLTRB(20, 22, 20, 110), sliver: SliverToBoxAdapter(child: _actions())),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(children: [
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('LVL LOOL', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, letterSpacing: 2)),
        SizedBox(height: 2),
        Text('PREPARE TO RAGE', style: TextStyle(color: GameColors.muted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2)),
      ])),
      _pill(Icons.favorite_rounded, GameColors.danger, lives.toString() + '/' + maxLives.toString()),
      const SizedBox(width: 6),
      _pill(Icons.diamond_rounded, GameColors.accentBright, gems.toString()),
      const SizedBox(width: 6),
      _pill(Icons.monetization_on_rounded, GameColors.rewardGold, gold.toString()),
      const SizedBox(width: 6),
      Stack(clipBehavior: Clip.none, children: [
        Material(color: GameColors.surfaceGlass, borderRadius: BorderRadius.circular(14), child: InkWell(
          onTap: () => _mailbox(), borderRadius: BorderRadius.circular(14),
          child: const SizedBox(width: 42, height: 42, child: Icon(Icons.mail_outline_rounded)),
        )),
        if (mail > 0) const Positioned(right: -1, top: -1, child: CircleAvatar(radius: 5, backgroundColor: GameColors.danger)),
      ]),
    ]);
  }

  Widget _pill(IconData icon, Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(color: color.withOpacity(.09), borderRadius: BorderRadius.circular(999), border: Border.all(color: color.withOpacity(.22))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: color, size: 15), const SizedBox(width: 4), Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900))]),
    );
  }

  Widget _hero() {
    return CosmicPanel(
      glow: true, padding: const EdgeInsets.all(28),
      child: LayoutBuilder(builder: (_, c) {
        final text = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('THE TROLL PLATFORMER', style: TextStyle(color: GameColors.accentBright, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 10),
          const Text('175 STAGES.\nZERO MERCY.', style: TextStyle(fontSize: 35, height: .98, fontWeight: FontWeight.w900, letterSpacing: -1)),
          const SizedBox(height: 12),
          const Text('Learn the trap. Remember the pattern. Beat the stage.', style: TextStyle(color: GameColors.textSoft, fontSize: 13)),
          const SizedBox(height: 22),
          CosmicPrimaryButton(onPressed: _worlds, child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.play_arrow_rounded), SizedBox(width: 8), Text('ENTER THE WORLD')])),
        ]);
        if (c.maxWidth < 600) return text;
        return Row(children: [Expanded(child: text), const SizedBox(width: 28), const _HeroMark()]);
      }),
    );
  }

  Widget _actions() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('QUICK ACCESS', style: TextStyle(color: GameColors.muted, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
      const SizedBox(height: 10),
      LayoutBuilder(builder: (_, c) {
        final cols = c.maxWidth > 650 ? 3 : 1;
        return GridView.count(
          crossAxisCount: cols, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: cols == 1 ? 5 : 1.9,
          children: [
            _action(Icons.public_rounded, 'WORLDS', 'Explore all 175 stages', _worlds),
            _action(Icons.storefront_rounded, 'STORE', 'Lives, gems and rewards', _store),
            _action(Icons.settings_rounded, 'SETTINGS', 'Gameplay preferences', _settings),
          ],
        );
      }),
    ]);
  }

  Widget _action(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Material(color: Colors.transparent, borderRadius: BorderRadius.circular(18), child: InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(18),
      child: Ink(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: GameColors.surfaceGlass, borderRadius: BorderRadius.circular(18), border: Border.all(color: GameColors.surfaceStrong)),
        child: Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(gradient: GameColors.cosmicGradient, borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: GameColors.backgroundDeep)),
          const SizedBox(width: 12),
          Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
            const SizedBox(height: 3), Text(subtitle, style: const TextStyle(color: GameColors.muted, fontSize: 10)),
          ])),
          const Icon(Icons.chevron_right_rounded, color: GameColors.muted),
        ]),
      ),
    ));
  }

  void _settings() {
    showModalBottomSheet<void>(context: context, backgroundColor: GameColors.surface, showDragHandle: true, builder: (_) => const SafeArea(
      child: Padding(padding: EdgeInsets.fromLTRB(20, 8, 20, 28), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('SETTINGS', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        SizedBox(height: 8), Text('LVL LOOL is optimized for landscape gameplay.', style: TextStyle(color: GameColors.muted)),
        SizedBox(height: 18), ListTile(leading: Icon(Icons.vibration_rounded, color: GameColors.accent), title: Text('Haptic feedback'), subtitle: Text('Tactile game feedback is enabled.'), trailing: Icon(Icons.check_circle, color: GameColors.success)),
        ListTile(leading: Icon(Icons.screen_rotation_alt_rounded, color: GameColors.violet), title: Text('Landscape mode'), subtitle: Text('Gameplay uses the landscape layout.'), trailing: Icon(Icons.check_circle, color: GameColors.success)),
      ])),
    ));
  }

  void _mailbox() {
    showDialog<void>(context: context, builder: (_) => const _MailboxDialog()).then((_) => _refresh());
  }
}

class _HeroMark extends StatelessWidget {
  const _HeroMark();
  @override Widget build(BuildContext context) => Container(
    width: 175, height: 175,
    decoration: BoxDecoration(shape: BoxShape.circle, gradient: GameColors.cosmicGradient, boxShadow: GameShadows.primaryGlow),
    child: Center(child: Container(width: 108, height: 108, decoration: const BoxDecoration(shape: BoxShape.circle, color: GameColors.backgroundDeep), child: const Icon(Icons.warning_amber_rounded, size: 60, color: GameColors.accentBright))),
  );
}

class _MailboxDialog extends StatefulWidget {
  const _MailboxDialog();
  @override State<_MailboxDialog> createState() => _MailboxDialogState();
}

class _MailboxDialogState extends State<_MailboxDialog> {
  List<Map<String, dynamic>> mails = [];
  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getStringList('ld_mailbox') ?? [];
    final out = <Map<String, dynamic>>[];
    for (final s in raw) { try { out.add(Map<String, dynamic>.from(jsonDecode(s) as Map)); } catch (_) {} }
    if (mounted) setState(() => mails = out);
  }

  Future<void> _claim(int i) async {
    if (mails[i]['claimed'] == true) return;
    final p = await SharedPreferences.getInstance();
    await p.setInt('ld_gems', (p.getInt('ld_gems') ?? 0) + ((mails[i]['gems'] as num?)?.toInt() ?? 0));
    await p.setInt('ld_gold', (p.getInt('ld_gold') ?? 0) + ((mails[i]['gold'] as num?)?.toInt() ?? 0));
    final raw = p.getStringList('ld_mailbox') ?? [];
    if (i < raw.length) {
      final m = Map<String, dynamic>.from(jsonDecode(raw[i]) as Map); m['claimed'] = true; raw[i] = jsonEncode(m); await p.setStringList('ld_mailbox', raw);
    }
    await _load();
  }

  @override Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480, maxHeight: 500), child: CosmicPanel(
      glow: true, child: Column(children: [
        Row(children: [const Icon(Icons.mail_rounded, color: GameColors.accentBright), const SizedBox(width: 10), const Expanded(child: Text('MAILBOX', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900))), IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded))]),
        const SizedBox(height: 8),
        Expanded(child: mails.isEmpty ? const Center(child: Text('No new mail.', style: TextStyle(color: GameColors.muted))) : ListView.separated(
          itemCount: mails.length, separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final m = mails[i]; final claimed = m['claimed'] == true;
            return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: GameColors.surfaceRaised, borderRadius: BorderRadius.circular(15)),
              child: Row(children: [
                const Icon(Icons.card_giftcard_rounded, color: GameColors.rewardGold), const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text((m['title'] ?? 'REWARD').toString(), style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text((m['body'] ?? '').toString(), style: const TextStyle(color: GameColors.muted, fontSize: 11))])),
                claimed ? const Text('CLAIMED', style: TextStyle(color: GameColors.muted, fontSize: 10)) : FilledButton(onPressed: () => _claim(i), child: const Text('CLAIM')),
              ]));
          },
        )),
      ]),
    )),
  );
}
