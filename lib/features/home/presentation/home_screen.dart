import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_service.dart';
import '../../competition/data/competition_backend.dart';
import '../../competition/domain/rank_tier.dart';
import '../../competition/presentation/leaderboard_screen.dart';
import '../../competition/presentation/rank_badge.dart';
import '../../competition/presentation/season_screen.dart';
import '../../competition/presentation/season_star_badge.dart';
import '../../economy/data/economy_backend.dart';
import '../../economy/presentation/shop_screen.dart';
import '../../match/data/match_backend.dart';
import '../../match/domain/match_ticket.dart';
import '../../match/presentation/match_history_screen.dart';
import '../../match/presentation/match_room_screen.dart';
import '../../match/presentation/matchmaking_screen.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/domain/player_profile.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../social/data/room_backend.dart';
import '../../social/data/social_backend.dart';
import '../../social/presentation/friends_screen.dart';
import '../../social/presentation/room_hub_screen.dart';
import '../../social/presentation/social_copy.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.user,
    required this.authService,
    required this.profileRepository,
    required this.matchBackend,
    required this.competitionBackend,
    required this.economyBackend,
    required this.socialBackend,
    required this.roomBackend,
  });

  final User user;
  final AuthService authService;
  final ProfileRepository profileRepository;
  final MatchBackend matchBackend;
  final CompetitionBackend competitionBackend;
  final EconomyBackend economyBackend;
  final SocialBackend socialBackend;
  final RoomBackend roomBackend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final socialCopy = SocialCopy.of(context);

    return StreamBuilder<PlayerProfile?>(
      stream: profileRepository.watchProfile(user.uid),
      builder: (context, snapshot) {
        final profile = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              l10n.appName,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            actions: [
              IconButton(
                tooltip: l10n.matchHistory,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => MatchHistoryScreen(
                        uid: user.uid,
                        matchBackend: matchBackend,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.history_rounded),
              ),
              IconButton(
                tooltip: l10n.signOut,
                onPressed: authService.signOut,
                icon: const Icon(Icons.logout_rounded),
              ),
            ],
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(GameSpacing.md),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - (GameSpacing.md * 2),
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _PlayerCard(profile: profile),
                          const SizedBox(height: GameSpacing.xl),
                          _PlayButton(
                            profile: profile,
                            matchBackend: matchBackend,
                          ),
                          const SizedBox(height: GameSpacing.sm),
                          Text(
                            l10n.miniGamesSummary(AppConfig.gamesPerMatch),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: GameColors.muted,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: GameSpacing.md),
                          _FriendsPlaySurface(
                            label: socialCopy.playWithFriends,
                            enabled: profile != null,
                            onTap: profile == null
                                ? null
                                : () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => RoomHubScreen(
                                          profile: profile,
                                          roomBackend: roomBackend,
                                          socialBackend: socialBackend,
                                        ),
                                      ),
                                    );
                                  },
                          ),
                          const SizedBox(height: GameSpacing.xl),
                          Row(
                            children: [
                              Expanded(
                                child: _MenuTile(
                                  icon: Icons.leaderboard_rounded,
                                  label: l10n.leaderboard,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => LeaderboardScreen(
                                          competitionBackend: competitionBackend,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: GameSpacing.sm),
                              Expanded(
                                child: _MenuTile(
                                  icon: Icons.auto_awesome_rounded,
                                  label: l10n.season,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => SeasonScreen(
                                          competitionBackend: competitionBackend,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: GameSpacing.sm),
                          Row(
                            children: [
                              Expanded(
                                child: _MenuTile(
                                  icon: Icons.group_rounded,
                                  label: socialCopy.friends,
                                  onTap: profile == null
                                      ? null
                                      : () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute<void>(
                                              builder: (_) => FriendsScreen(
                                                profile: profile,
                                                socialBackend: socialBackend,
                                              ),
                                            ),
                                          );
                                        },
                                ),
                              ),
                              const SizedBox(width: GameSpacing.sm),
                              Expanded(
                                child: _MenuTile(
                                  icon: Icons.storefront_rounded,
                                  label: l10n.shop,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => ShopScreen(
                                          uid: user.uid,
                                          economyBackend: economyBackend,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: GameSpacing.sm),
                          _MenuTile(
                            icon: Icons.person_rounded,
                            label: l10n.profile,
                            onTap: profile == null
                                ? null
                                : () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => ProfileScreen(
                                          profile: profile,
                                          profileRepository: profileRepository,
                                        ),
                                      ),
                                    );
                                  },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.profile, required this.matchBackend});

  final PlayerProfile? profile;
  final MatchBackend matchBackend;

  void _openMatch(
    BuildContext context,
    PlayerProfile player,
    MatchTicket? ticket,
  ) {
    final resumable = ticket?.status == MatchTicketStatus.matched &&
        ticket?.matchId != null;

    if (resumable) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => MatchRoomScreen(
            matchId: ticket!.matchId!,
            uid: player.uid,
            matchBackend: matchBackend,
          ),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MatchmakingScreen(
          profile: player,
          matchBackend: matchBackend,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = profile;
    final l10n = AppLocalizations.of(context);

    if (player == null) {
      return _PlaySurface(label: l10n.play, onTap: null);
    }

    return StreamBuilder<MatchTicket?>(
      stream: matchBackend.watchTicket(player.uid),
      builder: (context, snapshot) {
        final ticket = snapshot.data;
        final resumable = ticket?.status == MatchTicketStatus.matched &&
            ticket?.matchId != null;

        return _PlaySurface(
          label: resumable ? l10n.resume : l10n.play,
          onTap: () => _openMatch(context, player, ticket),
          resumable: resumable,
        );
      },
    );
  }
}

class _PlaySurface extends StatelessWidget {
  const _PlaySurface({
    required this.label,
    required this.onTap,
    this.resumable = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool resumable;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(GameRadii.panel),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GameRadii.panel),
        child: Ink(
          height: 92,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(GameRadii.panel),
            gradient: enabled
                ? const LinearGradient(
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                    colors: [Color(0xFF34CDEB), Color(0xFF197EA8)],
                  )
                : const LinearGradient(
                    colors: [GameColors.surfaceRaised, GameColors.surface],
                  ),
            border: Border.all(
              color: enabled
                  ? GameColors.accent.withValues(alpha: 0.65)
                  : GameColors.surfaceStrong,
            ),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: GameColors.accent.withValues(alpha: 0.16),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                resumable ? Icons.play_circle_outline_rounded : Icons.bolt_rounded,
                size: 30,
                color: enabled ? GameColors.background : GameColors.muted,
              ),
              const SizedBox(width: GameSpacing.sm),
              Text(
                label,
                style: TextStyle(
                  color: enabled ? GameColors.background : GameColors.muted,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FriendsPlaySurface extends StatelessWidget {
  const _FriendsPlaySurface({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: enabled ? onTap : null,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: GameSpacing.md),
        side: BorderSide(color: GameColors.accent.withValues(alpha: 0.35)),
        backgroundColor: GameColors.accentSoft.withValues(alpha: 0.35),
      ),
      icon: const Icon(Icons.groups_2_rounded),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({required this.profile});

  final PlayerProfile? profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final player = profile;
    final rankPoints = player?.rankPoints ?? 0;
    final tier = RankPolicy.tierFor(rankPoints);

    return Container(
      padding: const EdgeInsets.all(GameSpacing.md),
      decoration: BoxDecoration(
        color: GameColors.surface,
        borderRadius: BorderRadius.circular(GameRadii.panel),
        border: Border.all(color: GameColors.surfaceStrong),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: GameColors.surfaceRaised,
              border: Border.all(
                color: GameColors.accent.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: const Icon(Icons.person_rounded, size: 34),
          ),
          const SizedBox(width: GameSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player?.gameName ?? '—',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: GameColors.textStrong,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: GameSpacing.sm),
                Wrap(
                  spacing: GameSpacing.sm,
                  runSpacing: GameSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    RankBadge(tier: tier, compact: true),
                    Text(
                      l10n.levelWithValue(player?.level ?? 1),
                      style: const TextStyle(
                        color: GameColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      l10n.rpWithValue(rankPoints),
                      style: const TextStyle(
                        color: GameColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: GameSpacing.sm),
          SeasonStarBadge(stars: player?.stars ?? 0, compact: true),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Material(
      color: GameColors.surface,
      borderRadius: BorderRadius.circular(GameRadii.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GameRadii.card),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: GameSpacing.md,
            horizontal: GameSpacing.xs,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(GameRadii.card),
            border: Border.all(color: GameColors.surfaceStrong),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: GameColors.accentSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: enabled ? GameColors.accent : GameColors.muted,
                  size: 22,
                ),
              ),
              const SizedBox(height: GameSpacing.sm),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: enabled ? GameColors.textStrong : GameColors.muted,
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
