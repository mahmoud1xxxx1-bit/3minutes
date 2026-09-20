import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/cosmic_background.dart';
import '../../../core/theme/design_tokens.dart';
import '../../competition/domain/rank_tier.dart';
import '../../competition/presentation/rank_badge.dart';
import '../../economy/presentation/cosmetic_runtime.dart';
import '../../profile/domain/player_profile.dart';
import '../data/social_backend.dart';
import '../domain/friendship.dart';
import '../domain/player_friend_code.dart';
import '../domain/social_player_summary.dart';
import 'social_copy.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({
    super.key,
    required this.profile,
    required this.socialBackend,
  });

  final PlayerProfile profile;
  final SocialBackend socialBackend;

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  late final TextEditingController _searchController;
  late final String _friendCode;
  SocialPlayerSummary? _searchResult;
  bool _searching = false;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _friendCode = widget.profile.friendCode ??
        PlayerFriendCodePolicy.forPlayer(
          uid: widget.profile.uid,
          name: widget.profile.gameName,
        );
    _ensureCode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _ensureCode() async {
    final copy = SocialCopy.of(context);
    try {
      await widget.socialBackend.ensureFriendCode(
        PlayerFriendCode(uid: widget.profile.uid, code: _friendCode),
      );
    } catch (_) {
      if (mounted) setState(() => _error = copy.socialError);
    }
  }

  Future<void> _search() async {
    final copy = SocialCopy.of(context);
    final code = _searchController.text.trim().toUpperCase();
    if (!PlayerFriendCodePolicy.isValid(code)) {
      setState(() {
        _searchResult = null;
        _error = copy.invalidFriendCode;
      });
      return;
    }

    setState(() {
      _searching = true;
      _searchResult = null;
      _error = null;
    });
    try {
      final friendCode = await widget.socialBackend.findByFriendCode(code);
      if (friendCode == null || friendCode.uid == widget.profile.uid) {
        if (mounted) setState(() => _error = copy.playerNotFound);
        return;
      }
      final player = await widget.socialBackend.loadPlayerSummary(friendCode.uid);
      if (!mounted) return;
      setState(() {
        _searchResult = player;
        if (player == null) _error = copy.playerNotFound;
      });
    } catch (_) {
      if (mounted) setState(() => _error = copy.socialError);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _sendRequest(SocialPlayerSummary player) async {
    if (_sending) return;
    final copy = SocialCopy.of(context);
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await widget.socialBackend.sendFriendRequest(
        requesterUid: widget.profile.uid,
        recipientUid: player.uid,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(copy.requestSent)),
      );
    } catch (_) {
      if (mounted) setState(() => _error = copy.socialError);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _copyFriendCode() async {
    await Clipboard.setData(ClipboardData(text: _friendCode));
    if (!mounted) return;
    final copy = SocialCopy.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${copy.copyCode}: $_friendCode')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final copy = SocialCopy.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(copy.friends, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: CosmicBackground(
        child: SafeArea(
          top: false,
          child: StreamBuilder<List<Friendship>>(
            stream: widget.socialBackend.watchFriendships(widget.profile.uid),
            builder: (context, snapshot) {
              final friendships = snapshot.data ?? const <Friendship>[];
              final incoming = friendships
                  .where((item) =>
                      item.status == FriendshipStatus.pending &&
                      item.recipientUid == widget.profile.uid)
                  .toList(growable: false);
              final accepted = friendships
                  .where((item) => item.status == FriendshipStatus.accepted)
                  .toList(growable: false);

              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  GameSpacing.md,
                  GameSpacing.sm,
                  GameSpacing.md,
                  110,
                ),
                children: [
                  _HeroCard(code: _friendCode, copy: copy, onCopy: _copyFriendCode),
                  const SizedBox(height: GameSpacing.md),
                  _SearchCard(
                    controller: _searchController,
                    searching: _searching,
                    result: _searchResult,
                    error: _error,
                    copy: copy,
                    onSearch: _search,
                    onSend: _sendRequest,
                    sending: _sending,
                  ),
                  const SizedBox(height: GameSpacing.lg),
                  _SectionTitle(title: copy.requests, count: incoming.length),
                  const SizedBox(height: GameSpacing.sm),
                  if (incoming.isEmpty)
                    _EmptyState(label: copy.noRequests)
                  else
                    for (final friendship in incoming) ...[
                      _FriendshipTile(
                        friendship: friendship,
                        otherUid: friendship.requesterUid,
                        actingUid: widget.profile.uid,
                        socialBackend: widget.socialBackend,
                        incoming: true,
                      ),
                      const SizedBox(height: GameSpacing.sm),
                    ],
                  const SizedBox(height: GameSpacing.lg),
                  _SectionTitle(title: copy.acceptedFriends, count: accepted.length),
                  const SizedBox(height: GameSpacing.sm),
                  if (accepted.isEmpty)
                    _EmptyState(label: copy.noFriendsYet)
                  else
                    for (final friendship in accepted) ...[
                      _FriendshipTile(
                        friendship: friendship,
                        otherUid: friendship.requesterUid == widget.profile.uid
                            ? friendship.recipientUid
                            : friendship.requesterUid,
                        actingUid: widget.profile.uid,
                        socialBackend: widget.socialBackend,
                        incoming: false,
                      ),
                      const SizedBox(height: GameSpacing.sm),
                    ],
                  const SizedBox(height: GameSpacing.lg),
                  _RecentPlayers(uid: widget.profile.uid, socialBackend: widget.socialBackend),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.code, required this.copy, required this.onCopy});

  final String code;
  final SocialCopy copy;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return CosmicPanel(
      glow: true,
      padding: const EdgeInsets.all(GameSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: GameColors.cosmicGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: GameShadows.primaryGlow,
                ),
                child: const Icon(Icons.group_rounded, color: Colors.white),
              ),
              const SizedBox(width: GameSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(copy.friends, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 3),
                    Text(copy.friendsSubtitle, style: const TextStyle(color: GameColors.muted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: GameSpacing.lg),
          Text(
            copy.yourFriendCode,
            style: const TextStyle(color: GameColors.muted, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: GameSpacing.xs),
          Row(
            children: [
              Expanded(
                child: Text(
                  code,
                  style: const TextStyle(
                    fontSize: 24,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w900,
                    color: GameColors.textStrong,
                  ),
                ),
              ),
              IconButton.filledTonal(
                onPressed: onCopy,
                tooltip: copy.copyCode,
                icon: const Icon(Icons.copy_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchCard extends StatelessWidget {
  const _SearchCard({
    required this.controller,
    required this.searching,
    required this.result,
    required this.error,
    required this.copy,
    required this.onSearch,
    required this.onSend,
    required this.sending,
  });

  final TextEditingController controller;
  final bool searching;
  final SocialPlayerSummary? result;
  final String? error;
  final SocialCopy copy;
  final VoidCallback onSearch;
  final ValueChanged<SocialPlayerSummary> onSend;
  final bool sending;

  @override
  Widget build(BuildContext context) {
    return CosmicPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(copy.findFriend, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: GameSpacing.sm),
          TextField(
            controller: controller,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: copy.friendCodeHint,
              prefixIcon: const Icon(Icons.person_search_rounded),
              suffixIcon: searching
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(onPressed: onSearch, icon: const Icon(Icons.search_rounded)),
            ),
            onSubmitted: (_) => onSearch(),
          ),
          if (error != null) ...[
            const SizedBox(height: GameSpacing.sm),
            Text(error!, style: const TextStyle(color: GameColors.danger)),
          ],
          if (result != null) ...[
            const SizedBox(height: GameSpacing.md),
            _PlayerSummaryCard(
              player: result!,
              trailing: FilledButton(
                onPressed: sending ? null : () => onSend(result!),
                child: sending
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(copy.sendRequest),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FriendshipTile extends StatelessWidget {
  const _FriendshipTile({
    required this.friendship,
    required this.otherUid,
    required this.actingUid,
    required this.socialBackend,
    required this.incoming,
  });

  final Friendship friendship;
  final String otherUid;
  final String actingUid;
  final SocialBackend socialBackend;
  final bool incoming;

  @override
  Widget build(BuildContext context) {
    final copy = SocialCopy.of(context);
    return FutureBuilder<SocialPlayerSummary?>(
      future: socialBackend.loadPlayerSummary(otherUid),
      builder: (context, snapshot) {
        final player = snapshot.data;
        if (player == null) return const _LoadingPlayerCard();
        return _PlayerSummaryCard(
          player: player,
          trailing: incoming
              ? FilledButton(
                  onPressed: () => socialBackend.acceptFriendRequest(
                    friendshipId: friendship.id,
                    actingUid: actingUid,
                  ),
                  child: Text(copy.accept),
                )
              : PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'remove') {
                      await socialBackend.removeFriendship(
                        friendshipId: friendship.id,
                        actingUid: actingUid,
                      );
                    } else if (value == 'block') {
                      await socialBackend.blockPlayer(
                        actingUid: actingUid,
                        blockedUid: otherUid,
                      );
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem<String>(value: 'remove', child: Text(copy.remove)),
                    PopupMenuItem<String>(value: 'block', child: Text(copy.block)),
                  ],
                ),
        );
      },
    );
  }
}

class _PlayerSummaryCard extends StatelessWidget {
  const _PlayerSummaryCard({required this.player, required this.trailing});

  final SocialPlayerSummary player;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final tier = RankPolicy.tierFor(player.rankPoints);
    return CosmicPanel(
      padding: const EdgeInsets.all(GameSpacing.sm),
      child: Row(
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
                const SizedBox(height: 5),
                Wrap(
                  spacing: GameSpacing.xs,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    RankBadge(
                      tier: tier,
                      compact: true,
                      legendarySeasons: player.legendarySeasons,
                    ),
                    Text(
                      'Lv ${player.level}',
                      style: const TextStyle(
                        color: GameColors.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '★ ${player.stars}',
                      style: const TextStyle(
                        color: GameColors.rewardGold,
                        fontSize: 12,
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
      ),
    );
  }
}

class _RecentPlayers extends StatelessWidget {
  const _RecentPlayers({required this.uid, required this.socialBackend});

  final String uid;
  final SocialBackend socialBackend;

  @override
  Widget build(BuildContext context) {
    final copy = SocialCopy.of(context);
    return FutureBuilder<List<RecentPlayer>>(
      future: socialBackend.loadRecentPlayers(uid),
      builder: (context, snapshot) {
        final players = snapshot.data ?? const <RecentPlayer>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionTitle(title: copy.recentPlayers, count: players.length),
            const SizedBox(height: GameSpacing.sm),
            if (snapshot.connectionState == ConnectionState.waiting)
              const _LoadingPlayerCard()
            else if (players.isEmpty)
              _EmptyState(label: copy.noRecentPlayers)
            else
              for (final recent in players) ...[
                FutureBuilder<SocialPlayerSummary?>(
                  future: socialBackend.loadPlayerSummary(recent.uid),
                  builder: (context, playerSnapshot) {
                    final player = playerSnapshot.data;
                    if (playerSnapshot.connectionState == ConnectionState.waiting) {
                      return const _LoadingPlayerCard();
                    }
                    if (player != null) {
                      return _PlayerSummaryCard(
                        player: player,
                        trailing: TextButton.icon(
                          onPressed: () => socialBackend.sendFriendRequest(
                            requesterUid: uid,
                            recipientUid: player.uid,
                          ),
                          icon: const Icon(Icons.person_add_alt_1_rounded),
                          label: Text(copy.addFriend),
                        ),
                      );
                    }
                    return CosmicPanel(
                      padding: const EdgeInsets.all(GameSpacing.sm),
                      child: Row(
                        children: [
                          CosmeticAvatarView(
                            avatarId: recent.avatarId ?? 'avatar_free_vanguard',
                            size: 44,
                          ),
                          const SizedBox(width: GameSpacing.sm),
                          Expanded(
                            child: Text(
                              recent.displayName,
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => socialBackend.sendFriendRequest(
                              requesterUid: uid,
                              recipientUid: recent.uid,
                            ),
                            icon: const Icon(Icons.person_add_alt_1_rounded),
                            label: Text(copy.addFriend),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: GameSpacing.sm),
              ],
          ],
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: GameColors.accentSoft,
            borderRadius: BorderRadius.circular(GameRadii.pill),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: GameColors.accentBright,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return CosmicPanel(
      padding: const EdgeInsets.all(GameSpacing.lg),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: GameColors.muted),
        ),
      ),
    );
  }
}

class _LoadingPlayerCard extends StatelessWidget {
  const _LoadingPlayerCard();

  @override
  Widget build(BuildContext context) {
    return const CosmicPanel(
      child: SizedBox(
        height: 44,
        child: Center(
          child: SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }
}
