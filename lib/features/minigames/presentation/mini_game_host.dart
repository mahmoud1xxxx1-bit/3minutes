import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../domain/mini_game_contract.dart';

class MiniGameHost extends StatelessWidget {
  const MiniGameHost({
    super.key,
    required this.game,
    required this.config,
    required this.onComplete,
  });

  final MiniGameDescriptor game;
  final MiniGameConfig config;
  final ValueChanged<MiniGameResult> onComplete;

  @override
  Widget build(BuildContext context) {
    switch (game.id) {
      case 'quick_math':
      case 'color_match':
      case 'odd_one_out':
      case 'shape_count':
      case 'symbol_pair':
        return _ChoiceChallenge(
          key: ValueKey('${game.id}-${config.seed}'),
          gameId: game.id,
          seed: config.seed,
          onComplete: onComplete,
        );
      case 'tap_target':
        return _TapTargetChallenge(
          key: ValueKey('${game.id}-${config.seed}'),
          seed: config.seed,
          onComplete: onComplete,
        );
      case 'number_order':
      case 'memory_flash':
        return _SequenceChallenge(
          key: ValueKey('${game.id}-${config.seed}'),
          gameId: game.id,
          seed: config.seed,
          onComplete: onComplete,
        );
      case 'direction_swipe':
        return _SwipeChallenge(
          key: ValueKey('${game.id}-${config.seed}'),
          seed: config.seed,
          onComplete: onComplete,
        );
      case 'reaction_stop':
        return _ReactionChallenge(
          key: ValueKey('${game.id}-${config.seed}'),
          seed: config.seed,
          onComplete: onComplete,
        );
      default:
        return Center(child: Text('Unknown mini-game: ${game.id}'));
    }
  }
}

class _ChoiceSpec {
  const _ChoiceSpec({
    required this.prompt,
    required this.options,
    required this.correctIndex,
  });

  final String prompt;
  final List<String> options;
  final int correctIndex;
}

class _ChoiceChallenge extends StatefulWidget {
  const _ChoiceChallenge({
    super.key,
    required this.gameId,
    required this.seed,
    required this.onComplete,
  });

  final String gameId;
  final int seed;
  final ValueChanged<MiniGameResult> onComplete;

  @override
  State<_ChoiceChallenge> createState() => _ChoiceChallengeState();
}

class _ChoiceChallengeState extends State<_ChoiceChallenge> {
  late final Stopwatch _watch;
  late final _ChoiceSpec _spec;
  int _mistakes = 0;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _watch = Stopwatch()..start();
    _spec = _buildSpec(widget.gameId, widget.seed);
  }

  _ChoiceSpec _buildSpec(String id, int seed) {
    final random = Random(seed);
    switch (id) {
      case 'quick_math':
        final a = 2 + random.nextInt(8);
        final b = 2 + random.nextInt(8);
        final answer = a + b;
        final options = <int>{answer, answer + 1, max(0, answer - 1), answer + 2}.toList();
        options.shuffle(random);
        return _ChoiceSpec(
          prompt: '$a + $b = ?',
          options: options.map((value) => '$value').toList(),
          correctIndex: options.indexOf(answer),
        );
      case 'color_match':
        const colors = ['RED', 'BLUE', 'GREEN', 'YELLOW'];
        final answer = colors[random.nextInt(colors.length)];
        final options = List<String>.of(colors)..shuffle(random);
        return _ChoiceSpec(
          prompt: 'Tap $answer',
          options: options,
          correctIndex: options.indexOf(answer),
        );
      case 'odd_one_out':
        const sets = [
          ['●', '●', '●', '■'],
          ['▲', '▲', '◆', '▲'],
          ['★', '☆', '★', '★'],
        ];
        final options = List<String>.of(sets[random.nextInt(sets.length)]);
        final odd = options.firstWhere((value) => options.where((x) => x == value).length == 1);
        return _ChoiceSpec(
          prompt: 'Find the odd one',
          options: options,
          correctIndex: options.indexOf(odd),
        );
      case 'shape_count':
        final count = 2 + random.nextInt(5);
        final options = <int>{count, max(1, count - 1), count + 1, count + 2}.toList();
        options.shuffle(random);
        return _ChoiceSpec(
          prompt: '${List.filled(count, '●').join('  ')}\nHow many?',
          options: options.map((value) => '$value').toList(),
          correctIndex: options.indexOf(count),
        );
      case 'symbol_pair':
      default:
        const pairs = [
          ['★', '★', '☆', '✦', '◆'],
          ['◆', '◇', '◆', '●', '▲'],
          ['▲', '■', '●', '▲', '◆'],
        ];
        final row = pairs[random.nextInt(pairs.length)];
        final target = row.first;
        final options = row.sublist(1);
        return _ChoiceSpec(
          prompt: 'Match $target',
          options: options,
          correctIndex: options.indexOf(target),
        );
    }
  }

  void _pick(int index) {
    if (_done) return;
    if (index != _spec.correctIndex) {
      setState(() => _mistakes++);
      return;
    }

    _done = true;
    _watch.stop();
    widget.onComplete(
      MiniGameResult(
        completed: true,
        score: max(10, 100 - (_mistakes * 15)),
        accuracy: 1 / (_mistakes + 1),
        mistakes: _mistakes,
        duration: _watch.elapsed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        Text(
          _spec.prompt,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 28),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.2,
          ),
          itemCount: _spec.options.length,
          itemBuilder: (context, index) {
            return FilledButton(
              onPressed: () => _pick(index),
              child: Text(
                _spec.options[index],
                style: const TextStyle(fontSize: 22),
              ),
            );
          },
        ),
        const Spacer(),
      ],
    );
  }
}

class _TapTargetChallenge extends StatefulWidget {
  const _TapTargetChallenge({
    super.key,
    required this.seed,
    required this.onComplete,
  });

  final int seed;
  final ValueChanged<MiniGameResult> onComplete;

  @override
  State<_TapTargetChallenge> createState() => _TapTargetChallengeState();
}

class _TapTargetChallengeState extends State<_TapTargetChallenge> {
  late final Stopwatch _watch = Stopwatch()..start();
  late final Alignment _alignment;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    final random = Random(widget.seed);
    _alignment = Alignment(
      -0.8 + random.nextDouble() * 1.6,
      -0.6 + random.nextDouble() * 1.2,
    );
  }

  void _hit() {
    if (_done) return;
    _done = true;
    _watch.stop();
    final ms = _watch.elapsedMilliseconds;
    widget.onComplete(
      MiniGameResult(
        completed: true,
        score: max(20, 150 - (ms ~/ 20)),
        accuracy: 1,
        mistakes: 0,
        duration: _watch.elapsed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Center(
          child: Text(
            'Tap the target',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Align(
          alignment: _alignment,
          child: GestureDetector(
            onTap: _hit,
            child: Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Icon(Icons.gps_fixed, size: 38),
            ),
          ),
        ),
      ],
    );
  }
}

class _SequenceChallenge extends StatefulWidget {
  const _SequenceChallenge({
    super.key,
    required this.gameId,
    required this.seed,
    required this.onComplete,
  });

  final String gameId;
  final int seed;
  final ValueChanged<MiniGameResult> onComplete;

  @override
  State<_SequenceChallenge> createState() => _SequenceChallengeState();
}

class _SequenceChallengeState extends State<_SequenceChallenge> {
  late final Stopwatch _watch = Stopwatch()..start();
  late final List<int> _values;
  int _next = 1;
  int _mistakes = 0;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _values = [1, 2, 3, 4, 5]..shuffle(Random(widget.seed));
  }

  void _tap(int value) {
    if (_done) return;
    if (value != _next) {
      setState(() => _mistakes++);
      return;
    }

    if (_next == 5) {
      _done = true;
      _watch.stop();
      widget.onComplete(
        MiniGameResult(
          completed: true,
          score: max(20, 140 - (_mistakes * 15)),
          accuracy: 5 / (5 + _mistakes),
          mistakes: _mistakes,
          duration: _watch.elapsed,
        ),
      );
      return;
    }

    setState(() => _next++);
  }

  @override
  Widget build(BuildContext context) {
    final memory = widget.gameId == 'memory_flash';
    return Column(
      children: [
        const Spacer(),
        Text(
          memory ? 'Remember and tap 1 → 5' : 'Tap 1 → 5',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 28),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 14,
          runSpacing: 14,
          children: _values.map((value) {
            return SizedBox.square(
              dimension: 72,
              child: FilledButton(
                onPressed: () => _tap(value),
                child: Text('$value', style: const TextStyle(fontSize: 22)),
              ),
            );
          }).toList(),
        ),
        const Spacer(),
      ],
    );
  }
}

class _SwipeChallenge extends StatefulWidget {
  const _SwipeChallenge({
    super.key,
    required this.seed,
    required this.onComplete,
  });

  final int seed;
  final ValueChanged<MiniGameResult> onComplete;

  @override
  State<_SwipeChallenge> createState() => _SwipeChallengeState();
}

class _SwipeChallengeState extends State<_SwipeChallenge> {
  late final Stopwatch _watch = Stopwatch()..start();
  late final int _direction = Random(widget.seed).nextInt(4);
  Offset _delta = Offset.zero;
  int _mistakes = 0;
  bool _done = false;

  static const _icons = [
    Icons.arrow_upward,
    Icons.arrow_forward,
    Icons.arrow_downward,
    Icons.arrow_back,
  ];

  void _end() {
    if (_done) return;
    final horizontal = _delta.dx.abs() > _delta.dy.abs();
    final actual = horizontal
        ? (_delta.dx > 0 ? 1 : 3)
        : (_delta.dy > 0 ? 2 : 0);

    if (actual != _direction) {
      setState(() {
        _mistakes++;
        _delta = Offset.zero;
      });
      return;
    }

    _done = true;
    _watch.stop();
    widget.onComplete(
      MiniGameResult(
        completed: true,
        score: max(20, 120 - (_mistakes * 20)),
        accuracy: 1 / (_mistakes + 1),
        mistakes: _mistakes,
        duration: _watch.elapsed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: (details) => _delta += details.delta,
      onPanEnd: (_) => _end(),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Swipe in this direction'),
            const SizedBox(height: 20),
            Icon(_icons[_direction], size: 100),
          ],
        ),
      ),
    );
  }
}

class _ReactionChallenge extends StatefulWidget {
  const _ReactionChallenge({
    super.key,
    required this.seed,
    required this.onComplete,
  });

  final int seed;
  final ValueChanged<MiniGameResult> onComplete;

  @override
  State<_ReactionChallenge> createState() => _ReactionChallengeState();
}

class _ReactionChallengeState extends State<_ReactionChallenge> {
  Timer? _timer;
  Stopwatch? _reactionWatch;
  bool _go = false;
  bool _done = false;
  int _mistakes = 0;

  @override
  void initState() {
    super.initState();
    final delay = 800 + Random(widget.seed).nextInt(1000);
    _timer = Timer(Duration(milliseconds: delay), () {
      if (!mounted || _done) return;
      setState(() {
        _go = true;
        _reactionWatch = Stopwatch()..start();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tap() {
    if (_done) return;
    if (!_go) {
      setState(() => _mistakes++);
      return;
    }

    _done = true;
    _reactionWatch?.stop();
    final elapsed = _reactionWatch?.elapsed ?? Duration.zero;
    widget.onComplete(
      MiniGameResult(
        completed: true,
        score: max(20, 180 - (elapsed.inMilliseconds ~/ 5) - (_mistakes * 25)),
        accuracy: 1 / (_mistakes + 1),
        mistakes: _mistakes,
        duration: elapsed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _tap,
      child: Center(
        child: Text(
          _go ? 'TAP!' : 'Wait...',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
      ),
    );
  }
}
