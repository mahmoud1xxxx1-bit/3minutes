  Ã‚Â·  
import 'l10n.dart';

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
            scaffoldBackgroundColor: const Color(0xFF07080A),
          ),
          home: const LevelDevilLoginScreen(),
        );
      },
    );
  }
}
  Future<void> _changeLang(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ld_lang', lang);
    setState(() => _lang = lang);
  }

  @override
import 'l10n.dart';

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
            scaffoldBackgroundColor: const Color(0xFF07080A),
          ),
          home: const LevelDevilLoginScreen(),
        );
      },
    );
  }
}
  Future<void> _changeLang(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ld_lang', lang);
    setState(() => _lang = lang);
  }

  @override
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
            scaffoldBackgroundColor: const Color(0xFF07080A),
          ),
          home: const LevelDevilLoginScreen(),
        );
      },
    );
  }
}
                // Carousel
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double cardHeight = constraints.maxHeight;
                      final double cardWidth = cardHeight * 0.75; // Aspect ratio
                      return PageView.builder(
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
                                  height: Curves.easeOut.transform(value) * cardHeight,
                                  width: Curves.easeOut.transform(value) * cardWidth,
                                  child: child,
                                ),
                              );
                            },
                            child: _buildSeasonCard(season, index),
                          );
                        },
                      );
                    }
                  ),
                ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${L10n.get('season')} ${season.number}',
                    style: TextStyle(
                      color: isLocked ? Colors.white38 : season.color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    L10n.get(season.title.toLowerCase().replaceAll(' ', '_')),
                    style: TextStyle(
                      color: isLocked ? Colors.white54 : Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Levels range text
                  Text(
                    '${L10n.get('levels')} ${((season.number - 1) * 60) + 1} - ${season.number * 60}',
                    style: TextStyle(
                      color: isLocked ? Colors.white24 : Colors.white.withOpacity(0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          // ------------------------------------------------ TOP BAR (Economy) ------------------------------------------------
                          GlobalGameHUD(
                            lives: _lives,
                            maxLives: _maxLives,
                            gems: _gems,
                            gold: _gold,
                            unreadMail: _unreadMail,
                            onMailTap: () {
                              showDialog(context: context, builder: (_) => const MailboxDialog()).then((_) => _loadEconomy());
                            },
                            onStoreTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreScreen())).then((_) => _loadEconomy());
                            },
                            onSettingsTap: () {
                              showDialog(context: context, builder: (_) => const SettingsDialog()).then((_) => _loadEconomy());
                            },
                          ),
                          
                          const SizedBox(height: 10),
                          const Text('\u{1F608}', style: TextStyle(fontSize: 48)), // Devil emoji
                          const SizedBox(height: 12),
                          Text(
                            'LVL LOOL',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 8,
                              color: Colors.white,
                              shadows: [
                                const Shadow(color: Colors.redAccent, blurRadius: 20, offset: Offset(0, 0)),
                                const Shadow(color: Colors.red, blurRadius: 5, offset: Offset(2, 2)),
                                Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 0, offset: const Offset(3, 3)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            L10n.get('choose_nightmare'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 6,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                          const Spacer(),
                          
                          // Carousel
                          SizedBox(
                            height: 450,
                          children: [
                            Text('${L10n.get('season')} ${widget.season.number}', style: TextStyle(color: widget.season.color, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
                            const SizedBox(height: 4),
                            Text(L10n.get(widget.season.title.toLowerCase().replaceAll(' ', '_')), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 1)),
                            const SizedBox(height: 8),
                            Text('${L10n.get('levels')} ${easyRounds.first} - ${hardRounds.last}', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
                          ],
                                    );
                                  },
                                  child: _buildSeasonCard(season, index),
                                );
                              },
                            ),
                          ),
                          
                          const Spacer(),
                          
                          // Page Indicators
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(seasons.length, (index) {
                              return GestureDetector(
                                onTap: () {
                                  _pageController.animateToPage(index, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                                },
                                child: AnimatedContainer(
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
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              }
            ),
          ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                  child: Text('${rounds.length} ${L10n.get('levels')}', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
class SeasonInfo {
  final int number;
  final String title;
  final String icon;
  final String tagline;
  final Color color;
  final int maxRounds;           // 20 for seasons 1-5, 60 for season 11
  final int levelsPerMechanic;   // 5 for seasons 1-5, 3 for season 11
  final int mechanicOffset;      // 0,4,8,12,16 for seasons 1-5; 0 for s11

  const SeasonInfo(
    this.number,
    this.title, {
    required this.icon,
    required this.tagline,
    required this.color,
    this.maxRounds = 20,
    this.levelsPerMechanic = 5,
    this.mechanicOffset = 0,
  });
}

const List<SeasonInfo> seasons = [
  // ── Seasons 1-5: 20 levels each (4 mechanics × 5 difficulties) ──────────
  SeasonInfo(1,  'The Awakening',
    icon: '🔥', tagline: 'YOUR JOURNEY BEGINS... WITH PAIN',
    color: Color(0xFFFF3B30), mechanicOffset: 0),

  SeasonInfo(2,  'Deception',
    icon: '👻', tagline: 'NOTHING IS WHAT IT SEEMS',
    color: Color(0xFFBF00FF), mechanicOffset: 4),

  SeasonInfo(3,  'The Chase',
    icon: '🌋', tagline: 'RUN. THERE IS NO ESCAPE',
    color: Color(0xFFFF6B00), mechanicOffset: 8),

  SeasonInfo(4,  'Gravity Shift',
    icon: '⚡', tagline: 'YOUR SKILLS ARE USELESS HERE',
    color: Color(0xFF00C3FF), mechanicOffset: 12),

  SeasonInfo(5,  'Illusions',
    icon: '🪞', tagline: 'CAN YOU TRUST YOUR OWN MIND?',
    color: Color(0xFFFF2D97), mechanicOffset: 16),

  // ── Seasons 6-10: Locked (future content) ────────────────────────────────
  SeasonInfo(6,  'Elements',
    icon: '🔒', tagline: 'COMING SOON',
    color: Color(0xFF00FF55), mechanicOffset: 0),

  SeasonInfo(7,  'Time Warp',
    icon: '🔒', tagline: 'COMING SOON',
    color: Color(0xFFFFFF00), mechanicOffset: 0),

  SeasonInfo(8,  'The Abyss',
    icon: '🔒', tagline: 'COMING SOON',
    color: Color(0xFF4444FF), mechanicOffset: 0),

  SeasonInfo(9,  'Purgatory',
    icon: '🔒', tagline: 'COMING SOON',
    color: Color(0xFFFF3300), mechanicOffset: 0),

  SeasonInfo(10, 'Shadows',
    icon: '🔒', tagline: 'COMING SOON',
    color: Color(0xFFFF0055), mechanicOffset: 0),

  // ── Season 11: HELL — all 20 mechanics, 60 levels (legacy 3-level system) ─
  SeasonInfo(11, 'HELL',
    icon: '💀', tagline: 'ALL SEASONS. ONE NIGHTMARE',
    color: Color(0xFFFF0000),
    maxRounds: 60, levelsPerMechanic: 3, mechanicOffset: 0),
];


  @override
  void initState() {
    super.initState();
    _loadEconomy();
    // Each season uses local rounds 1..maxRounds
    // The Engine receives the local round + handles mechanicOffset internally
    final mr = widget.season.maxRounds;
    easyRounds   = List.generate(mr ~/ 5, (i) => i * 5 + 1);
    mediumRounds = List.generate(mr ~/ 5, (i) => i * 5 + 2);
    hardRounds   = List.generate(mr ~/ 5, (i) => i * 5 + 3);
    // Season 11 keeps old 3-level layout
    if (widget.season.levelsPerMechanic == 3) {
      final cnt = mr ~/ 3;
      easyRounds   = List.generate(cnt, (i) => i * 3 + 1);
      mediumRounds = List.generate(cnt, (i) => i * 3 + 2);
      hardRounds   = List.generate(cnt, (i) => i * 3 + 3);
    }
  }
    // For new seasons (levelsPerMechanic=5): round stays local (1..maxRounds)
    // For Season 11 (levelsPerMechanic=3): round also local (1..60)
    int localEngineRound = widget.round.clamp(1, widget.season.maxRounds);

    final hasNext = widget.round < widget.season.maxRounds;

    if (false) { // placeholder — no "under construction" for new seasons
