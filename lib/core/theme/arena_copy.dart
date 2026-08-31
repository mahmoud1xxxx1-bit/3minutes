import 'package:flutter/widgets.dart';

/// Focused bilingual copy for the premium competitive experience.
///
/// The app already uses generated ARB localization for global product strings.
/// This class keeps the new competitive surfaces self-contained while still
/// respecting the active app locale from the first implementation pass.
class ArenaCopy {
  const ArenaCopy._(this.isArabic);

  factory ArenaCopy.of(BuildContext context) => ArenaCopy._(
        Localizations.localeOf(context).languageCode.toLowerCase() == 'ar',
      );

  final bool isArabic;

  String get readyToFight => isArabic ? 'جاهز تحسمها في 3 دقائق؟' : 'READY TO OWN THE NEXT 3 MINUTES?';
  String get arenaSubtitle => isArabic
      ? 'خصم حقيقي • ألعاب سريعة • والفائز يأخذ الرهان + RP + Coins'
      : 'Real rival • rapid games • winner takes the wager + RP + Coins';
  String get rankedArena => isArabic ? 'الساحة المصنفة' : 'RANKED ARENA';
  String get rankedArenaSubtitle => isArabic ? 'نافس على RP وارفع رتبتك' : 'Climb the ladder and fight for RP';
  String get quickMatch => isArabic ? 'مباراة سريعة' : 'QUICK MATCH';
  String get quickMatchSubtitle => isArabic ? 'بدون RP • مكافآت Coins وXP' : 'No RP • Coins & XP rewards';
  String get playWithFriends => isArabic ? 'العب مع أصدقائك' : 'PLAY WITH FRIENDS';
  String get winRate => isArabic ? 'نسبة الفوز' : 'WIN RATE';
  String get bestStreak => isArabic ? 'أفضل سلسلة' : 'BEST STREAK';
  String get battles => isArabic ? 'المباريات' : 'BATTLES';
  String get currentRank => isArabic ? 'رتبتك الحالية' : 'CURRENT RANK';
  String get nextRank => isArabic ? 'إلى الرتبة التالية' : 'TO NEXT RANK';
  String get dailyMissions => isArabic ? 'مهام اليوم' : 'DAILY MISSIONS';
  String get dailyMissionsSubtitle => isArabic ? 'أنجزها قبل إعادة الضبط واربح مكافآتك' : 'Finish before reset and collect your rewards';
  String get allMissions => isArabic ? 'عرض جميع المهام' : 'VIEW ALL MISSIONS';
  String get claim => isArabic ? 'استلام' : 'CLAIM';
  String get claimed => isArabic ? 'تم الاستلام' : 'CLAIMED';
  String get inProgress => isArabic ? 'قيد التقدم' : 'IN PROGRESS';
  String get complete => isArabic ? 'مكتملة' : 'COMPLETE';
  String get xp => 'XP';
  String get coins => isArabic ? 'كوينز' : 'COINS';
  String get streak => isArabic ? 'سلسلة' : 'STREAK';
  String get live => isArabic ? 'مباشر' : 'LIVE';
  String get onlineArena => isArabic ? 'الساحة متاحة الآن' : 'ARENA IS LIVE';
  String get recentPerformance => isArabic ? 'أداؤك' : 'YOUR FORM';

  String get scanningArena => isArabic ? 'نبحث داخل الساحة...' : 'SCANNING THE ARENA...';
  String get syncingRank => isArabic ? 'نطابق الرتبة والمهارة' : 'MATCHING RANK & SKILL';
  String get lockingRival => isArabic ? 'تم العثور على منافس' : 'RIVAL LOCKED';
  String get fairFight => isArabic ? 'مطابقة عادلة محمية من الخادم' : 'Server-protected fair matchmaking';
  String get searchHint => isArabic
      ? 'نوسع نطاق البحث تدريجيًا للحصول على خصم مناسب بدون التضحية بعدالة المباراة.'
      : 'Search range expands gradually to find a strong rival without sacrificing match fairness.';
  String get searching => isArabic ? 'البحث عن منافس' : 'FINDING RIVAL';
  String get yourPower => isArabic ? 'قوتك' : 'YOUR POWER';
  String get estimated => isArabic ? 'وقت متوقع' : 'ESTIMATED';
  String get readyCheck => isArabic ? 'تأكيد الجاهزية' : 'READY CHECK';
  String get rival => isArabic ? 'المنافس' : 'RIVAL';
  String get you => isArabic ? 'أنت' : 'YOU';
  String get locked => isArabic ? 'تم القفل' : 'LOCKED';
  String get waiting => isArabic ? 'بانتظار الجاهزية' : 'WAITING';
  String get matchStarts => isArabic ? 'تبدأ المواجهة خلال' : 'BATTLE STARTS IN';
  String get gameSet => isArabic ? 'مجموعة الألعاب' : 'GAME SET';
  String gamesCount(int value) => isArabic ? '$value ألعاب' : '$value GAMES';
  String get rankedRules => isArabic ? 'مصنفة • RP + رهان + Coins' : 'Ranked • RP + wager + Coins';

  String get victoryHeadline => isArabic ? 'سيطرت على المواجهة' : 'ARENA DOMINATED';
  String get defeatHeadline => isArabic ? 'الجولة لم تنتهِ هنا' : 'THE RUN ISN’T OVER';
  String get tieHeadline => isArabic ? 'تعادل ناري' : 'DEAD EVEN';
  String get finalScore => isArabic ? 'النتيجة النهائية' : 'FINAL SCORE';
  String get matchRewards => isArabic ? 'حصيلة المباراة' : 'MATCH REWARDS';
  String get performance => isArabic ? 'الأداء' : 'PERFORMANCE';
  String get rematchNow => isArabic ? 'إعادة المواجهة' : 'RUN IT BACK';
  String get home => isArabic ? 'العودة للرئيسية' : 'BACK TO HOME';
  String get score => isArabic ? 'النقاط' : 'SCORE';
  String get completedGames => isArabic ? 'ألعاب مكتملة' : 'GAMES CLEARED';
  String get rankImpact => isArabic ? 'تأثير RP' : 'RP IMPACT';
  String get rewardPending => isArabic ? 'يتم تأكيد المكافآت من الخادم' : 'Rewards are being verified by the server';

  String get progression => isArabic ? 'مسار التقدم' : 'PROGRESSION';
  String get level => isArabic ? 'المستوى' : 'LEVEL';
  String get seasonPath => isArabic ? 'مسار الموسم' : 'SEASON PATH';
  String get missions => isArabic ? 'المهام' : 'MISSIONS';
  String get achievements => isArabic ? 'الإنجازات' : 'ACHIEVEMENTS';
  String get seasonPass => isArabic ? 'بطاقة الموسم' : 'SEASON PASS';
  String get daily => isArabic ? 'يومية' : 'DAILY';
  String get weekly => isArabic ? 'أسبوعية' : 'WEEKLY';
  String get rewardReady => isArabic ? 'مكافأة جاهزة' : 'REWARD READY';

  String mission(String id) => switch (id) {
        'daily_play_3' => isArabic ? 'ادخل الساحة 3 مرات' : 'Enter the arena 3 times',
        'daily_win_1' => isArabic ? 'حقق انتصارًا اليوم' : 'Win a battle today',
        'daily_friend_1' => isArabic ? 'العب مباراة مع صديق' : 'Play one friend match',
        'weekly_play_30' => isArabic ? 'العب 30 مباراة هذا الأسبوع' : 'Play 30 battles this week',
        'weekly_win_15' => isArabic ? 'حقق 15 انتصارًا هذا الأسبوع' : 'Win 15 battles this week',
        'weekly_friend_5' => isArabic ? 'العب 5 مباريات مع الأصدقاء' : 'Play 5 friend matches',
        _ => isArabic ? 'مهمة تنافسية' : 'Competitive mission',
      };
}
