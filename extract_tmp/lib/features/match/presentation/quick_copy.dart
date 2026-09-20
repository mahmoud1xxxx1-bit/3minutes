import 'package:flutter/widgets.dart';

class QuickCopy {
  const QuickCopy(this.isArabic);

  final bool isArabic;

  static QuickCopy of(BuildContext context) =>
      QuickCopy(Localizations.localeOf(context).languageCode == 'ar');

  String get title => isArabic ? 'اللعب السريع' : 'Quick Play';
  String get subtitle => isArabic
      ? '1 ضد 1 عشوائي • بدون RP • مكافآت Coins وXP'
      : 'Random 1v1 • No RP • Coins & XP rewards';
  String get unavailable => isArabic
      ? 'اللعب السريع سيعمل عند تفعيل الخادم الآمن.'
      : 'Quick Play activates with the secure server backend.';
}
