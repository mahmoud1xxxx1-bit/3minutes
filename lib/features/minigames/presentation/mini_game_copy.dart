import 'package:flutter/widgets.dart';

class MiniGameCopy {
  const MiniGameCopy._(this.isArabic);

  factory MiniGameCopy.fromContext(BuildContext context) {
    return MiniGameCopy._(
      Localizations.localeOf(context).languageCode.toLowerCase() == 'ar',
    );
  }

  final bool isArabic;

  String title(String gameId) => switch (gameId) {
        'find_differences' => isArabic ? 'البحث عن الفروق' : 'Find Differences',
        'follow_the_cup' => isArabic ? 'تتبع الكوب' : 'Follow the Cup',
        'key_escape' => isArabic ? 'مفتاح الهروب' : 'Key Escape',
        'level_devil' => isArabic ? 'مستوى الشيطان' : 'Level Devil',
        'mirror_control' => isArabic ? 'تحكم المرايا' : 'Mirror Control',
        'mole_strike' => isArabic ? 'ضرب السنجاب' : 'Mole Strike',
        'ninja_slice' => isArabic ? 'نينجا الفواكه' : 'Ninja Slice',
        'onet_connect' => isArabic ? 'توصيل الاشكال' : 'Onet Connect',
        'path_rush' => isArabic ? 'اختيار المسار' : 'Path Rush',
        'traffic_loop' => isArabic ? 'المرور المعقد' : 'Traffic Loop',
        'hidden_pigeon' => isArabic ? 'حمامة متخفية' : 'Hidden Pigeon',
        _ => isArabic ? 'لعبة مصغرة' : 'Mini-Game',
      };

  String get tapTarget => isArabic ? 'اضغط على الهدف' : 'Tap the target';
  String get moleStrikeInstruction => isArabic
      ? 'اضرب السنجاب الحقيقي بسرعة وتجنب المخادع'
      : 'Hit the real squirrel quickly and avoid the decoy';
  String get moleStrikeHits => isArabic ? 'الإصابات' : 'Hits';
  String get followCupInstruction => isArabic
      ? 'شاهد الكرة تحت الكأس ثم تابع التبديلات حتى النهاية'
      : 'Watch the ball, then follow the cup until the swaps end';
  String get followCupCorrect => isArabic ? 'الصحيح' : 'Correct';
  String get pathRushInstruction => isArabic
      ? 'اعرف طعام الشخصية ثم اختر بداية الخط الذي يصل إليه'
      : 'Find the character food, then choose the path that reaches it';
  String get pathRushRound => isArabic ? 'الجولة' : 'Round';
  String get pathRushChoose => isArabic ? 'اختر 1 أو 2 أو 3' : 'Choose 1, 2, or 3';
  String get findDifferencesInstruction => isArabic
      ? 'قارن الصورتين واضغط مكان كل اختلاف'
      : 'Compare both images and tap each difference';
  String get findDifferencesFound => isArabic ? 'وجدت' : 'Found';
  String get findDifferencesMistakes => isArabic ? 'الأخطاء' : 'Mistakes';
  String get findDifferencesTime => isArabic ? 'الوقت' : 'Time';
  String get findOdd => isArabic ? 'اختر الشكل المختلف' : 'Find the odd one';
  String get howMany => isArabic ? 'كم عددها؟' : 'How many?';

  String get hiddenPigeonInstruction =>
      isArabic ? 'ابحث عن الحمامة المخفية' : 'Find the hidden pigeon';

  String matchSymbol(String symbol) =>
      isArabic ? 'طابق $symbol' : 'Match $symbol';
  String tapColor(String color) =>
      isArabic ? 'اضغط $color' : 'Tap $color';
  String get memoryInstruction =>
      isArabic ? 'تذكر واضغط 1 ← 5' : 'Remember and tap 1 → 5';
  String get orderInstruction =>
      isArabic ? 'اضغط 1 ← 5' : 'Tap 1 → 5';
  String get swipeDirection =>
      isArabic ? 'اسحب في هذا الاتجاه' : 'Swipe in this direction';
  String get tapNow => isArabic ? 'اضغط!' : 'TAP!';
  String get wait => isArabic ? 'انتظر...' : 'Wait...';

  List<String> get colors => isArabic
      ? const ['أحمر', 'أزرق', 'أخضر', 'أصفر']
      : const ['RED', 'BLUE', 'GREEN', 'YELLOW'];
}
