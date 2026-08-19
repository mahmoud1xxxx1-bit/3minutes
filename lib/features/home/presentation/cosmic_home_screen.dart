import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/cosmic_background.dart';
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
import '../../economy/presentation/avatar_artwork.dart';
import '../../economy/presentation/shop_screen.dart';
import '../../match/data/match_backend.dart';
import '../../match/data/social_match_backend.dart';
import '../../match/domain/match_ticket.dart';
import '../../match/presentation/match_history_screen.dart';
import '../../match/presentation/match_room_screen.dart';
import '../../match/presentation/matchmaking_screen.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/domain/player_profile.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../social/data/room_backend.dart';
import '../../social/data/social_backend.dart';
import '../../social/presentation/friends_screen.dart';
import '../../social/presentation/room_hub_screen.dart';
import '../../social/presentation/social_copy.dart';

class CosmicHomeScreen extends StatelessWidget {
  const CosmicHomeScreen({
    super.key,
    required this.user,
    required this.authService,
    required this.profileRepository,
    required this.matchBackend,
    required this.quickMatchBackend,
    required this.socialMatchBackend,
    required this.competitionBackend,
    required this.economyBackend,
    required this.socialBackend,
    required this.roomBackend,
  });

  final User user;
  final AuthService authService;
  final ProfileRepository profileRepository;
  final MatchBackend matchBackend;
  final MatchBackend quickMatchBackend;
  final SocialMatchBackend socialMatchBackend;
  final CompetitionBackend competitionBackend;
  final EconomyBackend economyBackend;
  final SocialBackend socialBackend;
  final RoomBackend roomBackend;

  Future<void> _handleMenu(BuildContext context, String value) async {
    if (value == 'settings') {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SettingsScreen(authService: authService),
        ),
      );
      return;
    }
    if (value == 'signout') {
      if (!await confirmSignOut(context) || !context.mounted) return;
      await authService.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final social = SocialCopy.of(context);
    final ar = Localizations.localeOf(context).languageCode == 'ar';

    return StreamBuilder<PlayerProfile?>(
      stream: profileRepository.watchProfile(user.uid),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(l10n.appName),
            actions: [
              IconButton(
                tooltip: l10n.matchHistory,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => MatchHistoryScreen(
                      uid: user.uid,
                      matchBackend: matchBackend,
                    ),
                  ),
                ),
                icon: const Icon(Icons.history_rounded),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz_rounded),
                onSelected: (value) => _handleMenu(context, value),
                itemBuilder: (_) => [
                  PopupMenuItem<String>(
                    value: 'settings',
                    child: Row(
                      children: [
                        const Icon(Icons.settings_rounded),
                        const SizedBox(width: GameSpacing.sm),
                        Text(ar ? 'الإعدادات' : 'Settings'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'signout',
                    child: Row(
                      children: [
                        const Icon(Icons.logout_rounded),
                        const SizedBox(width: GameSpacing.sm),
                        Text(l10n.signOut),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                GameSpacing.md,
                GameSpacing.sm,
                GameSpacing.md,
                96,
              ),
              children: [
                _ProfileHero(profile: profile),
                const SizedBox(height: GameSpacing.md),
                _SeasonSummary(profile: profile),
                const SizedBox(height: GameSpacing.lg),
                _RankedPlayButton(
                  profile: profile,
                  matchBackend: matchBackend,
                ),
                const SizedBox(height: GameSpacing.sm),
                _QuickPlayButton(
                  profile: profile,
                  matchBackend: quickMatchBackend,
                ),
                const SizedBox(height: GameSpacing.sm),
                OutlinedButton.icon(
                  onPressed: profile == null
                      ? null
                      : () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => RoomHubScreen(
                                profile: profile,
                                roomBackend: roomBackend,
                                socialBackend: socialBackend,
                                socialMatchBackend: socialMatchBackend,
                              ),
                            ),
                          ),
                  icon: const Icon(Icons.groups_2_rounded),
                  label: Text(social.playWithFriends),
                ),
                const SizedBox(height: GameSpacing.sm),
                Text(
                  l10n.miniGamesSummary(AppConfig.gamesPerMatch),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: GameSpacing.lg),
                _QuickLinks(
                  onLeaderboard: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => LeaderboardScreen(
                        competitionBackend: competitionBackend,
                      ),
                    ),
                  ),
                  onSeason: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => SeasonScreen(
                        competitionBackend: competitionBackend,
                      ),
                    ),
                  ),
                  onFriends: profile == null
                      ? null
                      : () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => FriendsScreen(
                                profile: profile,
                                socialBackend: socialBackend,
                              ),
                            ),
                          ),
                  onShop: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ShopScreen(
                        uid: user.uid,
                        economyBackend: economyBackend,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.profile});

  final PlayerProfile? profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final player = profile;
    final rp = player?.rankPoints ?? 0;
    final tier = RankPolicy.tierFor(rp);
    final avatarId = player?.avatarId ?? 'avatar_free_vanguard';

    return CosmicPanel(
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: GameColors.cosmicGradient,
              boxShadow: GameShadows.primaryGlow,
            ),
            padding: const EdgeInsets.all(2),
            child: ClipOval(
              child: DecoratedBox(
                decoration: const BoxDecoration(color: GameColors.surface),
                child: AvatarArtwork(
                  avatarId: avatarId,
                  size: 64,
                  borderRadius: 32,
                ),
              ),
            ),
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
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: GameSpacing.xs),
                Wrap(
                  spacing: GameSpacing.sm,
                  runSpacing: GameSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    RankBadge(
                      tier: tier,
                      compact: true,
                      legendarySeasons: player?.legendarySeasons ?? 0,
                    ),
                    Text(
                      l10n.levelWithValue(player?.level ?? 1),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: GameSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                l10n.rpWithValue(rp),
                style: const TextStyle(
                  color: GameColors.accentBright,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: GameSpacing.xs),
              SeasonStarBadge(stars: player?.stars ?? 0, compact: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _SeasonSummary extends StatelessWidget {
  const _SeasonSummary({required this.profile});

  final PlayerProfile? profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rp = profile?.rankPoints ?? 0;
    final tier = RankPolicy.tierFor(rp);
    final index = RankPolicy.bands.indexWhere((band) => band.tier == tier);
    final floor = RankPolicy.bands[index].minimumRp;
    final hasNext = index >= 0 && index < RankPolicy.bands.length - 1;
    final ceiling = hasNext ? RankPolicy.bands[index + 1].minimumRp : rp;
    final range = hasNext ? (ceiling - floor) : 1;
    final progress = hasNext ? ((rp - floor) / range).clamp(0.0, 1.0) : 1.0;

    return CosmicPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: GameColors.violet),
              const SizedBox(width: GameSpacing.sm),
              Expanded(
                child: Text(
                  l10n.season,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              RankBadge(tier: tier, compact: true),
            ],
          ),
          const SizedBox(height: GameSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(GameRadii.pill),
            child: LinearProgressIndicator(value: progress, minHeight: 8),
          ),
          const SizedBox(height: GameSpacing.xs),
          Text(
            hasNext ? '$rp / $ceiling RP' : l10n.rpWithValue(rp),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _RankedPlayButton extends StatelessWidget {
  const _RankedPlayButton({required this.profile, required this.matchBackend});

  final PlayerProfile? profile;
  final MatchBackend matchBackend;

  void _open(BuildContext context, PlayerProfile player, MatchTicket? ticket) {
    final resumable = ticket?.status == MatchTicketStatus.matched && ticket?.matchId != null;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => resumable
            ? MatchRoomScreen(
                matchId: ticket!.matchId!,
                uid: player.uid,
                matchBackend: matchBackend,
              )
            : MatchmakingScreen(profile: player, matchBackend: matchBackend),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = profile;
    final l10n = AppLocalizations.of(context);
    if (player == null) {
      return CosmicPrimaryButton(onPressed: null, child: Text(l10n.play));
    }

    return StreamBuilder<MatchTicket?>(
      stream: matchBackend.watchTicket(player.uid),
      builder: (context, snapshot) {
        final ticket = snapshot.data;
        final resumable = ticket?.status == MatchTicketStatus.matched && ticket?.matchId != null;
        return CosmicPrimaryButton(
          onPressed: () => _open(context, player, ticket),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(resumable ? Icons.play_circle_fill_rounded : Icons.bolt_rounded),
              const SizedBox(width: GameSpacing.sm),
              Text(
                resumable ? l10n.resume : l10n.play,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickPlayButton extends StatelessWidget {
  const _QuickPlayButton({required this.profile, required this.matchBackend});

  final PlayerProfile? profile;
  final MatchBackend matchBackend;

  bool _isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar';

  void _open(BuildContext context, PlayerProfile player, MatchTicket? ticket) {
    final resumable = ticket?.status == MatchTicketStatus.matched && ticket?.matchId != null;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => resumable
            ? MatchRoomScreen(
                matchId: ticket!.matchId!,
                uid: player.uid,
                matchBackend: matchBackend,
              )
            : MatchmakingScreen(profile: player, matchBackend: matchBackend),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = profile;
    final serverReady = AppConfig.backendPhase == BackendPhase.blaze;
    final title = _isArabic(context) ? 'مباراة سريعة' : 'QUICK MATCH';
    final subtitle = _isArabic(context)
        ? '1 ضد 1 • بدون RP • مكافآت Coins وXP'
        : '1v1 • No RP • Coins & XP rewards';

    if (player == null || !serverReady) {
      return OutlinedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.flash_on_rounded),
        label: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            Text(
              serverReady
                  ? subtitle
                  : (_isArabic(context)
                      ? 'غير متاح في هذه النسخة التجريبية'
                      : 'Unavailable in this test build'),
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<MatchTicket?>(
      stream: matchBackend.watchTicket(player.uid),
      builder: (context, snapshot) {
        final ticket = snapshot.data;
        final resumable = ticket?.status == MatchTicketStatus.matched && ticket?.matchId != null;
        return OutlinedButton.icon(
          onPressed: () => _open(context, player, ticket),
          icon: Icon(resumable ? Icons.play_circle_fill_rounded : Icons.flash_on_rounded),
          label: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                resumable
                    ? (_isArabic(context) ? 'استئناف المباراة السريعة' : 'RESUME QUICK')
                    : title,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              Text(subtitle, style: const TextStyle(fontSize: 10)),
            ],
          ),
        );
      },
    );
  }
}

class _QuickLinks extends StatelessWidget {
  const _QuickLinks({
    required this.onLeaderboard,
    required this.onSeason,
    required this.onFriends,
    required this.onShop,
  });

  final VoidCallback onLeaderboard;
  final VoidCallback onSeason;
  final VoidCallback? onFriends;
  final VoidCallback onShop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final social = SocialCopy.of(context);
    final links = [
      (Icons.leaderboard_rounded, l10n.leaderboard, onLeaderboard),
      (Icons.auto_awesome_rounded, l10n.season, onSeason),
      (Icons.group_rounded, social.friends, onFriends),
      (Icons.storefront_rounded, l10n.shop, onShop),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: GameSpacing.sm,
        crossAxisSpacing: GameSpacing.sm,
        childAspectRatio: 1.9,
      ),
      itemCount: links.length,
      itemBuilder: (context, index) {
        final item = links[index];
        return Material(
          color: GameColors.surfaceGlass,
          borderRadius: BorderRadius.circular(GameRadii.card),
          child: InkWell(
            onTap: item.$3,
            borderRadius: BorderRadius.circular(GameRadii.card),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: GameSpacing.md),
              decoration: BoxDecoration(
                border: Border.all(color: GameColors.surfaceStrong, width: 0.8),
                borderRadius: BorderRadius.circular(GameRadii.card),
              ),
              child: Row(
                children: [
                  Icon(
                    item.$1,
                    color: item.$3 == null ? GameColors.muted : GameColors.accent,
                  ),
                  const SizedBox(width: GameSpacing.sm),
                  Expanded(
                    child: Text(
                      item.$2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: item.$3 == null ? GameColors.muted : GameColors.textStrong,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
