import 'dart:async';
import 'package:flutter/material.dart';

import 'features/minigames/domain/mini_game_contract.dart';
import 'features/minigames/presentation/first4/find_differences_game.dart';
import 'features/minigames/presentation/first4/follow_the_cup_game.dart';
import 'features/minigames/presentation/shared/minigame_environment.dart';

void main() {
  runApp(const PreviewApp());
}

class PreviewApp extends StatelessWidget {
  const PreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '3 Minutes · Original Games Preview',
      theme: ThemeData.dark(useMaterial3: true),
      home: const PreviewHome(),
    );
  }
}

enum PreviewGame { followCup, findDifferences }

class PreviewHome extends StatefulWidget {
  const PreviewHome({super.key});

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

  void _finish(MiniGameResult result) {
    _timer?.cancel();
    final points = result.score.clamp(0, 1000);
    setState(() {
      _score = points;
      _matchTotal += points;
    });
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0B1120),
        title: const Text('GAME COMPLETE'),
        content: Text(
          'Match Points: $points / 1000\n'
          'Mistakes: ${result.mistakes}\n'
          'Accuracy: ${(result.accuracy * 100).round()}%\n'
          'Time: ${result.duration.inSeconds}s',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _game = null);
            },
            child: const Text('BACK TO GAMES'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _start(_game!);
            },
            child: const Text('PLAY AGAIN'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF050817);
    return Scaffold(
      backgroundColor: const Color(0xFF01030A),
      body: Center(
        child: Container(
          width: 390,
          height: 844,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: const Color(0xFF263759)),
          ),
          child: SafeArea(
            child: _game == null ? _selection() : _gameShell(),
          ),
        ),
      ),
    );
  }

  Widget _selection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              _Logo(),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('3 MINUTES', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    Text('ORIGINAL SOURCE · MOBILE PREVIEW', style: TextStyle(fontSize: 9, color: Color(0xFF8290AD), fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('ORIGINAL GAMES', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _GameCard(
                    title: 'Follow The Cup',
                    subtitle: 'Original purple magic hats, cyan ball, particles and 3-round shuffle logic.',
                    meta: '3 ROUNDS · MEMORY',
                    icon: Icons.casino_outlined,
                    onTap: () => _start(PreviewGame.followCup),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _GameCard(
                    title: 'Find Differences',
                    subtitle: 'Original CustomPainter scene and exact difference regions from the supplied source.',
                    meta: '1 ROUND · LOGIC',
                    icon: Icons.travel_explore,
                    onTap: () => _start(PreviewGame.findDifferences),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'The dark frame/HUD belongs to 3 Minutes. The game canvas below uses the supplied Dart source.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 9, color: Color(0xFF6E7C99)),
          ),
        ],
      ),
    );
  }

  Widget _gameShell() {
    final name = _game == PreviewGame.followCup ? 'Follow The Cup' : 'Find Differences';
    final config = MiniGameConfig(seed: _game == PreviewGame.findDifferences ? 0 : 1234 + _seed, difficulty: 1);
    final game = _game == PreviewGame.followCup
        ? FollowTheCupGame(key: ValueKey('cup-$_seed'), config: config, onComplete: _finish)
        : FindDifferencesGame(key: ValueKey('find-$_seed'), config: config, onComplete: _finish);

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(8, 8, 8, 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1120),
            border: Border.all(color: const Color(0xFF1D2943)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF19DCE8).withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text('GAME PREVIEW', style: TextStyle(color: Color(0xFF52F2F2), fontSize: 9, fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900))),
                  Text(
                    '${(_remaining ~/ 60).toString().padLeft(2, '0')}:${(_remaining % 60).toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Color(0xFFFFD76A), fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _Metric(label: 'GAME POINTS', value: '$_score / 1000')),
                  const SizedBox(width: 8),
                  Expanded(child: _Metric(label: 'MATCH TOTAL', value: '$_matchTotal / 4000')),
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
                if (mounted) setState(() => _score = value.clamp(0, 1000));
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
    width: 44, height: 44,
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
    required this.title, required this.subtitle, required this.meta, required this.icon, required this.onTap,
  });
  final String title, subtitle, meta;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFF0B1120),
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF1D2943)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: const Color(0xFF142039), borderRadius: BorderRadius.circular(14)),
              alignment: Alignment.center,
              child: Icon(icon, color: const Color(0xFF52F2F2), size: 28),
            ),
            const Spacer(),
            Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
            const SizedBox(height: 7),
            Text(subtitle, style: const TextStyle(color: Color(0xFF91A0BD), fontSize: 11, height: 1.35)),
            const SizedBox(height: 10),
            Text(meta, style: const TextStyle(color: Color(0xFF52F2F2), fontSize: 9, fontWeight: FontWeight.w900)),
            const SizedBox(height: 7),
            const Text('MAX · 1,000 MATCH POINTS', style: TextStyle(color: Color(0xFFFFD76A), fontSize: 11, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    ),
  );
}
