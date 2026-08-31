import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/cosmic_background.dart';
import '../../../core/theme/design_tokens.dart';
import '../../competition/domain/rank_tier.dart';
import '../../competition/presentation/rank_badge.dart';
import '../../economy/presentation/cosmetic_runtime.dart';
import '../../match/data/social_match_backend.dart';
import '../../profile/domain/player_profile.dart';
import '../data/party_backend.dart';
import '../data/room_backend.dart';
import '../data/social_backend.dart';
import '../domain/friendship.dart';
import '../domain/party.dart';
import '../domain/private_room.dart';
import '../domain/social_player_summary.dart';
import 'private_room_screen.dart';
import 'social_copy.dart';

class PartyScreen extends StatefulWidget {
  const PartyScreen({
    super.key,
    required this.profile,
    required this.partyBackend,
    required this.roomBackend,
    required this.socialBackend,
    required this.socialMatchBackend,
  });

  final PlayerProfile profile;
  final PartyBackend partyBackend;
  final RoomBackend roomBackend;
  final SocialBackend socialBackend;
  final SocialMatchBackend socialMatchBackend;

  @override
  State<PartyScreen> createState() => _PartyScreenState();
}

class _PartyScreenState extends State<PartyScreen> {
  static const _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  bool _busy = false;
  String? _error;
  String? _lastOpenedRoomId;

  String _newRoomCode() {
    final random = Random.secure();
    return List.generate(
      5,
      (_) => _alphabet[random.nextInt(_alphabet.length)],
    ).join();
  }

  Future<void> _createParty() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.partyBackend.createParty(leaderUid: widget.profile.uid);
    } catch (_) {
      if (mounted) setState(() => _error = SocialCopy.of(context).socialError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _launchPartyRoom(Party party) async {
    if (_busy || !PartyPolicy.canStartMatch(party)) return;
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
            maxPlayers: party.size,
            roomCode: _newRoomCode(),
          );
        } catch (_) {
          if (attempt == 4) rethrow;
        }
      }
      if (room == null) return;
      await widget.partyBackend.setActiveRoom(
        partyId: party.id,
        leaderUid: widget.profile.uid,
        roomId: room.id,
      );
    } catch (_) {
      if (mounted) setState(() => _error = SocialCopy.of(context).socialError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openActiveRoom(Party party) async {
    final roomId = party.activeRoomId;
    if (roomId == null || roomId == _lastOpenedRoomId || _busy) return;
    _lastOpenedRoomId = roomId;
    try {
      await widget.roomBackend.joinRoom(
        roomId: roomId,
        uid: widget.profile.uid,
      );
      final room = await widget.roomBackend
          .watchRoom(roomId)
          .firstWhere((value) => value != null);
      if (!mounted || room == null) return;
      await Navigator.of(context).push(
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
      if (mounted && party.leaderUid == widget.profile.uid) {
        await widget.partyBackend.setActiveRoom(
          partyId: party.id,
          leaderUid: widget.profile.uid,
          roomId: null,
        );
      }
    } catch (_) {
      if (mounted) setState(() => _error = SocialCopy.of(context).socialError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final copy = SocialCopy.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          copy.party,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: CosmicBackground(
        child: SafeArea(
          top: false,
          child: StreamBuilder<Party?>(
            stream: widget.partyBackend.watchMembership(widget.profile.uid),
            builder: (context, membershipSnapshot) {
              final party = membershipSnapshot.data;
              if (membershipSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (party != null) {
                if (party.activeRoomId != null &&
                    party.activeRoomId != _lastOpenedRoomId) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _openActiveRoom(party);
                  });
                }
                return _PartyLobby(
                  party: party,
                  profile: widget.profile,
                  partyBackend: widget.partyBackend,
                  socialBackend: widget.socialBackend,
                  copy: copy,
                  busy: _busy,
                  error: _error,
                  onStart: () => _launchPartyRoom(party),
                );
              }
              return _NoPartyView(
                uid: widget.profile.uid,
                partyBackend: widget.partyBackend,
                socialBackend: widget.socialBackend,
                copy: copy,
                busy: _busy,
                error: _error,
                onCreate: _createParty,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NoPartyView extends StatelessWidget {
  const _NoPartyView({
    required this.uid,
    required this.partyBackend,
    required this.socialBackend,
    required this.copy,
    required this.busy,
    required this.error,
    required this.onCreate,
  });

  final String uid;
  final PartyBackend partyBackend;
  final SocialBackend socialBackend;
  final SocialCopy copy;
  final bool busy;
  final String? error;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        GameSpacing.md,
        GameSpacing.sm,
        GameSpacing.md,
        110,
      ),
      children: [
        _PartyHero(copy: copy),
        const SizedBox(height: GameSpacing.md),
        CosmicPrimaryButton(
          onPressed: busy ? null : onCreate,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.group_add_rounded),
              const SizedBox(width: GameSpacing.sm),
              Text(copy.createParty),
            ],
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: GameSpacing.sm),
          _ErrorText(error!),
        ],
        const SizedBox(height: GameSpacing.xl),
        Text(copy.partyInvitations, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: GameSpacing.sm),
        StreamBuilder<List<Party>>(
          stream: partyBackend.watchInvitations(uid),
          builder: (context, snapshot) {
            final invites = snapshot.data ?? const <Party>[];
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (invites.isEmpty) {
              return _EmptyCard(label: copy.noPartyInvites);
            }
            return Column(
              children: [
                for (final party in invites) ...[
                  _PartyInviteCard(
                    party: party,
                    uid: uid,
                    partyBackend: partyBackend,
                    socialBackend: socialBackend,
                    copy: copy,
                  ),
                  const SizedBox(height: GameSpacing.sm),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PartyLobby extends StatelessWidget {
  const _PartyLobby({
    required this.party,
    required this.profile,
    required this.partyBackend,
    required this.socialBackend,
    required this.copy,
    required this.busy,
    required this.error,
    required this.onStart,
  });

  final Party party;
  final PlayerProfile profile;
  final PartyBackend partyBackend;
  final SocialBackend socialBackend;
  final SocialCopy copy;
  final bool busy;
  final String? error;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final isLeader = party.leaderUid == profile.uid;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        GameSpacing.md,
        GameSpacing.sm,
        GameSpacing.md,
        110,
      ),
      children: [
        _PartyHero(copy: copy),
        const SizedBox(height: GameSpacing.md),
        Row(
          children: [
            Expanded(
              child: _Metric(label: copy.partyMembers, value: '${party.size}/6'),
            ),
            const SizedBox(width: GameSpacing.sm),
            Expanded(
              child: _Metric(
                label: copy.partyLeader,
                value: isLeader ? copy.you : '★',
              ),
            ),
          ],
        ),
        const SizedBox(height: GameSpacing.lg),
        Text(copy.partyMembers, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: GameSpacing.sm),
        for (final uid in party.memberUids) ...[
          _PartyMemberCard(
            uid: uid,
            isLeader: uid == party.leaderUid,
            isSelf: uid == profile.uid,
            canRemove: isLeader && uid != profile.uid,
            socialBackend: socialBackend,
            copy: copy,
            onRemove: () => partyBackend.removeMember(
              partyId: party.id,
              leaderUid: profile.uid,
              memberUid: uid,
            ),
          ),
          const SizedBox(height: GameSpacing.sm),
        ],
        if (isLeader && party.size < PartyPolicy.maxMembers) ...[
          const SizedBox(height: GameSpacing.md),
          Text(copy.inviteFriends, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: GameSpacing.sm),
          _FriendInviteList(
            party: party,
            uid: profile.uid,
            partyBackend: partyBackend,
            socialBackend: socialBackend,
            copy: copy,
          ),
        ],
        const SizedBox(height: GameSpacing.lg),
        CosmicPanel(
          child: Text(
            PartyPolicy.canStartMatch(party) ? copy.roomRule : copy.partyWaitingSize,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: PartyPolicy.canStartMatch(party)
                  ? GameColors.success
                  : GameColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: GameSpacing.sm),
        if (isLeader)
          CosmicPrimaryButton(
            onPressed: busy || !PartyPolicy.canStartMatch(party) ? null : onStart,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_arrow_rounded),
                const SizedBox(width: GameSpacing.sm),
                Text(copy.startPartyMatch),
              ],
            ),
          ),
        const SizedBox(height: GameSpacing.sm),
        OutlinedButton.icon(
          onPressed: busy
              ? null
              : () => partyBackend.leaveParty(
                    partyId: party.id,
                    uid: profile.uid,
                  ),
          icon: const Icon(Icons.logout_rounded),
          label: Text(copy.leaveParty),
        ),
        if (error != null) ...[
          const SizedBox(height: GameSpacing.sm),
          _ErrorText(error!),
        ],
      ],
    );
  }
}

class _FriendInviteList extends StatelessWidget {
  const _FriendInviteList({
    required this.party,
    required this.uid,
    required this.partyBackend,
    required this.socialBackend,
    required this.copy,
  });

  final Party party;
  final String uid;
  final PartyBackend partyBackend;
  final SocialBackend socialBackend;
  final SocialCopy copy;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Friendship>>(
      stream: socialBackend.watchFriendships(uid),
      builder: (context, snapshot) {
        final accepted = (snapshot.data ?? const <Friendship>[])
            .where((item) => item.status == FriendshipStatus.accepted)
            .map((item) =>
                item.requesterUid == uid ? item.recipientUid : item.requesterUid)
            .where((friendUid) => !party.memberUids.contains(friendUid))
            .toSet()
            .toList(growable: false);
        if (accepted.isEmpty) return _EmptyCard(label: copy.noFriendsYet);
        return Column(
          children: [
            for (final friendUid in accepted) ...[
              FutureBuilder<SocialPlayerSummary?>(
                future: socialBackend.loadPlayerSummary(friendUid),
                builder: (context, playerSnapshot) {
                  final player = playerSnapshot.data;
                  if (player == null) return const SizedBox.shrink();
                  final pending = party.pendingInviteUids.contains(friendUid);
                  return PartyPlayerIdentityCard(
                    player: player,
                    trailing: TextButton.icon(
                      onPressed: pending
                          ? null
                          : () => partyBackend.inviteMember(
                                partyId: party.id,
                                leaderUid: uid,
                                invitedUid: friendUid,
                              ),
                      icon: Icon(
                        pending
                            ? Icons.schedule_rounded
                            : Icons.person_add_alt_1_rounded,
                      ),
                      label: Text(pending ? copy.invited : copy.invite),
                    ),
                  );
                },
              ),
              const SizedBox(height: GameSpacing.xs),
            ],
          ],
        );
      },
    );
  }
}

class _PartyInviteCard extends StatelessWidget {
  const _PartyInviteCard({
    required this.party,
    required this.uid,
    required this.partyBackend,
    required this.socialBackend,
    required this.copy,
  });

  final Party party;
  final String uid;
  final PartyBackend partyBackend;
  final SocialBackend socialBackend;
  final SocialCopy copy;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SocialPlayerSummary?>(
      future: socialBackend.loadPlayerSummary(party.leaderUid),
      builder: (context, snapshot) {
        final leader = snapshot.data;
        return CosmicPanel(
          glow: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (leader != null)
                PartyPlayerIdentityCard(
                  player: leader,
                  subtitle: '${party.size}/6 • ${copy.party}',
                  trailing: const SizedBox.shrink(),
                  embedded: true,
                )
              else ...[
                Text(
                  copy.partyLeader,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  '${party.size}/6 • ${copy.party}',
                  style: const TextStyle(color: GameColors.muted),
                ),
              ],
              const SizedBox(height: GameSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () => partyBackend.acceptInvite(
                        partyId: party.id,
                        uid: uid,
                      ),
                      child: Text(copy.accept),
                    ),
                  ),
                  const SizedBox(width: GameSpacing.sm),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => partyBackend.declineInvite(
                        partyId: party.id,
                        uid: uid,
                      ),
                      child: Text(copy.decline),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PartyMemberCard extends StatelessWidget {
  const _PartyMemberCard({
    required this.uid,
    required this.isLeader,
    required this.isSelf,
    required this.canRemove,
    required this.socialBackend,
    required this.copy,
    required this.onRemove,
  });

  final String uid;
  final bool isLeader;
  final bool isSelf;
  final bool canRemove;
  final SocialBackend socialBackend;
  final SocialCopy copy;
  final Future<void> Function() onRemove;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SocialPlayerSummary?>(
      future: socialBackend.loadPlayerSummary(uid),
      builder: (context, snapshot) {
        final player = snapshot.data;
        if (player == null) {
          return const SizedBox(
            height: 58,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        return PartyPlayerIdentityCard(
          player: player,
          subtitle: [if (isLeader) copy.partyLeader, if (isSelf) copy.you]
              .join(' • '),
          trailing: canRemove
              ? IconButton(
                  tooltip: copy.removeFromParty,
                  onPressed: onRemove,
                  icon: const Icon(Icons.person_remove_rounded),
                )
              : Icon(
                  isLeader ? Icons.workspace_premium_rounded : Icons.circle,
                  color: isLeader ? GameColors.rewardGold : GameColors.muted,
                  size: 20,
                ),
        );
      },
    );
  }
}

class PartyPlayerIdentityCard extends StatelessWidget {
  const PartyPlayerIdentityCard({
    super.key,
    required this.player,
    required this.trailing,
    this.subtitle,
    this.embedded = false,
  });

  final SocialPlayerSummary player;
  final Widget trailing;
  final String? subtitle;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final tier = RankPolicy.tierFor(player.rankPoints);
    final content = Row(
      children: [
        CosmeticAvatarView(
          avatarId: player.avatarId,
          frameId: player.avatarFrameId,
          size: 48,
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
                      text: player.displayName,
                      styleId: player.nameStyleId,
                      fontSize: 15,
                    ),
                  ),
                  if (player.badgeId != null) ...[
                    const SizedBox(width: 5),
                    CosmeticBadgeView(badgeId: player.badgeId!, size: 28),
                  ],
                ],
              ),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: GameColors.muted,
                    fontSize: 11,
                  ),
                ),
              ],
              const SizedBox(height: 5),
              Wrap(
                spacing: GameSpacing.xs,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  CosmeticRankAura(
                    auraId: player.rankAuraId,
                    padding: player.rankAuraId == null ? 0 : 2,
                    child: RankBadge(
                      tier: tier,
                      compact: true,
                      legendarySeasons: player.legendarySeasons,
                    ),
                  ),
                  Text(
                    'Lv ${player.level}',
                    style: const TextStyle(
                      color: GameColors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '★ ${player.stars}',
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
        const SizedBox(width: GameSpacing.sm),
        trailing,
      ],
    );

    if (embedded) return content;
    return CosmicPanel(
      padding: const EdgeInsets.all(GameSpacing.sm),
      child: content,
    );
  }
}

class _PartyHero extends StatelessWidget {
  const _PartyHero({required this.copy});
  final SocialCopy copy;

  @override
  Widget build(BuildContext context) {
    return CosmicPanel(
      glow: true,
      padding: const EdgeInsets.all(GameSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: GameColors.cosmicGradient,
              borderRadius: BorderRadius.circular(19),
              boxShadow: GameShadows.primaryGlow,
            ),
            child: const Icon(
              Icons.groups_3_rounded,
              size: 34,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: GameSpacing.sm),
          Text(copy.party, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: GameSpacing.xs),
          Text(
            copy.partySubtitle,
            style: const TextStyle(color: GameColors.muted),
          ),
          const SizedBox(height: GameSpacing.xs),
          Text(
            copy.partySizeRule,
            style: const TextStyle(
              color: GameColors.rewardGold,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return CosmicPanel(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: GameColors.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return CosmicPanel(
      padding: const EdgeInsets.all(GameSpacing.lg),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(color: GameColors.muted),
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(color: GameColors.danger),
    );
  }
}
