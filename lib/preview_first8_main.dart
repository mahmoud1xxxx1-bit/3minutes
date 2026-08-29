import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'features/minigames/domain/mini_game_contract.dart';
import 'features/minigames/presentation/first4/find_differences_game.dart';
import 'features/minigames/presentation/first4/follow_the_cup_game.dart';
import 'features/minigames/presentation/first4/key_escape_game.dart';
import 'features/minigames/presentation/first4/level_devil_host.dart';
import 'features/minigames/presentation/mole_strike/mole_strike_game.dart';
import 'features/minigames/presentation/ninja_slice/ninja_slice_game.dart';
import 'features/minigames/presentation/onet_connect/onet_connect_game.dart';
import 'features/minigames/presentation/shared/minigame_environment.dart';

void main() => runApp(const Preview8App());

class Preview8App extends StatefulWidget {
  const Preview8App({super.key});
  @override
  State<Preview8App> createState() => _Preview8AppState();
}

class _Preview8AppState extends State<Preview8App> {
  bool arabic = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Locale(arabic ? 'ar' : 'en'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData.dark(useMaterial3: true),
      home: Preview8Home(
        arabic: arabic,
        onToggleLanguage: () => setState(() => arabic = !arabic),
      ),
    );
  }
}

enum PreviewGame {
  followCup,
  findDifferences,
  keyEscape,
  levelDevil,
  moleStrike,
  ninjaSlice,
  onetConnect,
}

class Preview8Home extends StatefulWidget {
  const Preview8Home({
    super.key,
    required this.arabic,
    required this.onToggleLanguage,
  });

  final bool arabic;
  final VoidCallback onToggleLanguage;

  @override
  State<Preview8Home> createState() => _Preview8HomeState();
}

class _Preview8HomeState extends State<Preview8Home> {
  PreviewGame? _game;
  int _score = 0;
  int _matchTotal = 0;
  int _remaining = 180;
  int _seed = 0;
  Timer? _timer;

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

  int _normalizeFinal(MiniGameResult result) {
    switch (_game!) {
      case PreviewGame.findDifferences:
        return (result.score * 10).clamp(0, 1000);
      case PreviewGame.moleStrike:
        final rawPart = ((result.score.clamp(0, 7000) / 7000) * 700).round();
        final accuracyPart = (result.accuracy.clamp(0.0, 1.0) * 200).round();
        final cleanPart = (100 - result.mistakes * 15).clamp(0, 100);
        return (rawPart + accuracyPart + cleanPart).clamp(0, 1000);
      case PreviewGame.ninjaSlice:
        final rawPart = ((result.score.clamp(0, 1200) / 1200) * 700).round();
        final accuracyPart = (result.accuracy.clamp(0.0, 1.0) * 200).round();
        final survivalPart = result.completed ? 100 : (100 - result.mistakes * 34).clamp(0, 100);
        return (rawPart + accuracyPart + survivalPart).clamp(0, 1000);
      case PreviewGame.onetConnect:
        return result.score.clamp(0, 1000);
      default:
        return result.score.clamp(0, 1000);
    }
  }

  int _normalizeLive(int value) {
    if (_game == PreviewGame.moleStrike) {
      return ((value.clamp(0, 7000) / 7000) * 700).round().clamp(0, 700);
    }
    return value.clamp(0, 1000);
  }

  void _finish(MiniGameResult result) {
    _timer?.cancel();
    final points = _normalizeFinal(result);
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

  void _mirrorMissing() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0B1120),
        title: Text(t('Mirror Control غير جاهزة', 'Mirror Control is not ready')),
        content: Text(
          t(
            'المصدر الأصلي يحتاج player.png و enemy.png و target.png. لن أستبدلها برسومات من عندي.',
            'The supplied source requires player.png, enemy.png and target.png. They will not be replaced with invented artwork.',
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t('فهمت', 'OK')),
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
          final landscape = _game == PreviewGame.findDifferences;
          final logicalWidth = landscape ? 844.0 : 390.0;
          final logicalHeight = landscape ? 390.0 : 844.0;
          final sx = constraints.maxWidth / logicalWidth;
          final sy = constraints.maxHeight / logicalHeight;
          final scale = (sx < sy ? sx : sy).clamp(0.35, 1.0);
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
        padding: const EdgeInsets.symmetric(horizontal: 10),
      ),
    );
  }

  Widget _selection() {
    final cards = <Widget>[
      _gameCard('تتبع القبعة', 'Follow The Cup', '3 جولات · ذاكرة', '3 ROUNDS · MEMORY',
          'تتبع الكرة تحت القبعات.', 'Track the ball under the hats.', Icons.casino_outlined, () => _start(PreviewGame.followCup)),
      _gameCard('اكتشف الاختلافات', 'Find Differences', 'جولة · منطق · عرضي', '1 ROUND · LOGIC · LANDSCAPE',
          'اكتشف الاختلافات الخمسة.', 'Find all five differences.', Icons.travel_explore, () => _start(PreviewGame.findDifferences)),
      _gameCard('هروب المفتاح', 'Key Escape', '3 جولات · ألغاز', '3 ROUNDS · PUZZLE',
          'حرّك القطع وأخرج المفتاح.', 'Move the blocks and free the key.', Icons.key_rounded, () => _start(PreviewGame.keyEscape)),
      _gameCard('مرحلة الشيطان', 'Level Devil', '3 جولات · مهارة', '3 ROUNDS · SKILL',
          'تجاوز الفخاخ وأنهِ المراحل.', 'Survive the traps and clear the stages.', Icons.sports_esports_rounded, () => _start(PreviewGame.levelDevil)),
      _gameCard('ضربة الخلد', 'Mole Strike', '30 ثانية · رد فعل', '30 SEC · REACTION',
          'اضرب الأهداف وتجنب الخادعة.', 'Strike targets and avoid decoys.', Icons.sports_baseball, () => _start(PreviewGame.moleStrike)),
      _gameCard('تقطيع النينجا', 'Ninja Slice', 'مهارة · كومبو', 'SKILL · COMBO',
          'اقطع الأهداف وتجنب الأطباق.', 'Slice targets and avoid plates.', Icons.gesture_rounded, () => _start(PreviewGame.ninjaSlice)),
      _gameCard('ربط الأزواج', 'Onet Connect', '28 زوجًا · ألغاز', '28 PAIRS · PUZZLE',
          'اربط الأزواج بمسار صحيح.', 'Connect matching pairs with a valid path.', Icons.hub_outlined, () => _start(PreviewGame.onetConnect)),
      _gameCard('تحكم المرآة', 'Mirror Control', '105 مشاهد · أصول ناقصة', '105 SCENES · ASSETS MISSING',
          'بانتظار صور اللاعب والمطارد والهدف الأصلية.', 'Waiting for the original player, enemy and target images.',
          Icons.control_camera_rounded, _mirrorMissing, disabled: true),
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
                    Text(t('معاينة الجوال · 8 ألعاب', 'MOBILE PREVIEW · 8 GAMES'),
                        style: const TextStyle(fontSize: 9, color: Color(0xFF8290AD), fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              _languageButton(),
            ],
          ),
          const SizedBox(height: 14),
          Text(t('مكتبة الألعاب', 'GAME LIBRARY'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
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
        ],
      ),
    );
  }

  Widget _gameCard(
    String arTitle, String enTitle,
    String arMeta, String enMeta,
    String arSubtitle, String enSubtitle,
    IconData icon, VoidCallback onTap, {bool disabled = false}
  ) {
    return _GameCard(
      title: t(arTitle, enTitle),
      meta: t(arMeta, enMeta),
      subtitle: t(arSubtitle, enSubtitle),
      icon: icon,
      onTap: onTap,
      disabled: disabled,
    );
  }

  String _gameName(PreviewGame game) {
    switch (game) {
      case PreviewGame.followCup: return t('تتبع القبعة', 'Follow The Cup');
      case PreviewGame.findDifferences: return t('اكتشف الاختلافات', 'Find Differences');
      case PreviewGame.keyEscape: return t('هروب المفتاح', 'Key Escape');
      case PreviewGame.levelDevil: return t('مرحلة الشيطان', 'Level Devil');
      case PreviewGame.moleStrike: return t('ضربة الخلد', 'Mole Strike');
      case PreviewGame.ninjaSlice: return t('تقطيع النينجا', 'Ninja Slice');
      case PreviewGame.onetConnect: return t('ربط الأزواج', 'Onet Connect');
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
      case PreviewGame.moleStrike:
        return MoleStrikeGame(key: ValueKey('mole-$_seed'), config: config, onComplete: _finish);
      case PreviewGame.ninjaSlice:
        return NinjaSliceGame(key: ValueKey('ninja-$_seed'), config: config, onComplete: _finish);
      case PreviewGame.onetConnect:
        return OnetConnectGame(key: ValueKey('onet-$_seed'), config: config, onComplete: _finish);
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
          padding: const EdgeInsets.all(10),
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
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      _timer?.cancel();
                      setState(() => _game = null);
                    },
                    icon: Icon(widget.arabic ? Icons.arrow_forward_ios : Icons.arrow_back_ios_new, size: 16),
                  ),
                  Expanded(child: Text(_gameName(selected), style: const TextStyle(fontWeight: FontWeight.w900), overflow: TextOverflow.ellipsis)),
                  Text(
                    '${(_remaining ~/ 60).toString().padLeft(2, '0')}:${(_remaining % 60).toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Color(0xFFFFD76A), fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(width: 5),
                  SizedBox(height: 34, child: _languageButton()),
                ],
              ),
              const SizedBox(height: 6),
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
                setState(() => _score = _normalizeLive(value));
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

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.icon,
    required this.onTap,
    this.disabled = false,
  });

  final String title;
  final String subtitle;
  final String meta;
  final IconData icon;
  final VoidCallback onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? .62 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF0B1120),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: disabled ? const Color(0xFF5A3D42) : const Color(0xFF213354)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    gradient: disabled ? null : const LinearGradient(colors: [Color(0xFF19DCE8), Color(0xFF7657F6)]),
                    color: disabled ? const Color(0xFF342129) : null,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: Colors.white),
                ),
                const Spacer(),
                Text(meta, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900,
                    color: disabled ? const Color(0xFFFF9E9E) : const Color(0xFF52F2F2))),
                const SizedBox(height: 5),
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900), maxLines: 2),
                const SizedBox(height: 5),
                Text(subtitle, style: const TextStyle(fontSize: 9, color: Color(0xFF8794AE), height: 1.35), maxLines: 3),
                const SizedBox(height: 8),
                const Text('MAX 1000', style: TextStyle(fontSize: 9, color: Color(0xFFFFD76A), fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(color: const Color(0xFF070B17), borderRadius: BorderRadius.circular(12)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 7, color: Color(0xFF75829C), fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
      ],
    ),
  );
}

class _Logo extends StatelessWidget {
  const _Logo();
  @override
  Widget build(BuildContext context) => Container(
    width: 44, height: 44,
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF19DCE8), Color(0xFF7657F6)]),
      borderRadius: BorderRadius.circular(14),
    ),
    child: const Center(child: Text('3', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900))),
  );
}
