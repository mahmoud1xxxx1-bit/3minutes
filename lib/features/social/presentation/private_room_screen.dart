import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/platform/room_invite_service.dart';
import '../../../core/theme/cosmic_background.dart';
import '../../../core/theme/design_tokens.dart';
import '../../economy/data/cosmetic_loadout_repository.dart';
import '../../economy/domain/cosmetic_loadout.dart';
import '../../economy/presentation/cosmetic_runtime.dart';
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
  late final CosmeticLoadoutRepository _loadouts;

  @override
  void initState() {
    super.initState();
    _loadouts = CosmeticLoadoutRepository();
  }

  Future<void> _shareInvite(PrivateRoom room) async {
    final uri = RoomInvitePolicy.buildUri(room.code);
    final shared = await RoomInviteService.shareRoomInvite(uri.toString());
    if (shared || !mounted) return;
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
            backgroundColor: Colors.transparent,
            appBar: AppBar(backgroundColor: Colors.transparent, title: Text(copy.privateRoom)),
            body: CosmicBackground(child: Center(child: Text(copy.roomNotFound))),
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
            backgroundColor: Colors.transparent,
            appBar: AppBar(backgroundColor: Colors.transparent, title: Text(copy.privateRoom)),
            body: CosmicBackground(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(GameSpacing.lg),
                  child: CosmicPanel(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cancel_outlined, size: 56, color: GameColors.danger),
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
              ),
            ),
          );
        }

        final isHost = room.hostUid == widget.profile.uid;
        final isReady = room.isReady(widget.profile.uid);
        final waitingCount = room.maxPlayers - room.participantUids.length;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(copy.privateRoom, style: const TextStyle(fontWeight: FontWeight.w900)),
            actions: [
              IconButton(
                onPressed: () => _shareInvite(room),
                tooltip: copy.shareRoom,
                icon: const Icon(Icons.ios_share_rounded),
              ),
            ],
          ),
          body: StreamBuilder<CosmeticLoadout>(
            stream: _loadouts.watch(room.hostUid),
            initialData: const CosmeticLoadout(),
            builder: (context, loadoutSnapshot) {
              final hostLoadout = loadoutSnapshot.data ?? const CosmeticLoadout();
              return CosmicBackground(
                child: CosmeticRoomTheme(
                  themeId: hostLoadout.roomThemeId,
                  borderRadius: 0,
                  child: SafeArea(
                    top: false,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                        GameSpacing.md,
                        GameSpacing.sm,
                        GameSpacing.md,
                        110,
                      ),
                      children: [
                        _RoomHeader(
                          room: room,
                          copy: copy,
                          themeId: hostLoadout.roomThemeId,
                        ),
                        const SizedBox(height: GameSpacing.lg),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                room.isFull
                                    ? copy.roomFull
                                    : '${copy.waitingPlayers} • $waitingCount',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: GameSpacing.sm,
                                vertical: GameSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: GameColors.accentSoft,
                                borderRadius: BorderRadius.circular(GameRadii.pill),
                              ),
                              child: Text(
                                '${room.participantUids.length}/${room.maxPlayers}',
                                style: const TextStyle(
                                  color: GameColors.accentBright,
                                  fontWeight: FontWeight.w900,
                                ),
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
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: isReady ? null : GameColors.cosmicGradient,
                              color: isReady ? GameColors.success : null,
                              borderRadius: BorderRadius.circular(GameRadii.button),
                              boxShadow: isReady ? null : GameShadows.primaryGlow,
                            ),
                            child: FilledButton.icon(
                              onPressed: _busy ? null : () => _toggleReady(room),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                disabledBackgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: GameColors.background,
                                padding: const EdgeInsets.symmetric(vertical: GameSpacing.md),
                              ),
                              icon: Icon(
                                isReady
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                              ),
                              label: Text(isReady ? copy.ready : copy.notReady),
                            ),
                          ),
                          if (isHost) ...[
                            const SizedBox(height: GameSpacing.sm),
                            CosmicPrimaryButton(
                              onPressed: _busy || !room.canStart ? null : () => _start(room),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.bolt_rounded),
                                  const SizedBox(width: GameSpacing.sm),
                                  Text(copy.startMatch),
                                ],
                              ),
                            ),
                            if (!room.canStart) ...[
                              const SizedBox(height: GameSpacing.xs),
                              Text(
                                copy.everyoneMustBeReady,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: GameColors.muted, fontSize: 12),
                              ),
                            ],
                          ],
                        ] else ...[
                          CosmicPanel(
                            glow: true,
                            padding: const EdgeInsets.all(GameSpacing.lg),
                            child: Column(
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: GameSpacing.md),
                                Text(copy.matchStarting, style: const TextStyle(fontWeight: FontWeight.w900)),
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
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _RoomHeader extends StatelessWidget {
  const _RoomHeader({
    required this.room,
    required this.copy,
    required this.themeId,
  });

  final PrivateRoom room;
  final SocialCopy copy;
  final String? themeId;

  @override
  Widget build(BuildContext context) {
    final themed = themeId != null;
    return CosmicPanel(
      glow: true,
      padding: const EdgeInsets.all(GameSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: themed
                  ? (themeId == 'room_cyber_royal'
                      ? const LinearGradient(colors: [GameColors.rewardGold, GameColors.violet])
                      : const LinearGradient(colors: [GameColors.accentBright, GameColors.cosmicPink]))
                  : GameColors.cosmicGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: GameShadows.primaryGlow,
            ),
            child: Icon(
              themeId == 'room_cyber_royal'
                  ? Icons.diamond_rounded
                  : themeId == 'room_arcade'
                      ? Icons.sports_esports_rounded
                      : Icons.groups_2_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: GameSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(copy.roomCode, style: const TextStyle(color: GameColors.muted, fontWeight: FontWeight.w700)),
                Text(room.code, style: const TextStyle(fontSize: 26, letterSpacing: 2, fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(
                  '${room.maxPlayers} • ${copy.roomNoRankedRp}',
                  style: const TextStyle(color: GameColors.rewardGold, fontSize: 12),
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
      builder: (context, summarySnapshot) {
        final player = summarySnapshot.data;
        return FutureBuilder<CosmeticLoadout>(
          future: CosmeticLoadoutRepository().load(uid),
          builder: (context, loadoutSnapshot) {
            final loadout = loadoutSnapshot.data ?? const CosmeticLoadout();
            final avatarId = loadout.avatarId ?? player?.avatarId ?? 'avatar_free_vanguard';
            return CosmicPanel(
              padding: const EdgeInsets.all(GameSpacing.sm),
              glow: isReady,
              child: Row(
                children: [
                  CosmeticAvatarView(
                    avatarId: avatarId,
                    frameId: loadout.avatarFrameId,
                    size: 46,
                  ),
                  const SizedBox(width: GameSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: CosmeticNameText(
                                text: player?.displayName ?? '…',
                                styleId: loadout.nameStyleId,
                                fontSize: 15,
                              ),
                            ),
                            if (loadout.badgeId != null)
                              CosmeticBadgeView(badgeId: loadout.badgeId!, size: 28),
                          ],
                        ),
                        Wrap(
                          spacing: GameSpacing.xs,
                          children: [
                            if (isSelf)
                              Text(copy.you, style: const TextStyle(color: GameColors.accentBright, fontSize: 11, fontWeight: FontWeight.w800)),
                            if (isHost)
                              Text(copy.host, style: const TextStyle(color: GameColors.rewardGold, fontSize: 11, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isReady ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
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
    return CosmicPanel(
      padding: const EdgeInsets.symmetric(horizontal: GameSpacing.md),
      child: SizedBox(
        height: 46,
        child: Row(
          children: [
            const Icon(Icons.person_outline_rounded, color: GameColors.muted),
            const SizedBox(width: GameSpacing.sm),
            Expanded(
              child: Text('${copy.waitingPlayers} #$index', style: const TextStyle(color: GameColors.muted)),
            ),
          ],
        ),
      ),
    );
  }
}
