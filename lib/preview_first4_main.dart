import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'features/minigames/domain/mini_game_contract.dart';
import 'features/minigames/presentation/first4/find_differences_game.dart';
import 'features/minigames/presentation/first4/follow_the_cup_game.dart';
import 'features/minigames/presentation/first4/key_escape_game.dart';
import 'features/minigames/presentation/first4/level_devil_host.dart';
import 'features/minigames/presentation/shared/minigame_environment.dart';

void main() => runApp(const PreviewApp());

class PreviewApp extends StatefulWidget {
  const PreviewApp({super.key});

  @override
  State<PreviewApp> createState() => _PreviewAppState();
}

class _PreviewAppState extends State<PreviewApp> {
  bool _arabic = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '3 Minutes · First 4 Games',
      locale: Locale(_arabic ? 'ar' : 'en'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData.dark(useMaterial3: true),
      home: PreviewHome(
        arabic: _arabic,
        onToggleLanguage: () => setState(() => _arabic = !_arabic),
      ),
    );
  }
}

enum PreviewGame { followCup, findDifferences, keyEscape, levelDevil }

class PreviewHome extends StatefulWidget {
  const PreviewHome({
    super.key,
    required this.arabic,
    required this.onToggleLanguage,
  });

  final bool arabic;
  final VoidCallback onToggleLanguage;

  @override
  State<PreviewHome> createState() => _PreviewHomeState();
}

class _PreviewHomeState extends State<PreviewHome> {
  PreviewGame? _game;
  int _score = 0;
  int _matchTotal = 0;
  int _remaining = 180;
  Timer? _timer;
  int _seed = 0;

  String t(String ar, String en) => widget.arabic ? ar : en;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start(PreviewGame game) {
    _timer?.cancel();
    setState(() {
      _game = game;
      _score = 0;
      _remaining = 180;
      _seed++;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining <= 0) {
        _timer?.cancel();
        return;
      }
      setState(() => _remaining--);
    });
  }

  int _normalizedFinalScore(MiniGameResult result) {
    if (_game == PreviewGame.findDifferences) {
      return (result.score * 10).clamp(0, 1000);
    }
    return result.score.clamp(0, 1000);
  }

  void _finish(MiniGameResult result) {
    _timer?.cancel();
    final points = _normalizedFinalScore(result);
    setState(() {
      _score = points;
      _matchTotal = (_matchTotal + points).clamp(0, 4000);
    });
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0B1120),
        title: Text(t('اكتملت اللعبة', 'GAME COMPLETE')),
        content: Text(
          '${t('نقاط المباراة', 'Match Points')}: $points / 1000\n'
          '${t('الأخطاء', 'Mistakes')}: ${result.mistakes}\n'
          '${t('الدقة', 'Accuracy')}: ${(result.accuracy * 100).round()}%\n'
          '${t('الوقت', 'Time')}: ${result.duration.inSeconds}s',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _game = null);
            },
            child: Text(t('العودة للألعاب', 'BACK TO GAMES')),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _start(_game!);
            },
            child: Text(t('العب مجددًا', 'PLAY AGAIN')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01030A),
      body: LayoutBuilder(
        builder: (context, constraints) {
          const logicalWidth = 390.0;
          const logicalHeight = 844.0;
          final sx = constraints.maxWidth / logicalWidth;
          final sy = constraints.maxHeight / logicalHeight;
          final scale = sx < sy ? sx.clamp(0.6, 1.0) : sy.clamp(0.6, 1.0);
          return Center(
            child: Transform.scale(
              scale: scale,
              child: SizedBox(
                width: logicalWidth,
                height: logicalHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFF050817),
                    border: Border.all(color: const Color(0xFF263759)),
                  ),
                  child: SafeArea(
                    child: _game == null ? _selection() : _gameShell(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _languageButton() {
    return OutlinedButton.icon(
      onPressed: widget.onToggleLanguage,
      icon: const Icon(Icons.language, size: 16),
      label: Text(widget.arabic ? 'EN' : 'عربي'),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF52F2F2),
        side: const BorderSide(color: Color(0xFF26436A)),
        minimumSize: const Size(64, 38),
        padding: const EdgeInsets.symmetric(horizontal: 10),
      ),
    );
  }

  Widget _selection() {
    final cards = [
      _GameCard(
        title: t('تتبع القبعة', 'Follow The Cup'),
        subtitle: t('3 جولات. تتبع الكرة تحت القبعات مع زيادة سرعة الخلط.', '3 rounds. Track the ball under the hats as shuffle speed increases.'),
        meta: t('3 جولات · ذاكرة', '3 ROUNDS · MEMORY'),
        icon: Icons.casino_outlined,
        onTap: () => _start(PreviewGame.followCup),
      ),
      _GameCard(
        title: t('اكتشف الاختلافات', 'Find Differences'),
        subtitle: t('اكتشف الاختلافات الخمسة في المشهد الأصلي.', 'Find all five differences in the original scene.'),
        meta: t('جولة واحدة · منطق', '1 ROUND · LOGIC'),
        icon: Icons.travel_explore,
        onTap: () => _start(PreviewGame.findDifferences),
      ),
      _GameCard(
        title: t('هروب المفتاح', 'Key Escape'),
        subtitle: t('3 ألغاز. حرّك القطع وأخرج المفتاح بأقل عدد من الحركات.', '3 puzzles. Move the blocks and free the key with efficient moves.'),
        meta: t('3 جولات · ألغاز', '3 ROUNDS · PUZZLE'),
        icon: Icons.key_rounded,
        onTap: () => _start(PreviewGame.keyEscape),
      ),
      _GameCard(
        title: t('مرحلة الشيطان', 'Level Devil'),
        subtitle: t('3 جولات متتابعة من الفصل المختار مع فخاخ وتحكم كامل.', '3 consecutive rounds from one chapter with traps and full controls.'),
        meta: t('3 جولات · مهارة', '3 ROUNDS · SKILL'),
        icon: Icons.sports_esports_rounded,
        onTap: () => _start(PreviewGame.levelDevil),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const _Logo(),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('3 MINUTES', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                    Text(t('معاينة الجوال · المصدر الأصلي', 'MOBILE PREVIEW · ORIGINAL SOURCE'), style: const TextStyle(fontSize: 9, color: Color(0xFF8290AD), fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              _languageButton(),
            ],
          ),
          const SizedBox(height: 16),
          Text(t('الألعاب الأربع', 'FIRST FOUR GAMES'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              itemCount: cards.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.76,
              ),
              itemBuilder: (context, index) => cards[index],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t('إطار 3 Minutes موحّد، بينما محتوى كل لعبة من المصدر الذي أرسلته.', 'The 3 Minutes frame is unified; each game keeps the supplied source content.'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9, color: Color(0xFF6E7C99)),
          ),
        ],
      ),
    );
  }

  String _gameName(PreviewGame game) {
    switch (game) {
      case PreviewGame.followCup:
        return t('تتبع القبعة', 'Follow The Cup');
      case PreviewGame.findDifferences:
        return t('اكتشف الاختلافات', 'Find Differences');
      case PreviewGame.keyEscape:
        return t('هروب المفتاح', 'Key Escape');
      case PreviewGame.levelDevil:
        return t('مرحلة الشيطان', 'Level Devil');
    }
  }

  Widget _buildGame(MiniGameConfig config) {
    switch (_game!) {
      case PreviewGame.followCup:
        return FollowTheCupGame(key: ValueKey('cup-$_seed'), config: config, onComplete: _finish);
      case PreviewGame.findDifferences:
        return FindDifferencesGame(key: ValueKey('find-$_seed'), config: config, onComplete: _finish);
      case PreviewGame.keyEscape:
        return KeyEscapeGame(key: ValueKey('key-$_seed'), config: config, onComplete: _finish);
      case PreviewGame.levelDevil:
        return LevelDevilHost(key: ValueKey('devil-$_seed'), config: config, onComplete: _finish);
    }
  }

  Widget _gameShell() {
    final selected = _game!;
    final config = MiniGameConfig(
      seed: selected == PreviewGame.findDifferences ? _seed % 45 : 1234 + _seed,
      difficulty: 1,
    );
    final game = _buildGame(config);

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(8, 8, 8, 10),
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1120),
            border: Border.all(color: const Color(0xFF1D2943)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: t('رجوع', 'Back'),
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      _timer?.cancel();
                      setState(() => _game = null);
                    },
                    icon: Icon(widget.arabic ? Icons.arrow_forward_ios : Icons.arrow_back_ios_new, size: 16),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF19DCE8).withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(t('معاينة', 'PREVIEW'), style: const TextStyle(color: Color(0xFF52F2F2), fontSize: 8, fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(width: 7),
                  Expanded(child: Text(_gameName(selected), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900), overflow: TextOverflow.ellipsis)),
                  Text(
                    '${(_remaining ~/ 60).toString().padLeft(2, '0')}:${(_remaining % 60).toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Color(0xFFFFD76A), fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(width: 54, height: 34, child: _languageButton()),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _Metric(label: t('نقاط اللعبة', 'GAME POINTS'), value: '$_score / 1000')),
                  const SizedBox(width: 8),
                  Expanded(child: _Metric(label: t('مجموع المباراة', 'MATCH TOTAL'), value: '$_matchTotal / 4000')),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFF070B17),
              border: Border.all(color: const Color(0xFF17213A)),
              borderRadius: BorderRadius.circular(22),
            ),
            child: MinigameEnvironment(
              onScore: (value) {
                if (!mounted) return;
                final normalized = selected == PreviewGame.findDifferences
                    ? value.clamp(0, 1000)
                    : value.clamp(0, 1000);
                setState(() => _score = normalized);
              },
              onTimeProgress: (_) {},
              onSuccess: (_) {},
              onError: (_) {},
              child: game,
            ),
          ),
        ),
      ],
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF19DCE8), Color(0xFF7657F6)]),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: const Text('3', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
      );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
        decoration: BoxDecoration(color: const Color(0xFF08101F), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF6C7B99), fontSize: 8, fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
          ],
        ),
      );
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String meta;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: const Color(0xFF0B1120),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF1D2943)),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: const Color(0xFF142039), borderRadius: BorderRadius.circular(12)),
                  alignment: Alignment.center,
                  child: Icon(icon, color: const Color(0xFF52F2F2), size: 24),
                ),
                const Spacer(),
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text(subtitle, style: const TextStyle(color: Color(0xFF91A0BD), fontSize: 9.5, height: 1.3), maxLines: 4, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text(meta, style: const TextStyle(color: Color(0xFF52F2F2), fontSize: 8, fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                const Text('MAX · 1,000', style: TextStyle(color: Color(0xFFFFD76A), fontSize: 10, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ),
      );
}
