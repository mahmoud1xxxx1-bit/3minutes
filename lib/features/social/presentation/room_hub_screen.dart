import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../../match/data/social_match_backend.dart';
import '../../profile/domain/player_profile.dart';
import '../data/room_backend.dart';
import '../data/social_backend.dart';
import '../domain/private_room.dart';
import 'private_room_screen.dart';
import 'social_copy.dart';

class RoomHubScreen extends StatefulWidget {
  const RoomHubScreen({
    super.key,
    required this.profile,
    required this.roomBackend,
    required this.socialBackend,
    required this.socialMatchBackend,
  });

  final PlayerProfile profile;
  final RoomBackend roomBackend;
  final SocialBackend socialBackend;
  final SocialMatchBackend socialMatchBackend;

  @override
  State<RoomHubScreen> createState() => _RoomHubScreenState();
}

class _RoomHubScreenState extends State<RoomHubScreen> {
  final _roomCodeController = TextEditingController();
  bool _busy = false;
  String? _error;

  static const _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  @override
  void dispose() {
    _roomCodeController.dispose();
    super.dispose();
  }

  String _newCode() {
    final random = Random.secure();
    return List.generate(
      5,
      (_) => _alphabet[random.nextInt(_alphabet.length)],
    ).join();
  }

  Future<void> _create(int maxPlayers) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      PrivateRoom? room;
      for (var attempt = 0; attempt < 5 && room == null; attempt++) {
        try {
          room = await widget.roomBackend.createRoom(
            hostUid: widget.profile.uid,
            maxPlayers: maxPlayers,
            roomCode: _newCode(),
          );
        } catch (_) {
          if (attempt == 4) rethrow;
        }
      }
      if (!mounted || room == null) return;
      await _openRoom(room);
    } catch (_) {
      if (mounted) setState(() => _error = SocialCopy.of(context).socialError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _join() async {
    if (_busy) return;
    final copy = SocialCopy.of(context);
    final code = _roomCodeController.text.trim().toUpperCase();
    if (!PrivateRoomPolicy.validCode(code)) {
      setState(() => _error = copy.invalidRoomCode);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final room = await widget.roomBackend.findRoomByCode(code);
      if (room == null) {
        if (mounted) setState(() => _error = copy.roomNotFound);
        return;
      }
      await widget.roomBackend.joinRoom(
        roomId: room.id,
        uid: widget.profile.uid,
      );
      if (!mounted) return;
      await _openRoom(room);
    } catch (_) {
      if (mounted) setState(() => _error = copy.socialError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openRoom(PrivateRoom room) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PrivateRoomScreen(
          initialRoom: room,
          profile: widget.profile,
          roomBackend: widget.roomBackend,
          socialBackend: widget.socialBackend,
          socialMatchBackend: widget.socialMatchBackend,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final copy = SocialCopy.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          copy.playWithFriends,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(GameSpacing.md),
          children: [
            Container(
              padding: const EdgeInsets.all(GameSpacing.lg),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(GameRadii.panel),
                gradient: const LinearGradient(
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                  colors: [GameColors.surfaceRaised, GameColors.surface],
                ),
                border: Border.all(
                  color: GameColors.accent.withValues(alpha: 0.28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.groups_2_rounded,
                    size: 42,
                    color: GameColors.accent,
                  ),
                  const SizedBox(height: GameSpacing.sm),
                  Text(
                    copy.privateRoom,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: GameSpacing.xs),
                  Text(
                    copy.roomRule,
                    style: const TextStyle(color: GameColors.muted),
                  ),
                  const SizedBox(height: GameSpacing.xs),
                  Text(
                    copy.roomNoRankedRp,
                    style: const TextStyle(
                      color: GameColors.rewardGold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GameSpacing.lg),
            Text(
              copy.createRoom,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: GameSpacing.sm),
            Row(
              children: [
                for (final entry in <(int, String)>[
                  (2, copy.players2),
                  (4, copy.players4),
                  (6, copy.players6),
                ]) ...[
                  Expanded(
                    child: _PlayerCountButton(
                      count: entry.$1,
                      label: entry.$2,
                      busy: _busy,
                      onPressed: () => _create(entry.$1),
                    ),
                  ),
                  if (entry.$1 != 6)
                    const SizedBox(width: GameSpacing.sm),
                ],
              ],
            ),
            const SizedBox(height: GameSpacing.xl),
            Text(
              copy.joinRoom,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: GameSpacing.sm),
            Container(
              padding: const EdgeInsets.all(GameSpacing.md),
              decoration: BoxDecoration(
                color: GameColors.surface,
                borderRadius: BorderRadius.circular(GameRadii.card),
                border: Border.all(color: GameColors.surfaceStrong),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _roomCodeController,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 5,
                    decoration: InputDecoration(
                      hintText: copy.enterRoomCode,
                      prefixIcon: const Icon(Icons.key_rounded),
                    ),
                    onSubmitted: (_) => _join(),
                  ),
                  const SizedBox(height: GameSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _busy ? null : _join,
                      icon: const Icon(Icons.login_rounded),
                      label: Text(_busy ? copy.joiningRoom : copy.joinRoom),
                    ),
                  ),
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: GameSpacing.sm),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: GameColors.danger),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlayerCountButton extends StatelessWidget {
  const _PlayerCountButton({
    required this.count,
    required this.label,
    required this.busy,
    required this.onPressed,
  });

  final int count;
  final String label;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: busy ? null : onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: GameSpacing.md),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            count == 2
                ? Icons.people_rounded
                : count == 4
                    ? Icons.groups_rounded
                    : Icons.groups_2_rounded,
          ),
          const SizedBox(height: GameSpacing.xs),
          Text(label),
        ],
      ),
    );
  }
}
