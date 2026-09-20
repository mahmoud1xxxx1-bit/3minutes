import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/minigames/presentation/level_devil/troll_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TrollShowcaseApp());
}

class TrollShowcaseApp extends StatelessWidget {
  const TrollShowcaseApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Level Devil',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const TrollShowcaseScreen(),
    );
  }
}

// ─────────────────────────── Helpers ───────────────────────────

String getLevelName(int round) {
  int group = (round - 1) ~/ 3 + 1;
  int diff = (round - 1) % 3;
  String suffix = diff == 0 ? '' : diff == 1 ? '+' : '++';
  return 'LVL $group$suffix';
}

String getMechanicName(int round) {
  const names = [
    'Appearing Spikes', 'Erratic Spike', 'Jump Drop Floor', 'Darkness',
    'Time Freeze', 'Inverted Gravity', 'Bouncy', 'Ghost Shadow',
    'Conveyor Belt', 'Wall Chase', 'Lava Rising', 'Low Gravity',
    'Flappy Mode', 'Tiny Character', 'Dash', 'Wind',
    'Ice Floor', 'Screen Blink', 'Mirror Controls', 'Absolute Chaos',
  ];
  int group = (round - 1) ~/ 3;
  return group < names.length ? names[group] : '???';
}

Color getMechanicColor(int round) {
  const colors = [
    Color(0xFF00FFCC), Color(0xFFFF6B35), Color(0xFF9B59B6), Color(0xFF3498DB),
    Color(0xFF00BCD4), Color(0xFFFFD700), Color(0xFF1ABC9C), Color(0xFFFF0066),
    Color(0xFFFF9500), Color(0xFF9C27B0), Color(0xFFFF3300), Color(0xFFCCCCCC),
    Color(0xFF00FFFF), Color(0xFF00FF00), Color(0xFFFF00FF), Color(0xFF88FFAA),
    Color(0xFF88CCFF), Color(0xFF4444FF), Color(0xFFFFFFFF), Color(0xFFFF0000),
  ];
  int group = (round - 1) ~/ 3;
  return group < colors.length ? colors[group] : Colors.white;
}

// ─────────────────────────── Showcase Screen ───────────────────────────

class TrollShowcaseScreen extends StatefulWidget {
  const TrollShowcaseScreen({super.key});
  @override
  State<TrollShowcaseScreen> createState() => _TrollShowcaseScreenState();
}

class _TrollShowcaseScreenState extends State<TrollShowcaseScreen> {
  Set<int> _unlocked = {1};
  bool _loaded = false;

  static const List<int> easyRounds   = [1,4,7,10,13,16,19,22,25,28,31,34,37,40,43,46,49,52,55,58];
  static const List<int> mediumRounds = [2,5,8,11,14,17,20,23,26,29,32,35,38,41,44,47,50,53,56,59];
  static const List<int> hardRounds   = [3,6,9,12,15,18,21,24,27,30,33,36,39,42,45,48,51,54,57,60];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('ld_unlocked') ?? ['1'];
    setState(() {
      _unlocked = saved.map(int.parse).toSet();
      _loaded = true;
    });
  }

  Future<void> _unlockNext(int completedRound) async {
    int next = completedRound + 1;
    if (next > 60) return;
    if (_unlocked.contains(next)) return;
    setState(() => _unlocked.add(next));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('ld_unlocked', _unlocked.map((e) => e.toString()).toList());
  }

  void _openLevel(int round) {
    if (!_unlocked.contains(round)) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _LevelScreen(
          round: round,
          onUnlockNext: _unlockNext,
        ),
      ),
    );
  }

  Widget _levelCard(int round, Color sectionColor) {
    final bool unlocked = _unlocked.contains(round);
    final Color mc = unlocked ? getMechanicColor(round) : Colors.transparent;

    return GestureDetector(
      onTap: unlocked ? () => _openLevel(round) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: unlocked ? const Color(0xFF0F111A) : const Color(0xFF09090F),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: unlocked ? mc.withOpacity(0.35) : Colors.white.withOpacity(0.07),
          ),
          boxShadow: unlocked
              ? [BoxShadow(color: mc.withOpacity(0.08), blurRadius: 12, spreadRadius: 1)]
              : [],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Level name badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: unlocked ? mc.withOpacity(0.15) : Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          getLevelName(round),
                          style: TextStyle(
                            color: unlocked ? mc : Colors.white24,
                            fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Spacer(),
                      unlocked
                          ? Icon(Icons.play_circle_outline, color: sectionColor.withOpacity(0.45), size: 15)
                          : const Icon(Icons.lock_outline, color: Colors.white24, size: 15),
                    ],
                  ),
                  Text(
                    unlocked ? getMechanicName(round) : '???',
                    style: TextStyle(
                      color: unlocked ? Colors.white70 : Colors.white24,
                      fontSize: 11, fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Locked overlay
            if (!unlocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.black.withOpacity(0.35),
                  ),
                  child: const Center(
                    child: Icon(Icons.lock, color: Colors.white12, size: 22),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required List<int> rounds,
  }) {
    int unlockedCount = rounds.where((r) => _unlocked.contains(r)).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Container(
          margin: const EdgeInsets.fromLTRB(24, 32, 24, 0),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                    Text(subtitle, style: TextStyle(color: color.withOpacity(0.55), fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                child: Text('$unlockedCount / ${rounds.length}', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: LayoutBuilder(builder: (ctx, box) {
            int cols = box.maxWidth > 1200 ? 5 : box.maxWidth > 900 ? 4 : box.maxWidth > 600 ? 3 : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols, childAspectRatio: 1.55,
                crossAxisSpacing: 10, mainAxisSpacing: 10,
              ),
              itemCount: rounds.length,
              itemBuilder: (_, i) => _levelCard(rounds[i], color),
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        backgroundColor: Color(0xFF07080A),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF00FFCC))),
      );
    }

    int totalUnlocked = _unlocked.where((r) => r >= 1 && r <= 60).length;

    return Scaffold(
      backgroundColor: const Color(0xFF07080A),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 52, 24, 24),
              decoration: BoxDecoration(
                color: const Color(0xFF0F111A),
                border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06))),
              ),
              child: Row(
                children: [
                  const Text('😈', style: TextStyle(fontSize: 40)),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Level Devil',
                          style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      Text(
                        '$totalUnlocked / 60 levels unlocked',
                        style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 13),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Progress bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${((totalUnlocked / 60) * 100).toInt()}%',
                          style: const TextStyle(color: Color(0xFF00FFCC), fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 120,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: totalUnlocked / 60,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation(Color(0xFF00FFCC)),
                            minHeight: 6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            _buildSection(
              title: 'LVL  ·  EASY',
              subtitle: 'First encounter with each mechanic',
              color: const Color(0xFF00E676),
              icon: Icons.sentiment_satisfied_alt,
              rounds: easyRounds,
            ),
            _buildSection(
              title: 'LVL+  ·  MEDIUM',
              subtitle: 'Getting trickier now...',
              color: const Color(0xFF29B6F6),
              icon: Icons.sentiment_neutral,
              rounds: mediumRounds,
            ),
            _buildSection(
              title: 'LVL++  ·  HARD',
              subtitle: 'Pure evil. Good luck.',
              color: const Color(0xFFFF1744),
              icon: Icons.sentiment_very_dissatisfied,
              rounds: hardRounds,
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Level Screen ───────────────────────────

class _LevelScreen extends StatefulWidget {
  final int round;
  final Future<void> Function(int completedRound) onUnlockNext;

  const _LevelScreen({required this.round, required this.onUnlockNext});

  @override
  State<_LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<_LevelScreen> {
  bool _showWinDialog = false;
  bool _processing = false;

  void _handleWin(int score) async {
    if (_processing || _showWinDialog) return;
    _processing = true;
    await widget.onUnlockNext(widget.round);
    if (mounted) setState(() => _showWinDialog = true);
  }

  void _goNext() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => _LevelScreen(
          round: widget.round + 1,
          onUnlockNext: widget.onUnlockNext,
        ),
      ),
    );
  }

  void _replay() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => _LevelScreen(
          round: widget.round,
          onUnlockNext: widget.onUnlockNext,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final levelName = getLevelName(widget.round);
    final mechColor = getMechanicColor(widget.round);
    final hasNext = widget.round < 60;
    final nextName = hasNext ? getLevelName(widget.round + 1) : '';

    return Scaffold(
      backgroundColor: const Color(0xFF07080A),
      body: Stack(
        children: [
          // Game
          TrollGame(
            startRound: widget.round,
            maxRounds: 1,
            onWin: _handleWin,
            onFail: () => Navigator.pop(context), // Return to menu on loss
          ),

          // Level name top-left
          Positioned(
            top: 20, left: 70,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: mechColor.withOpacity(0.4)),
                ),
                child: Text(levelName,
                    style: TextStyle(color: mechColor, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
              ),
            ),
          ),

          // Back button
          Positioned(
            top: 20, left: 20,
            child: SafeArea(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: Colors.black54, shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ),

          // Win Dialog
          if (_showWinDialog)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.88),
                child: Center(
                  child: Container(
                    width: 300,
                    padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F111A),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: mechColor.withOpacity(0.4)),
                      boxShadow: [BoxShadow(color: mechColor.withOpacity(0.12), blurRadius: 30, spreadRadius: 2)],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🎉', style: TextStyle(fontSize: 44)),
                        const SizedBox(height: 10),
                        Text(levelName,
                            style: TextStyle(color: mechColor, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        const SizedBox(height: 4),
                        Text('${getMechanicName(widget.round)} · Completed!',
                            style: const TextStyle(color: Colors.white54, fontSize: 13), textAlign: TextAlign.center),
                        const SizedBox(height: 24),

                        // Next Level button
                        if (hasNext)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _goNext,
                              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                              label: Text('Next: $nextName', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mechColor,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),

                        const SizedBox(height: 10),

                        // Replay button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _replay,
                            icon: const Icon(Icons.replay_rounded, size: 16, color: Colors.white60),
                            label: const Text('Replay', style: TextStyle(color: Colors.white60, fontSize: 13)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.white.withOpacity(0.15)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Back to menu
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Back to Menu', style: TextStyle(color: Colors.white30, fontSize: 12)),
                        ),

                        if (!hasNext)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text('🏆 All levels complete!',
                                style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
