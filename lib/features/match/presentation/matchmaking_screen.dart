import 'package:flutter/material.dart';

import '../../profile/domain/player_profile.dart';
import '../data/match_backend.dart';
import '../domain/match_ticket.dart';
import 'match_room_screen.dart';

class MatchmakingScreen extends StatefulWidget {
  const MatchmakingScreen({
    super.key,
    required this.profile,
    required this.matchBackend,
  });

  final PlayerProfile profile;
  final MatchBackend matchBackend;

  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen> {
  String? _error;
  bool _joining = true;
  bool _leaving = false;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    _join();
  }

  Future<void> _join() async {
    if (mounted) {
      setState(() {
        _joining = true;
        _error = null;
      });
    }

    try {
      await widget.matchBackend.joinQueue(widget.profile);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not start matchmaking. Try again.');
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  Future<void> _cancel() async {
    if (_leaving || _navigating) return;
    setState(() => _leaving = true);
    try {
      await widget.matchBackend.leaveQueue(widget.profile.uid);
    } finally {
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _openMatch(String matchId) {
    if (_navigating) return;
    _navigating = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => MatchRoomScreen(
            matchId: matchId,
            uid: widget.profile.uid,
            matchBackend: widget.matchBackend,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _cancel();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Finding opponent'),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: StreamBuilder<MatchTicket?>(
            stream: widget.matchBackend.watchTicket(widget.profile.uid),
            builder: (context, snapshot) {
              final ticket = snapshot.data;
              if (ticket?.status == MatchTicketStatus.matched &&
                  ticket?.matchId != null) {
                _openMatch(ticket!.matchId!);
              }

              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    const Center(
                      child: SizedBox.square(
                        dimension: 64,
                        child: CircularProgressIndicator(strokeWidth: 6),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _joining ? 'Joining queue...' : 'Searching for a player...',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your match will use the same 3-minute clock and game seed for both players.',
                      textAlign: TextAlign.center,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 20),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _joining ? null : _join,
                        child: const Text('Try again'),
                      ),
                    ],
                    const Spacer(),
                    OutlinedButton(
                      onPressed: _leaving ? null : _cancel,
                      child: Text(_leaving ? 'Leaving...' : 'Cancel'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
