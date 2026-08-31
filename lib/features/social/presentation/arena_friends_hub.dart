import 'package:flutter/material.dart';

import '../../../core/theme/arena_ui.dart';
import '../../../core/theme/cosmic_background.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/game_glyphs.dart';
import '../../profile/domain/player_profile.dart';
import '../data/social_backend.dart';
import '../domain/friendship.dart';

class ArenaFriendsHub extends StatelessWidget {
  const ArenaFriendsHub({
    super.key,
    required this.profile,
    required this.socialBackend,
    required this.onOpenFriends,
  });

  final PlayerProfile profile;
  final SocialBackend socialBackend;
  final VoidCallback onOpenFriends;

  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            const GameGlyph(
              type: GameGlyphType.squad,
              size: 26,
              color: GameColors.accentBright,
              active: true,
            ),
            const SizedBox(width: 10),
            Text(ar ? 'الفريق والأصدقاء' : 'SQUAD & FRIENDS'),
          ],
        ),
      ),
      body: CosmicBackground(
        child: SafeArea(
          top: false,
          child: StreamBuilder<List<Friendship>>(
            stream: socialBackend.watchFriendships(profile.uid),
            builder: (context, snapshot) {
              final friendships = snapshot.data ?? const <Friendship>[];
              final accepted = friendships
                  .where((item) => item.status == FriendshipStatus.accepted)
                  .length;
              final incoming = friendships
                  .where((item) =>
                      item.status == FriendshipStatus.pending &&
                      item.recipientUid == profile.uid)
                  .length;
              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  GameSpacing.md,
                  GameSpacing.sm,
                  GameSpacing.md,
                  112,
                ),
                children: [
                  _SocialHero(
                    ar: ar,
                    accepted: accepted,
                    incoming: incoming,
                  ),
                  const SizedBox(height: GameSpacing.md),
                  Row(
                    children: [
                      ArenaMetric(
                        label: ar ? 'الأصدقاء' : 'FRIENDS',
                        value: '$accepted',
                        icon: Icons.people_alt_rounded,
                        color: GameColors.accentBright,
                      ),
                      const SizedBox(width: 8),
                      ArenaMetric(
                        label: ar ? 'طلبات جديدة' : 'REQUESTS',
                        value: '$incoming',
                        icon: Icons.notifications_active_rounded,
                        color: incoming > 0 ? GameColors.warning : GameColors.muted,
                      ),
                      const SizedBox(width: 8),
                      ArenaMetric(
                        label: ar ? 'الحالة' : 'STATUS',
                        value: ar ? 'جاهز' : 'READY',
                        icon: Icons.flash_on_rounded,
                        color: GameColors.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: GameSpacing.lg),
                  ArenaSectionTitle(
                    title: ar ? 'جهّز فريقك' : 'BUILD YOUR SQUAD',
                    subtitle: ar
                        ? 'أضف اللاعبين، تابع الطلبات، وابدأ التحديات الخاصة.'
                        : 'Add players, manage requests and launch private challenges.',
                    trailing: const GameGlyph(
                      type: GameGlyphType.squad,
                      size: 25,
                      color: GameColors.violet,
                    ),
                  ),
                  const SizedBox(height: GameSpacing.sm),
                  ArenaPlayButton(
                    title: ar ? 'إدارة الأصدقاء' : 'MANAGE FRIENDS',
                    subtitle: ar
                        ? 'بحث، طلبات، حظر، ولاعبون حديثون'
                        : 'Search, requests, blocks and recent players',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: onOpenFriends,
                  ),
                  const SizedBox(height: GameSpacing.md),
                  ArenaCard(
                    accent: GameColors.violet,
                    child: Row(
                      children: [
                        const GameGlyph(
                          type: GameGlyphType.battle,
                          size: 29,
                          color: GameColors.violet,
                          active: true,
                        ),
                        const SizedBox(width: GameSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ar ? 'التحدي الخاص' : 'PRIVATE CHALLENGE',
                                style: const TextStyle(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ar
                                    ? 'دعوات الغرف الخاصة ستظهر داخل نظام الأصدقاء والغرف دون تغيير قواعد المباراة.'
                                    : 'Private-room invites remain integrated with friends and rooms without changing match rules.',
                                style: const TextStyle(color: GameColors.textSoft, fontSize: 11, height: 1.45),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: GameSpacing.md),
                  ArenaCard(
                    accent: GameColors.success,
                    child: Row(
                      children: [
                        const GameGlyph(
                          type: GameGlyphType.shield,
                          size: 28,
                          color: GameColors.success,
                        ),
                        const SizedBox(width: GameSpacing.md),
                        Expanded(
                          child: Text(
                            ar
                                ? 'اجعل دائرتك صغيرة وواضحة: أصدقاء، منافسون حديثون، وحظر عند الحاجة.'
                                : 'Keep your circle clean: friends, recent rivals and blocking when needed.',
                            style: const TextStyle(color: GameColors.textSoft, fontSize: 11, height: 1.45),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SocialHero extends StatelessWidget {
  const _SocialHero({required this.ar, required this.accepted, required this.incoming});
  final bool ar;
  final int accepted;
  final int incoming;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(GameSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(27),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF123A4D), Color(0xFF262451), Color(0xFF09152C)],
        ),
        border: Border.all(color: GameColors.accentBright.withValues(alpha: .24)),
        boxShadow: const [BoxShadow(color: Color(0x2820DDE9), blurRadius: 30, offset: Offset(0, 12))],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: GameColors.accentBright.withValues(alpha: .09),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: GameColors.accentBright.withValues(alpha: .28)),
            ),
            alignment: Alignment.center,
            child: const GameGlyph(
              type: GameGlyphType.squad,
              size: 39,
              color: GameColors.accentBright,
              active: true,
            ),
          ),
          const SizedBox(width: GameSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ar ? 'لا تلعب وحدك' : 'DON’T FIGHT ALONE',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                Text(
                  ar
                      ? 'كوّن دائرتك، واجه أصدقاءك، واحتفظ بأفضل المنافسين قريبين.'
                      : 'Build your circle, challenge friends and keep great rivals close.',
                  style: const TextStyle(color: GameColors.textSoft, fontSize: 11, height: 1.45),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ArenaPill(
                      label: ar ? '$accepted صديق' : '$accepted FRIENDS',
                      color: GameColors.accentBright,
                      solid: true,
                    ),
                    if (incoming > 0)
                      ArenaPill(
                        label: ar ? '$incoming طلب' : '$incoming REQUESTS',
                        color: GameColors.warning,
                        solid: true,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
