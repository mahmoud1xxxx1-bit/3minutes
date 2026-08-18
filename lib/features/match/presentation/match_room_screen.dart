import 'dart:async';

import 'package:flutter/material.dart';

import '../data/match_backend.dart';
import '../domain/match_session.dart';
import 'match_play_screen.dart';

class MatchRoomScreen extends StatefulWidget {
  const MatchRoomScreen({
    super.key,
    required this.matchId,
    required this.uid,
    required this.matchBackend,
  });

  final String matchId;
  final String uid;
  final MatchBackend matchBackend;

  @override
  State<MatchRoomScreen> createState() => _MatchRoomScreenState();
}

class _MatchRoomScreenState extends State<MatchRoomScreen> {
  Timer? _ticker;
  bool _readyBusy = false;
  bool _navigating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _markReady() async {
    if (_readyBusy) return;
    setState(() {
      _readyBusy = true;
      _error = null;
    });

    try {
      await widget.matchBackend.markReady(
        matchId: widget.matchId,
        uid: widget.uid,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not mark you ready. Try again.');
    } finally {
      if (mounted) setState(() => _readyBusy = false);
    }
  }

  int? _countdown(MatchSession match) {
    final startedAt = match.countdownStartedAt;
    if (startedAt == null) return null;

    final goAt = startedAt.add(const Duration(seconds: 3));
    final remainingMs = goAt.difference(DateTime.now()).inMilliseconds;
    if (remainingMs <= 0) return 0;
    return (remainingMs / 1000).ceil();
  }

  void _openPlay() {
    if (_navigating) return;
    _navigating = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => MatchPlayScreen(
            matchId: widget.matchId,
            uid: widget.uid,
            matchBackend: widget.matchBackend,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Match room')),
      body: SafeArea(
        child: StreamBuilder<MatchSession?>(
          stream: widget.matchBackend.watchMatch(widget.matchId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Could not load this match.'));
            }

            final match = snapshot.data;
            if (match == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final countdown = _countdown(match);
            if (countdown == 0) {
              _openPlay();
            }

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PlayerRow(
                    label: 'You',
                    name: match.playerAId == widget.uid
                        ? match.playerAName
                        : match.playerBName,
                    ready: match.isReady(widget.uid),
                  ),
                  const SizedBox(height: 10),
                  _PlayerRow(
                    label: 'Opponent',
                    name: match.opponentName(widget.uid),
                    ready: match.playerAId == widget.uid
                        ? match.readyB
                        : match.readyA,
                  ),
                  const Spacer(),
                  if (countdown != null) ...[
                    Text(
                      countdown == 0 ? 'GO!' : '$countdown',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Both players are ready',
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    const Text(
                      'Both players must be ready before the synchronized 3-2-1 starts.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const Spacer(),
                  if (countdown == null && !match.isReady(widget.uid))
                    FilledButton(
                      onPressed: _readyBusy ? null : _markReady,
                      child: Text(_readyBusy ? 'Getting ready...' : 'READY'),
                    )
                  else if (countdown == null)
                    const FilledButton(
                      onPressed: null,
                      child: Text('Waiting for opponent...'),
                    ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({
    required this.label,
    required this.name,
    required this.ready,
  });

  final String label;
  final String name;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(ready ? Icons.check : Icons.person),
        ),
        title: Text(name),
        subtitle: Text(label),
        trailing: Text(ready ? 'READY' : 'WAITING'),
      ),
    );
  }
}
