import 'package:flutter/widgets.dart';

class ProgressionCopy {
  const ProgressionCopy._(this.isArabic);

  final bool isArabic;

  static ProgressionCopy of(BuildContext context) => ProgressionCopy._(
        Localizations.localeOf(context).languageCode == 'ar',
      );

  String get missions => isArabic ? 'المهمات' : 'Missions';
  String get achievements => isArabic ? 'الإنجازات' : 'Achievements';
  String get seasonPass => isArabic ? 'مسار الموسم' : 'Season Pass';
  String get daily => isArabic ? 'يومية' : 'Daily';
  String get weekly => isArabic ? 'أسبوعية' : 'Weekly';
  String get free => isArabic ? 'مجاني' : 'Free';
  String get premium => isArabic ? 'مميز' : 'Premium';
  String get seasonLevel => isArabic ? 'مستوى الموسم' : 'Season level';
  String get completed => isArabic ? 'مكتمل' : 'Completed';
  String get inProgress => isArabic ? 'قيد التقدم' : 'In progress';
  String get locked => isArabic ? 'مقفل' : 'Locked';
  String get reward => isArabic ? 'المكافأة' : 'Reward';
  String get coins => isArabic ? 'كوينز' : 'Coins';
  String get seasonXp => isArabic ? 'خبرة الموسم' : 'Season XP';
  String get claim => isArabic ? 'استلام' : 'Claim';
  String get claimed => isArabic ? 'تم الاستلام' : 'Claimed';
  String get rewardClaimed => isArabic ? 'تم استلام المكافأة' : 'Reward claimed';
  String get rewardUnavailable => isArabic
      ? 'هذه المكافأة غير متاحة للاستلام في النسخة الحالية.'
      : 'This reward is unavailable to claim in the current build.';
  String get premiumPassLocked => isArabic
      ? 'المسار المميز غير مفعل لهذا الموسم.'
      : 'Premium track is not unlocked for this season.';
  String get serverProtected => isArabic
      ? 'يتم التحقق من التقدم والمكافآت تلقائيًا للحفاظ على عدالة اللعبة.'
      : 'Progress and rewards are automatically verified to keep the game fair.';

  String mission(String id) => switch (id) {
        'daily_play_3' => isArabic ? 'العب 3 مباريات' : 'Play 3 matches',
        'daily_win_1' => isArabic ? 'حقق فوزًا واحدًا' : 'Win 1 match',
        'daily_friend_1' => isArabic ? 'العب مباراة مع صديق' : 'Play 1 friend match',
        'weekly_play_30' => isArabic ? 'العب 30 مباراة' : 'Play 30 matches',
        'weekly_win_15' => isArabic ? 'حقق 15 فوزًا' : 'Win 15 matches',
        'weekly_friend_5' => isArabic ? 'العب 5 مباريات مع الأصدقاء' : 'Play 5 friend matches',
        _ => id,
      };

  String achievement(String id) => switch (id) {
        'first_win' => isArabic ? 'الفوز الأول' : 'First Victory',
        'wins_10' => isArabic ? '10 انتصارات' : '10 Victories',
        'wins_100' => isArabic ? '100 انتصار' : '100 Victories',
        'wins_500' => isArabic ? '500 انتصار' : '500 Victories',
        'matches_1000' => isArabic ? 'ألف مباراة' : '1,000 Matches',
        'streak_10' => isArabic ? 'سلسلة 10 انتصارات' : '10 Win Streak',
        'friend_matches_50' => isArabic ? '50 مباراة أصدقاء' : '50 Friend Matches',
        'six_player_wins_10' => isArabic ? '10 انتصارات في مباراة 6 لاعبين' : '10 Six-Player Wins',
        'seasons_10' => isArabic ? 'إكمال 10 مواسم' : 'Complete 10 Seasons',
        'prestige_100' => isArabic ? 'امتلاك 100 نجمة هيبة' : 'Own 100 Prestige Stars',
        _ => id,
      };
}
