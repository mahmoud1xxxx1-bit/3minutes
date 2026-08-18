import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/cosmic_background.dart';
import '../../../core/theme/design_tokens.dart';
import '../../match/data/social_match_backend.dart';
import '../../profile/domain/player_profile.dart';
import '../data/firestore_party_backend.dart';
import '../data/room_backend.dart';
import '../data/social_backend.dart';
import '../domain/private_room.dart';
import 'party_screen.dart';
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
  int _selectedPlayers = 4;

  static const _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  @override
  void dispose() {
    _roomCodeController.dispose();
    super.dispose();
  }

  String _newCode() {
    final random = Random.secure();
    return List.generate(5, (_) => _alphabet[random.nextInt(_alphabet.length)]).join();
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
      await widget.roomBackend.joinRoom(roomId: room.id, uid: widget.profile.uid);
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

  void _openParty() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PartyScreen(
          profile: widget.profile,
          partyBackend: FirestorePartyBackend(),
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(copy.playWithFriends)),
      body: CosmicBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              GameSpacing.md,
              GameSpacing.md,
              GameSpacing.md,
              GameSpacing.xl,
            ),
            children: [
              CosmicPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: GameColors.cosmicGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.groups_2_rounded,
                            color: GameColors.backgroundDeep,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: GameSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(copy.privateRoom, style: Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: 3),
                              Text(copy.roomRule, style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: GameSpacing.md),
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
              const SizedBox(height: GameSpacing.md),
              InkWell(
                onTap: _openParty,
                borderRadius: BorderRadius.circular(GameRadii.card),
                child: Ink(
                  padding: const EdgeInsets.all(GameSpacing.md),
                  decoration: BoxDecoration(
                    color: GameColors.surfaceGlass,
                    borderRadius: BorderRadius.circular(GameRadii.card),
                    border: Border.all(color: GameColors.violet.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.groups_3_rounded, color: GameColors.violet, size: 32),
                      const SizedBox(width: GameSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(copy.party, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                            const SizedBox(height: 3),
                            Text(copy.partySubtitle, style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: GameColors.muted),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: GameSpacing.lg),
              Text(copy.createRoom, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: GameSpacing.sm),
              CosmicPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        _PlayerCountChoice(
                          count: 2,
                          label: copy.players2,
                          selected: _selectedPlayers == 2,
                          onTap: _busy ? null : () => setState(() => _selectedPlayers = 2),
                        ),
                        const SizedBox(width: GameSpacing.sm),
                        _PlayerCountChoice(
                          count: 4,
                          label: copy.players4,
                          selected: _selectedPlayers == 4,
                          onTap: _busy ? null : () => setState(() => _selectedPlayers = 4),
                        ),
                        const SizedBox(width: GameSpacing.sm),
                        _PlayerCountChoice(
                          count: 6,
                          label: copy.players6,
                          selected: _selectedPlayers == 6,
                          onTap: _busy ? null : () => setState(() => _selectedPlayers = 6),
                        ),
                      ],
                    ),
                    const SizedBox(height: GameSpacing.md),
                    CosmicPrimaryButton(
                      onPressed: _busy ? null : () => _create(_selectedPlayers),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_busy)
                            const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            const Icon(Icons.add_rounded),
                          const SizedBox(width: GameSpacing.sm),
                          Text(copy.createRoom),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GameSpacing.lg),
              Text(copy.joinRoom, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: GameSpacing.sm),
              CosmicPanel(
                child: Column(
                  children: [
                    TextField(
                      controller: _roomCodeController,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 5,
                      decoration: InputDecoration(
                        hintText: copy.enterRoomCode,
                        prefixIcon: const Icon(Icons.key_rounded),
                        counterText: '',
                      ),
                      onSubmitted: (_) => _join(),
                    ),
                    const SizedBox(height: GameSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _busy ? null : _join,
                        icon: const Icon(Icons.login_rounded),
                        label: Text(_busy ? copy.joiningRoom : copy.joinRoom),
                      ),
                    ),
                  ],
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: GameSpacing.md),
                CosmicPanel(
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: GameColors.danger),
                      const SizedBox(width: GameSpacing.sm),
                      Expanded(
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: GameColors.danger),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerCountChoice extends StatelessWidget {
  const _PlayerCountChoice({
    required this.count,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final int count;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GameRadii.card),
        child: AnimatedContainer(
          duration: GameDurations.normal,
          padding: const EdgeInsets.symmetric(vertical: GameSpacing.md),
          decoration: BoxDecoration(
            color: selected ? GameColors.accentSoft : GameColors.surfaceRaised,
            borderRadius: BorderRadius.circular(GameRadii.card),
            border: Border.all(
              color: selected ? GameColors.accentBright : GameColors.surfaceStrong,
              width: selected ? 1.4 : 0.8,
            ),
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
                color: selected ? GameColors.accentBright : GameColors.textSoft,
              ),
              const SizedBox(height: GameSpacing.xs),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? GameColors.textStrong : GameColors.textSoft,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
