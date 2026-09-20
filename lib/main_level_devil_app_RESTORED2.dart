import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'features/minigames/presentation/level_devil/troll_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LevelDevilApp());
}

class LevelDevilApp extends StatelessWidget {
  const LevelDevilApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Level Devil',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF07080A),
      ),
      home: const SeasonsMenuScreen(),
    );
  }
}

// ─────────────────────────── Season Data ───────────────────────────

class SeasonInfo {
  final int number;
  final String title;
  final Color color;

  const SeasonInfo(this.number, this.title, this.color);
}

const List<SeasonInfo> seasons = [
  SeasonInfo(1, 'The Awakening', Color(0xFF00FFCC)),
  SeasonInfo(2, 'Deception', Color(0xFFB400FF)),
  SeasonInfo(3, 'Shadows', Color(0xFFFF0055)),
  SeasonInfo(4, 'Gravity Shift', Color(0xFF00BFFF)),
  SeasonInfo(5, 'The Chase', Color(0xFFFF9900)),
  SeasonInfo(6, 'Elements', Color(0xFF00FF55)),
  SeasonInfo(7, 'Illusions', Color(0xFFFF00FF)),
  SeasonInfo(8, 'Time Warp', Color(0xFFFFFF00)),
  SeasonInfo(9, 'The Abyss', Color(0xFF4444FF)),
  SeasonInfo(10, 'Purgatory', Color(0xFFFF3300)),
  SeasonInfo(11, 'Hell', Color(0xFFFF0000)),
];

// ─────────────────────────── Seasons Menu (Carousel) ───────────────────────────

class SeasonsMenuScreen extends StatefulWidget {
  const SeasonsMenuScreen({super.key});
  @override
  State<SeasonsMenuScreen> createState() => _SeasonsMenuScreenState();
}

class _SeasonsMenuScreenState extends State<SeasonsMenuScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.75);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Glow based on current season
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.2),
                radius: 1.5,
                colors: [
                  seasons[_currentPage].color.withOpacity(0.15),
                  const Color(0xFF07080A),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text('😈', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                const Text(
                  'LEVEL DEVIL',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'CHOOSE YOUR NIGHTMARE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
                const Spacer(),
                
                // Carousel
                SizedBox(
                  height: 450,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (idx) => setState(() => _currentPage = idx),
                    itemCount: seasons.length,
                    itemBuilder: (context, index) {
                      final season = seasons[index];
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          double value = 1.0;
                          if (_pageController.position.haveDimensions) {
                            value = _pageController.page! - index;
                            value = (1 - (value.abs() * 0.25)).clamp(0.0, 1.0);
                          }
                          return Center(
                            child: SizedBox(
                              height: Curves.easeOut.transform(value) * 450,
                              width: Curves.easeOut.transform(value) * 350,
                              child: child,
                            ),
                          );
                        },
                        child: _buildSeasonCard(season),
                      );
                    },
                  ),
                ),
                
                const Spacer(),
                
                // Page Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(seasons.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index 
                            ? seasons[_currentPage].color 
                            : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonCard(SeasonInfo season) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => SeasonLevelsScreen(season: season),
            transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F111A),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: season.color.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(color: season.color.withOpacity(0.2), blurRadius: 20, spreadRadius: 2)
          ],
        ),
        child: Stack(
          children: [
            // Internal Glow
            Positioned(
              right: -50, top: -50,
              child: Container(
                width: 200, height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: season.color.withOpacity(0.15),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SEASON ${season.number}',
                    style: TextStyle(
                      color: season.color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    season.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Levels range text
                  Text(
                    'LEVELS ${((season.number - 1) * 60) + 1} - ${season.number * 60}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: null, // Gesture detector handles it
                      style: ElevatedButton.styleFrom(
                        backgroundColor: season.color,
                        disabledBackgroundColor: season.color,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('ENTER SEASON', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Season Levels Screen ───────────────────────────

class SeasonLevelsScreen extends StatefulWidget {
  final SeasonInfo season;

  const SeasonLevelsScreen({super.key, required this.season});

  @override
  State<SeasonLevelsScreen> createState() => _SeasonLevelsScreenState();
}

class _SeasonLevelsScreenState extends State<SeasonLevelsScreen> {
  
  late List<int> easyRounds;
  late List<int> mediumRounds;
  late List<int> hardRounds;

  @override
  void initState() {
    super.initState();
    int offset = (widget.season.number - 1) * 60;
    easyRounds = List.generate(20, (i) => offset + i * 3 + 1);
    mediumRounds = List.generate(20, (i) => offset + i * 3 + 2);
    hardRounds = List.generate(20, (i) => offset + i * 3 + 3);
  }

  // --- Dynamic Helpers ---
  String getLevelName(int globalRound) {
    int absoluteGroup = (globalRound - 1) ~/ 3 + 1;
    int diff = (globalRound - 1) % 3;
    String suffix = diff == 0 ? '' : diff == 1 ? '+' : '++';
    return 'LVL $absoluteGroup$suffix';
  }

  String getMechanicName(int globalRound) {
    int localRound = ((globalRound - 1) % 60) + 1;
    const names = [
      'Appearing Spikes', 'Erratic Spike', 'Jump Drop Floor', 'Darkness',
      'Time Freeze', 'Inverted Gravity', 'Bouncy', 'Ghost Shadow',
      'Conveyor Belt', 'Wall Chase', 'Lava Rising', 'Low Gravity',
      'Flappy Mode', 'Tiny Character', 'Dash', 'Wind',
      'Ice Floor', 'Screen Blink', 'Mirror Controls', 'Absolute Chaos',
    ];
    int group = (localRound - 1) ~/ 3;
    return group < names.length ? names[group] : '???';
  }

  Color getMechanicColor(int globalRound) {
    int localRound = ((globalRound - 1) % 60) + 1;
    const baseColors = [
      Color(0xFF00FFCC), Color(0xFFFF6B35), Color(0xFF9B59B6), Color(0xFF3498DB),
      Color(0xFF00BCD4), Color(0xFFFFD700), Color(0xFF1ABC9C), Color(0xFFFF0066),
      Color(0xFFFF9500), Color(0xFF9C27B0), Color(0xFFFF3300), Color(0xFFCCCCCC),
      Color(0xFF00FFFF), Color(0xFF00FF00), Color(0xFFFF00FF), Color(0xFF88FFAA),
      Color(0xFF88CCFF), Color(0xFF4444FF), Color(0xFFFFFFFF), Color(0xFFFF0000),
    ];
    int group = (localRound - 1) ~/ 3;
    Color base = group < baseColors.length ? baseColors[group] : Colors.white;
    // Blend the mechanic base color slightly with the season's main color for thematic unity
    return Color.lerp(base, widget.season.color, 0.3) ?? base;
  }

  void _openLevel(int round) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _LevelPlayerScreen(
          round: round,
          season: widget.season,
        ),
      ),
    );
  }

  Widget _levelCard(int round, Color sectionColor) {
    final Color mc = getMechanicColor(round);

    return GestureDetector(
      onTap: () => _openLevel(round),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: const Color(0xFF0F111A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: mc.withOpacity(0.35)),
          boxShadow: [BoxShadow(color: mc.withOpacity(0.08), blurRadius: 12, spreadRadius: 1)],
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: mc.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          getLevelName(round),
                          style: TextStyle(
                            color: mc,
                            fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.play_circle_outline, color: sectionColor.withOpacity(0.45), size: 15),
                    ],
                  ),
                  Text(
                    getMechanicName(round),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11, fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String subtitle, required Color color, required IconData icon, required List<int> rounds}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                child: Text('${rounds.length} Levels', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
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
                crossAxisCount: cols, childAspectRatio: 1.55, crossAxisSpacing: 10, mainAxisSpacing: 10,
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
    return Scaffold(
      backgroundColor: const Color(0xFF07080A),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header heavily themed by season color
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 70, 24, 30),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F111A),
                    border: Border(bottom: BorderSide(color: widget.season.color.withOpacity(0.3), width: 2)),
                    boxShadow: [BoxShadow(color: widget.season.color.withOpacity(0.1), blurRadius: 30)],
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SEASON ${widget.season.number}', style: TextStyle(color: widget.season.color, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
                          const SizedBox(height: 4),
                          Text(widget.season.title, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 1)),
                          const SizedBox(height: 8),
                          Text('Levels ${easyRounds.first} to ${hardRounds.last}', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 16, left: 16,
                  child: SafeArea(
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, color: widget.season.color),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),

            _buildSection(
              title: 'LVL  ·  EASY', subtitle: 'First encounter with each mechanic',
              color: const Color(0xFF00E676), icon: Icons.sentiment_satisfied_alt, rounds: easyRounds,
            ),
            _buildSection(
              title: 'LVL+  ·  MEDIUM', subtitle: 'Getting trickier now...',
              color: const Color(0xFF29B6F6), icon: Icons.sentiment_neutral, rounds: mediumRounds,
            ),
            _buildSection(
              title: 'LVL++  ·  HARD', subtitle: 'Pure evil. Good luck.',
              color: const Color(0xFFFF1744), icon: Icons.sentiment_very_dissatisfied, rounds: hardRounds,
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Level Player Screen ───────────────────────────

class _LevelPlayerScreen extends StatefulWidget {
  final int round;
  final SeasonInfo season;

  const _LevelPlayerScreen({required this.round, required this.season});

  @override
  State<_LevelPlayerScreen> createState() => _LevelPlayerScreenState();
}

class _LevelPlayerScreenState extends State<_LevelPlayerScreen> {
  bool _showWinDialog = false;

  void _handleWin(int score) async {
    if (_showWinDialog) return;
    if (mounted) setState(() => _showWinDialog = true);
  }

  @override
  Widget build(BuildContext context) {
    int absoluteGroup = (widget.round - 1) ~/ 3 + 1;
    int diff = (widget.round - 1) % 3;
    String suffix = diff == 0 ? '' : diff == 1 ? '+' : '++';
    final levelName = 'LVL $absoluteGroup$suffix';
    
    // We map global round 1-660 into local round 1-60 for the Engine placeholder
    int localEngineRound = ((widget.round - 1) % 60) + 1;

    final hasNext = widget.round < 660;

    return Scaffold(
      backgroundColor: const Color(0xFF07080A),
      body: Stack(
        children: [
          TrollGame(
            startRound: localEngineRound,
            maxRounds: 1,
            onWin: _handleWin,
            onFail: () => Navigator.pop(context),
          ),
          
          // Header info themed with Season Color
          Positioned(
            top: 20, left: 70,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54, borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: widget.season.color.withOpacity(0.6)),
                ),
                child: Text(levelName, style: TextStyle(color: widget.season.color, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
              ),
            ),
          ),
          Positioned(
            top: 20, left: 20,
            child: SafeArea(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle, border: Border.all(color: Colors.white24)),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ),
          
          if (_showWinDialog)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.88),
                child: Center(
                  child: Container(
                    width: 300, padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F111A), borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: widget.season.color.withOpacity(0.4)),
                      boxShadow: [BoxShadow(color: widget.season.color.withOpacity(0.12), blurRadius: 30, spreadRadius: 2)],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🎉', style: TextStyle(fontSize: 44)),
                        const SizedBox(height: 10),
                        Text(levelName, style: TextStyle(color: widget.season.color, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        const SizedBox(height: 24),
                        if (hasNext)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => _LevelPlayerScreen(round: widget.round + 1, season: widget.season))),
                              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                              label: const Text('Next Level', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                              style: ElevatedButton.styleFrom(backgroundColor: widget.season.color, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            ),
                          ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => _LevelPlayerScreen(round: widget.round, season: widget.season))),
                            icon: const Icon(Icons.replay_rounded, size: 16, color: Colors.white60),
                            label: const Text('Replay', style: TextStyle(color: Colors.white60, fontSize: 13)),
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), side: BorderSide(color: Colors.white.withOpacity(0.15)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back to Menu', style: TextStyle(color: Colors.white30, fontSize: 12))),
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
