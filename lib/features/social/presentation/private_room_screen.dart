import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/design_tokens.dart';
import '../../match/data/social_match_backend.dart';
import '../../match/domain/match_progress.dart';
import '../../match/domain/multiplayer_match.dart';
import '../../match/presentation/social_match_play_screen.dart';
import '../../profile/domain/player_profile.dart';
import '../data/room_backend.dart';
import '../data/social_backend.dart';
import '../domain/private_room.dart';
import '../domain/social_player_summary.dart';
import 'social_copy.dart';

class PrivateRoomScreen extends StatefulWidget {
  const PrivateRoomScreen({
    super.key,
    required this.initialRoom,
    required this.profile,
    required this.roomBackend,
    required this.socialBackend,
    required this.socialMatchBackend,
  });

  final PrivateRoom initialRoom;
  final PlayerProfile profile;
  final RoomBackend roomBackend;
  final SocialBackend socialBackend;
  final SocialMatchBackend socialMatchBackend;

  @override
  State<PrivateRoomScreen> createState() => _PrivateRoomScreenState();
}

class _PrivateRoomScreenState extends State<PrivateRoomScreen> {
  bool _busy = false;
  bool _openedMatch = false;
  String? _error;

  Future<void> _copyInvite(PrivateRoom room) async {
    final uri = RoomInvitePolicy.buildUri(room.code);
    await Clipboard.setData(ClipboardData(text: uri.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(SocialCopy.of(context).inviteCopied)),
    );
  }

  Future<void> _toggleReady(PrivateRoom room) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.roomBackend.setReady(
        roomId: room.id,
        uid: widget.profile.uid,
        ready: !room.isReady(widget.profile.uid),
      );
    } catch (_) {
      if (mounted) setState(() => _error = SocialCopy.of(context).socialError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _start(PrivateRoom room) async {
    if (_busy || !room.canStart || room.hostUid != widget.profile.uid) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final participants = <MatchParticipant>[];
      for (final uid in room.participantUids) {
        final summary = await widget.socialBackend.loadPlayerSummary(uid);
        participants.add(
          MatchParticipant(
            uid: uid,
            displayName: summary?.displayName ??
                (uid == widget.profile.uid ? widget.profile.gameName : 'Player'),
            avatarId: summary?.avatarId,
            isReady: true,
            progress: const MatchProgress.empty(),
          ),
        );
      }

      await widget.socialMatchBackend.createMatch(
        roomId: room.id,
        roomCode: room.code,
        hostUid: room.hostUid,
        maxPlayers: room.maxPlayers,
        participants: participants,
      );
      await widget.roomBackend.startRoom(
        roomId: room.id,
        hostUid: widget.profile.uid,
      );
    } catch (_) {
      if (mounted) setState(() => _error = SocialCopy.of(context).socialError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openMatch(String matchId) async {
    if (_openedMatch || !mounted) return;
    _openedMatch = true;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => SocialMatchPlayScreen(
          matchId: matchId,
          uid: widget.profile.uid,
          matchBackend: widget.socialMatchBackend,
        ),
      ),
    );
  }

  Future<void> _leave(PrivateRoom room) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (room.hostUid == widget.profile.uid) {
        await widget.roomBackend.cancelRoom(
          roomId: room.id,
          hostUid: widget.profile.uid,
        );
      } else {
        await widget.roomBackend.leaveRoom(
          roomId: room.id,
          uid: widget.profile.uid,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _error = SocialCopy.of(context).socialError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final copy = SocialCopy.of(context);
    return StreamBuilder<PrivateRoom?>(
      stream: widget.roomBackend.watchRoom(widget.initialRoom.id),
      initialData: widget.initialRoom,
      builder: (context, snapshot) {
        final room = snapshot.data;
        if (room == null) {
          return Scaffold(
            appBar: AppBar(title: Text(copy.privateRoom)),
            body: Center(child: Text(copy.roomNotFound)),
          );
        }

        if ((room.status == PrivateRoomStatus.countdown ||
                room.status == PrivateRoomStatus.playing) &&
            !_openedMatch) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _openMatch(room.id);
          });
        }

        if (room.status == PrivateRoomStatus.cancelled) {
          return Scaffold(
            appBar: AppBar(title: Text(copy.privateRoom)),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(GameSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cancel_outlined,
                      size: 56,
                      color: GameColors.danger,
                    ),
                    const SizedBox(height: GameSpacing.md),
                    Text(copy.roomCancelled),
                    const SizedBox(height: GameSpacing.md),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(MaterialLocalizations.of(context).backButtonTooltip),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final isHost = room.hostUid == widget.profile.uid;
        final isReady = room.isReady(widget.profile.uid);
        final waitingCount = room.maxPlayers - room.participantUids.length;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              copy.privateRoom,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            actions: [
              IconButton(
                onPressed: () => _copyInvite(room),
                tooltip: copy.shareRoom,
                icon: const Icon(Icons.ios_share_rounded),
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(GameSpacing.md),
              children: [
                _RoomHeader(room: room, copy: copy),
                const SizedBox(height: GameSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        room.isFull
                            ? copy.roomFull
                            : '${copy.waitingPlayers} • $waitingCount',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                    Text(
                      '${room.participantUids.length}/${room.maxPlayers}',
                      style: const TextStyle(
                        color: GameColors.accent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: GameSpacing.sm),
                for (var i = 0; i < room.maxPlayers; i++) ...[
                  if (i < room.participantUids.length)
                    _ParticipantTile(
                      uid: room.participantUids[i],
                      isHost: room.hostUid == room.participantUids[i],
                      isSelf: room.participantUids[i] == widget.profile.uid,
                      isReady: room.readyUids.contains(room.participantUids[i]),
                      socialBackend: widget.socialBackend,
                      copy: copy,
                    )
                  else
                    _EmptyParticipantSlot(index: i + 1, copy: copy),
                  const SizedBox(height: GameSpacing.sm),
                ],
                if (_error != null) ...[
                  const SizedBox(height: GameSpacing.xs),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: GameColors.danger),
                  ),
                ],
                const SizedBox(height: GameSpacing.md),
                if (room.status == PrivateRoomStatus.lobby) ...[
                  FilledButton.icon(
                    onPressed: _busy ? null : () => _toggleReady(room),
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          isReady ? GameColors.success : GameColors.accent,
                      foregroundColor: GameColors.background,
                      padding: const EdgeInsets.symmetric(
                        vertical: GameSpacing.md,
                      ),
                    ),
                    icon: Icon(
                      isReady
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                    ),
                    label: Text(isReady ? copy.ready : copy.notReady),
                  ),
                  if (isHost) ...[
                    const SizedBox(height: GameSpacing.sm),
                    FilledButton.icon(
                      onPressed:
                          _busy || !room.canStart ? null : () => _start(room),
                      icon: const Icon(Icons.bolt_rounded),
                      label: Text(copy.startMatch),
                    ),
                    if (!room.canStart) ...[
                      const SizedBox(height: GameSpacing.xs),
                      Text(
                        copy.everyoneMustBeReady,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: GameColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(GameSpacing.lg),
                    decoration: BoxDecoration(
                      color: GameColors.accentSoft,
                      borderRadius: BorderRadius.circular(GameRadii.panel),
                      border: Border.all(
                        color: GameColors.accent.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: GameSpacing.md),
                        Text(
                          copy.matchStarting,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: GameSpacing.sm),
                if (room.status == PrivateRoomStatus.lobby)
                  TextButton.icon(
                    onPressed: _busy ? null : () => _leave(room),
                    icon: const Icon(Icons.logout_rounded),
                    label: Text(isHost ? copy.cancelRoom : copy.leaveRoom),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RoomHeader extends StatelessWidget {
  const _RoomHeader({required this.room, required this.copy});

  final PrivateRoom room;
  final SocialCopy copy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(GameSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(GameRadii.panel),
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [GameColors.surfaceRaised, GameColors.surface],
        ),
        border: Border.all(color: GameColors.surfaceStrong),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: GameColors.accentSoft,
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.groups_2_rounded,
              color: GameColors.accent,
              size: 30,
            ),
          ),
          const SizedBox(width: GameSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  copy.roomCode,
                  style: const TextStyle(
                    color: GameColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  room.code,
                  style: const TextStyle(
                    fontSize: 26,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${room.maxPlayers} • ${copy.roomNoRankedRp}',
                  style: const TextStyle(
                    color: GameColors.rewardGold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  const _ParticipantTile({
    required this.uid,
    required this.isHost,
    required this.isSelf,
    required this.isReady,
    required this.socialBackend,
    required this.copy,
  });

  final String uid;
  final bool isHost;
  final bool isSelf;
  final bool isReady;
  final SocialBackend socialBackend;
  final SocialCopy copy;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SocialPlayerSummary?>(
      future: socialBackend.loadPlayerSummary(uid),
      builder: (context, snapshot) {
        final player = snapshot.data;
        return Container(
          padding: const EdgeInsets.all(GameSpacing.sm),
          decoration: BoxDecoration(
            color: GameColors.surface,
            borderRadius: BorderRadius.circular(GameRadii.card),
            border: Border.all(
              color: isReady
                  ? GameColors.success.withValues(alpha: 0.45)
                  : GameColors.surfaceStrong,
            ),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: GameColors.accentSoft,
                child: Icon(Icons.person_rounded, color: GameColors.accent),
              ),
              const SizedBox(width: GameSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player?.displayName ?? '…',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Wrap(
                      spacing: GameSpacing.xs,
                      children: [
                        if (isSelf)
                          Text(
                            copy.you,
                            style: const TextStyle(
                              color: GameColors.accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        if (isHost)
                          Text(
                            copy.host,
                            style: const TextStyle(
                              color: GameColors.rewardGold,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                isReady
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: isReady ? GameColors.success : GameColors.muted,
              ),
              const SizedBox(width: GameSpacing.xs),
              Text(
                isReady ? copy.ready : copy.notReady,
                style: TextStyle(
                  color: isReady ? GameColors.success : GameColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyParticipantSlot extends StatelessWidget {
  const _EmptyParticipantSlot({required this.index, required this.copy});

  final int index;
  final SocialCopy copy;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: GameSpacing.md),
      decoration: BoxDecoration(
        color: GameColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(GameRadii.card),
        border: Border.all(color: GameColors.surfaceStrong),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline_rounded, color: GameColors.muted),
          const SizedBox(width: GameSpacing.sm),
          Expanded(
            child: Text(
              '${copy.waitingPlayers} #$index',
              style: const TextStyle(color: GameColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}
