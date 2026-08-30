import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/arena_copy.dart';
import '../../../core/theme/arena_ui.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_service.dart';
import '../../competition/data/competition_backend.dart';
import '../../competition/domain/rank_tier.dart';
import '../../competition/presentation/leaderboard_screen.dart';
import '../../competition/presentation/rank_badge.dart';
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
import '../../progression/data/progression_backend.dart';
import '../../progression/presentation/daily_missions_panel.dart';
import '../../progression/presentation/progression_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../social/data/room_backend.dart';
import '../../social/data/social_backend.dart';
import '../../social/presentation/room_hub_screen.dart';

class ArenaHomeScreen extends StatelessWidget {
  const ArenaHomeScreen({
    super.key,
    required this.user,
    required this.authService,
    required this.profileRepository,
    required this.matchBackend,
    required this.quickMatchBackend,
    required this.socialMatchBackend,
    required this.competitionBackend,
    required this.economyBackend,
    required this.progressionBackend,
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
  final ProgressionBackend progressionBackend;
  final SocialBackend socialBackend;
  final RoomBackend roomBackend;

  Future<String> _resolveSeasonId() async {
    try {
      final season = await competitionBackend
          .watchCurrentSeason()
          .firstWhere((value) => value != null)
          .timeout(const Duration(seconds: 2));
      return season?.id ?? 'preview_current';
    } catch (_) {
      return 'preview_current';
    }
  }

  Future<void> _openMissions(BuildContext context) async {
    final seasonId = await _resolveSeasonId();
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProgressionScreen(
          uid: user.uid,
          seasonId: seasonId,
          backend: progressionBackend,
        ),
      ),
    );
  }

  Future<void> _handleMenu(BuildContext context, String value) async {
    if (value == 'settings') {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SettingsScreen(authService: authService),
        ),
      );
      return;
    }
    if (value == 'history') {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => MatchHistoryScreen(uid: user.uid, matchBackend: matchBackend),
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
    final copy = ArenaCopy.of(context);
    return StreamBuilder<PlayerProfile?>(
      stream: profileRepository.watchProfile(user.uid),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            titleSpacing: GameSpacing.md,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    gradient: GameColors.cosmicGradient,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: GameShadows.primaryGlow,
                  ),
                  alignment: Alignment.center,
                  child: const Text('3', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                ),
                const SizedBox(width: 9),
                Text(l10n.appName, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: .7)),
              ],
            ),
            actions: [
              ArenaPill(
                label: copy.live,
                icon: Icons.circle,
                color: GameColors.success,
                solid: true,
              ),
              const SizedBox(width: 6),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz_rounded),
                onSelected: (value) => _handleMenu(context, value),
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'history', child: Text(l10n.matchHistory)),
                  PopupMenuItem(value: 'settings', child: Text(copy.isArabic ? 'الإعدادات' : 'Settings')),
                  const PopupMenuDivider(),
                  PopupMenuItem(value: 'signout', child: Text(l10n.signOut)),
                ],
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(GameSpacing.md, GameSpacing.xs, GameSpacing.md, 112),
              children: [
                _IdentityHero(profile: profile),
                const SizedBox(height: GameSpacing.md),
                _BattleHero(copy: copy),
                const SizedBox(height: GameSpacing.md),
                _PerformanceStrip(profile: profile),
                const SizedBox(height: GameSpacing.lg),
                _RankedEntry(profile: profile, backend: matchBackend),
                const SizedBox(height: GameSpacing.sm),
                _QuickEntry(profile: profile, backend: quickMatchBackend),
                const SizedBox(height: GameSpacing.sm),
                ArenaPlayButton(
                  title: copy.playWithFriends,
                  subtitle: copy.isArabic ? 'غرفة خاصة • اختر خصمك وارفع التحدي' : 'Private room • choose your rival and set the challenge',
                  icon: Icons.groups_2_rounded,
                  primary: false,
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
                ),
                const SizedBox(height: GameSpacing.lg),
                FutureBuilder<String>(
                  future: _resolveSeasonId(),
                  initialData: 'preview_current',
                  builder: (context, seasonSnapshot) => DailyMissionsPanel(
                    uid: user.uid,
                    seasonId: seasonSnapshot.data ?? 'preview_current',
                    backend: progressionBackend,
                    onOpenAll: () => unawaited(_openMissions(context)),
                  ),
                ),
                const SizedBox(height: GameSpacing.lg),
                _DiscoveryGrid(
                  onLeaderboard: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => LeaderboardScreen(competitionBackend: competitionBackend),
                    ),
                  ),
                  onProgression: () => unawaited(_openMissions(context)),
                  onShop: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ShopScreen(uid: user.uid, economyBackend: economyBackend),
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

class _IdentityHero extends StatelessWidget {
  const _IdentityHero({required this.profile});
  final PlayerProfile? profile;

  @override
  Widget build(BuildContext context) {
    final copy = ArenaCopy.of(context);
    final player = profile;
    final rp = player?.rankPoints ?? 0;
    final tier = RankPolicy.tierFor(rp);
    final avatarId = player?.avatarId ?? 'avatar_free_vanguard';
    final rankProgress = _rankProgress(rp);

    return ArenaCard(
      accent: GameColors.accentBright,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: const BoxDecoration(shape: BoxShape.circle, gradient: GameColors.cosmicGradient),
                padding: const EdgeInsets.all(2.5),
                child: ClipOval(
                  child: ColoredBox(
                    color: GameColors.surface,
                    child: AvatarArtwork(avatarId: avatarId, size: 69, borderRadius: 35),
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
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 7,
                      runSpacing: 6,
                      children: [
                        RankBadge(tier: tier, compact: true, legendarySeasons: player?.legendarySeasons ?? 0),
                        ArenaPill(label: '${copy.level} ${player?.level ?? 1}', icon: Icons.stars_rounded, color: GameColors.violet),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$rp RP', style: const TextStyle(color: GameColors.accentBright, fontWeight: FontWeight.w900, fontSize: 16)),
                  const SizedBox(height: 6),
                  SeasonStarBadge(stars: player?.stars ?? 0, compact: true),
                ],
              ),
            ],
          ),
          const SizedBox(height: GameSpacing.md),
          Row(
            children: [
              Text(copy.currentRank, style: const TextStyle(color: GameColors.muted, fontSize: 10, fontWeight: FontWeight.w800)),
              const Spacer(),
              Text(copy.nextRank, style: const TextStyle(color: GameColors.muted, fontSize: 10, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 7),
          ArenaProgress(value: rankProgress, color: _rankColor(tier)),
        ],
      ),
    );
  }

  static double _rankProgress(int rp) {
    final tier = RankPolicy.tierFor(rp);
    final index = RankPolicy.bands.indexWhere((band) => band.tier == tier);
    if (index < 0 || index >= RankPolicy.bands.length - 1) return 1;
    final floor = RankPolicy.bands[index].minimumRp;
    final ceiling = RankPolicy.bands[index + 1].minimumRp;
    return ((rp - floor) / (ceiling - floor)).clamp(0.0, 1.0).toDouble();
  }

  static Color _rankColor(RankTier tier) => switch (tier) {
        RankTier.bronze => GameColors.rankBronze,
        RankTier.silver => GameColors.rankSilver,
        RankTier.gold => GameColors.rankGold,
        RankTier.platinum => GameColors.rankPlatinum,
        RankTier.diamond => GameColors.rankDiamond,
        RankTier.master => GameColors.rankMaster,
        RankTier.grandmaster => GameColors.rankGrandmaster,
        RankTier.legend => GameColors.rankLegend,
      };
}

class _BattleHero extends StatelessWidget {
  const _BattleHero({required this.copy});
  final ArenaCopy copy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(GameSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF142D54), Color(0xFF241B50), Color(0xFF0B1730)],
        ),
        border: Border.all(color: GameColors.violet.withValues(alpha: .38)),
        boxShadow: const [
          BoxShadow(color: Color(0x332B72FF), blurRadius: 28, offset: Offset(0, 12)),
        ],
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            end: -12,
            top: -18,
            child: Icon(Icons.bolt_rounded, size: 112, color: Colors.white.withValues(alpha: .035)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ArenaPill(label: copy.onlineArena, icon: Icons.wifi_tethering_rounded, color: GameColors.success, solid: true),
              const SizedBox(height: GameSpacing.md),
              Text(
                copy.readyToFight,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, height: 1.12),
              ),
              const SizedBox(height: GameSpacing.sm),
              Text(
                copy.arenaSubtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: GameColors.textSoft, height: 1.55),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PerformanceStrip extends StatelessWidget {
  const _PerformanceStrip({required this.profile});
  final PlayerProfile? profile;

  @override
  Widget build(BuildContext context) {
    final copy = ArenaCopy.of(context);
    final player = profile;
    final winRate = ((player?.winRate ?? 0) * 100).round();
    return Row(
      children: [
        ArenaMetric(label: copy.winRate, value: '$winRate%', icon: Icons.show_chart_rounded, color: GameColors.success),
        const SizedBox(width: 8),
        ArenaMetric(label: copy.bestStreak, value: '${player?.bestWinStreak ?? 0}', icon: Icons.local_fire_department_rounded, color: GameColors.warning),
        const SizedBox(width: 8),
        ArenaMetric(label: copy.battles, value: '${player?.gamesPlayed ?? 0}', icon: Icons.sports_esports_rounded, color: GameColors.violet),
      ],
    );
  }
}

class _RankedEntry extends StatelessWidget {
  const _RankedEntry({required this.profile, required this.backend});
  final PlayerProfile? profile;
  final MatchBackend backend;

  @override
  Widget build(BuildContext context) {
    final copy = ArenaCopy.of(context);
    final player = profile;
    if (player == null) {
      return ArenaPlayButton(title: copy.rankedArena, subtitle: copy.rankedArenaSubtitle, onPressed: null);
    }
    return StreamBuilder<MatchTicket?>(
      stream: backend.watchTicket(player.uid),
      builder: (context, snapshot) {
        final ticket = snapshot.data;
        final resumable = ticket?.status == MatchTicketStatus.matched && ticket?.matchId != null;
        return ArenaPlayButton(
          title: resumable ? (copy.isArabic ? 'استئناف المواجهة' : 'RESUME BATTLE') : copy.rankedArena,
          subtitle: resumable ? (copy.isArabic ? 'لديك مباراة تنتظرك' : 'Your rival is waiting') : copy.rankedArenaSubtitle,
          icon: resumable ? Icons.play_circle_fill_rounded : Icons.bolt_rounded,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => resumable
                  ? MatchRoomScreen(matchId: ticket!.matchId!, uid: player.uid, matchBackend: backend)
                  : MatchmakingScreen(profile: player, matchBackend: backend),
            ),
          ),
        );
      },
    );
  }
}

class _QuickEntry extends StatelessWidget {
  const _QuickEntry({required this.profile, required this.backend});
  final PlayerProfile? profile;
  final MatchBackend backend;

  @override
  Widget build(BuildContext context) {
    final copy = ArenaCopy.of(context);
    final player = profile;
    final serverReady = AppConfig.backendPhase == BackendPhase.blaze;
    if (player == null || !serverReady) {
      return ArenaPlayButton(
        title: copy.quickMatch,
        subtitle: serverReady ? copy.quickMatchSubtitle : (copy.isArabic ? 'ستتاح عند تفعيل خادم المباريات' : 'Available when the match server is enabled'),
        icon: Icons.flash_on_rounded,
        primary: false,
        onPressed: null,
      );
    }
    return StreamBuilder<MatchTicket?>(
      stream: backend.watchTicket(player.uid),
      builder: (context, snapshot) {
        final ticket = snapshot.data;
        final resumable = ticket?.status == MatchTicketStatus.matched && ticket?.matchId != null;
        return ArenaPlayButton(
          title: resumable ? (copy.isArabic ? 'استئناف السريعة' : 'RESUME QUICK') : copy.quickMatch,
          subtitle: copy.quickMatchSubtitle,
          icon: Icons.flash_on_rounded,
          primary: false,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => resumable
                  ? MatchRoomScreen(matchId: ticket!.matchId!, uid: player.uid, matchBackend: backend)
                  : MatchmakingScreen(profile: player, matchBackend: backend),
            ),
          ),
        );
      },
    );
  }
}

class _DiscoveryGrid extends StatelessWidget {
  const _DiscoveryGrid({required this.onLeaderboard, required this.onProgression, required this.onShop});
  final VoidCallback onLeaderboard;
  final VoidCallback onProgression;
  final VoidCallback onShop;

  @override
  Widget build(BuildContext context) {
    final copy = ArenaCopy.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ArenaSectionTitle(
          title: copy.isArabic ? 'استكشف 3 Minutes' : 'EXPLORE 3 MINUTES',
          subtitle: copy.isArabic ? 'كل تقدمك ومكافآتك في مكان واحد' : 'Your climb, rewards and collection in one place',
          icon: Icons.explore_rounded,
        ),
        const SizedBox(height: GameSpacing.sm),
        Row(
          children: [
            Expanded(child: _DiscoveryTile(icon: Icons.leaderboard_rounded, title: copy.isArabic ? 'المتصدرون' : 'LEADERBOARD', color: GameColors.warning, onTap: onLeaderboard)),
            const SizedBox(width: 8),
            Expanded(child: _DiscoveryTile(icon: Icons.route_rounded, title: copy.progression, color: GameColors.violet, onTap: onProgression)),
            const SizedBox(width: 8),
            Expanded(child: _DiscoveryTile(icon: Icons.storefront_rounded, title: copy.isArabic ? 'المتجر' : 'SHOP', color: GameColors.accentBright, onTap: onShop)),
          ],
        ),
      ],
    );
  }
}

class _DiscoveryTile extends StatelessWidget {
  const _DiscoveryTile({required this.icon, required this.title, required this.color, required this.onTap});
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ArenaCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
      child: Column(
        children: [
          Icon(icon, color: color, size: 23),
          const SizedBox(height: 8),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
