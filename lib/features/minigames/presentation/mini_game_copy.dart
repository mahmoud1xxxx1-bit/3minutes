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
        'tap_target' => isArabic ? 'اضغط الهدف' : 'Tap Target',
        'mole_strike' => isArabic ? 'اضرب السنجاب' : 'Mole Strike',
        'quick_math' => isArabic ? 'حساب سريع' : 'Quick Math',
        'color_match' => isArabic ? 'مطابقة اللون' : 'Color Match',
        'odd_one_out' => isArabic ? 'المختلف' : 'Odd One Out',
        'memory_flash' => isArabic ? 'ذاكرة سريعة' : 'Memory Flash',
        'direction_swipe' => isArabic ? 'اسحب بالاتجاه' : 'Direction Swipe',
        'number_order' => isArabic ? 'ترتيب الأرقام' : 'Number Order',
        'shape_count' => isArabic ? 'عدّ الأشكال' : 'Shape Count',
        'reaction_stop' => isArabic ? 'سرعة الاستجابة' : 'Reaction Stop',
        'symbol_pair' => isArabic ? 'طابق الرمز' : 'Symbol Pair',
        _ => isArabic ? 'لعبة مصغرة' : 'Mini-Game',
      };

  String get tapTarget => isArabic ? 'اضغط على الهدف' : 'Tap the target';
  String get moleStrikeInstruction => isArabic
      ? 'اضرب السنجاب الحقيقي بسرعة وتجنب المخادع'
      : 'Hit the real squirrel quickly and avoid the decoy';
  String get moleStrikeHits => isArabic ? 'الإصابات' : 'Hits';
  String get findOdd => isArabic ? 'اختر الشكل المختلف' : 'Find the odd one';
  String get howMany => isArabic ? 'كم عددها؟' : 'How many?';
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
