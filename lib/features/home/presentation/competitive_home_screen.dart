import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../../competition/data/competition_backend.dart';
import '../../competition/data/competitive_leaderboard_repository.dart';
import '../../competition/domain/rank_tier.dart';
import '../../competition/presentation/competitive_leaderboard_screen.dart';
import '../../competition/presentation/rank_badge.dart';
import '../../competition/presentation/season_star_badge.dart';
import '../../economy/data/competitive_economy_service.dart';
import '../../economy/data/competitive_wallet_repository.dart';
import '../../economy/data/economy_backend.dart';
import '../../economy/presentation/avatar_artwork.dart';
import '../../economy/presentation/daily_gold_mail_screen.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/domain/player_profile.dart';

class CompetitiveHomeScreen extends StatelessWidget {
  const CompetitiveHomeScreen({
    super.key,
    required this.user,
    required this.profileRepository,
    required this.economyBackend,
    required this.competitionBackend,
    required this.walletRepository,
    required this.competitiveEconomyService,
    required this.onPlay,
    required this.onRank,
    required this.onShop,
  });

  final User user;
  final ProfileRepository profileRepository;
  final EconomyBackend economyBackend;
  final CompetitionBackend competitionBackend;
  final CompetitiveWalletRepository walletRepository;
  final CompetitiveEconomyService competitiveEconomyService;
  final VoidCallback onPlay;
  final VoidCallback onRank;
  final VoidCallback onShop;

  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    return StreamBuilder<PlayerProfile?>(
      stream: profileRepository.watchProfile(user.uid),
      builder: (context, profileSnapshot) {
        final profile = profileSnapshot.data;
        return StreamBuilder(
          stream: economyBackend.watchInventory(user.uid),
          builder: (context, inventorySnapshot) {
            final inventory = inventorySnapshot.data;
            return StreamBuilder(
              stream: walletRepository.watchWallet(user.uid),
              builder: (context, walletSnapshot) {
                final wallet = walletSnapshot.data;
                final rp = profile?.rankPoints ?? 0;
                final tier = RankPolicy.tierFor(rp);
                return Scaffold(
                  backgroundColor: Colors.transparent,
                  body: SafeArea(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 110),
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: GameColors.cosmicGradient,
                                boxShadow: GameShadows.primaryGlow,
                              ),
                              child: ClipOval(
                                child: AvatarArtwork(
                                  avatarId: profile?.avatarId ?? 'avatar_free_vanguard',
                                  size: 60,
                                  borderRadius: 30,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile?.gameName ?? '—',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      RankBadge(
                                        tier: tier,
                                        compact: true,
                                        legendarySeasons: profile?.legendarySeasons ?? 0,
                                      ),
                                      const SizedBox(width: 8),
                                      SeasonStarBadge(stars: profile?.stars ?? 0, compact: true),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: ar ? 'البريد' : 'Mail',
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => DailyGoldMailScreen(
                                    uid: user.uid,
                                    walletRepository: walletRepository,
                                    economyService: competitiveEconomyService,
                                  ),
                                ),
                              ),
                              icon: const Icon(Icons.mail_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: _BalanceCard(
                                label: 'COINS',
                                value: inventory?.coins ?? 0,
                                icon: Icons.monetization_on_rounded,
                                color: GameColors.coin,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _BalanceCard(
                                label: 'GOLD',
                                value: wallet?.availableGold ?? 0,
                                icon: Icons.workspace_premium_rounded,
                                color: GameColors.rewardGoldBright,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: GameColors.arenaGradient,
                            borderRadius: BorderRadius.circular(GameRadii.panel),
                            border: Border.all(color: GameColors.accentSoft),
                            boxShadow: GameShadows.primaryGlow,
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.timer_rounded, size: 54, color: GameColors.accentBright),
                              const SizedBox(height: 10),
                              const Text(
                                '3 MINUTES',
                                style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                ar ? 'خصم حقيقي • أربع ألعاب • شيء على المحك' : 'Real opponent • 4 games • Something at stake',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: GameColors.textSoft),
                              ),
                              const SizedBox(height: 22),
                              SizedBox(
                                width: double.infinity,
                                height: 62,
                                child: FilledButton.icon(
                                  onPressed: onPlay,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: GameColors.accent,
                                    foregroundColor: GameColors.backgroundDeep,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(GameRadii.button),
                                    ),
                                  ),
                                  icon: const Icon(Icons.play_arrow_rounded, size: 30),
                                  label: Text(
                                    ar ? 'العب الآن' : 'PLAY',
                                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 2.2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          children: [
                            _QuickAction(
                              icon: Icons.military_tech_rounded,
                              label: ar ? 'الرتبة' : 'Rank',
                              onTap: onRank,
                            ),
                            _QuickAction(
                              icon: Icons.leaderboard_rounded,
                              label: ar ? 'المتصدرون' : 'Leaderboards',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => CompetitiveLeaderboardScreen(
                                    uid: user.uid,
                                    repository: CompetitiveLeaderboardRepository(),
                                  ),
                                ),
                              ),
                            ),
                            _QuickAction(
                              icon: Icons.storefront_rounded,
                              label: ar ? 'المتجر' : 'Shop',
                              onTap: onShop,
                            ),
                            _QuickAction(
                              icon: Icons.mail_rounded,
                              label: ar ? 'البريد' : 'Mail',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => DailyGoldMailScreen(
                                    uid: user.uid,
                                    walletRepository: walletRepository,
                                    economyService: competitiveEconomyService,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.label, required this.value, required this.icon, required this.color});
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: GameColors.surfaceGlass,
          borderRadius: BorderRadius.circular(GameRadii.card),
          border: Border.all(color: GameColors.surfaceStrong),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 11, color: GameColors.textSoft, fontWeight: FontWeight.w800)),
                  Text('$value', style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GameRadii.card),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: GameColors.surfaceGlass,
            borderRadius: BorderRadius.circular(GameRadii.card),
            border: Border.all(color: GameColors.surfaceStrong),
          ),
          child: Row(
            children: [
              Icon(icon, color: GameColors.accentBright),
              const SizedBox(width: 10),
              Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800))),
            ],
          ),
        ),
      );
}
