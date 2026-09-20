import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Arabic and English localization keys stay in parity', () {
    final english = jsonDecode(
      File('lib/l10n/app_en.arb').readAsStringSync(),
    ) as Map<String, dynamic>;
    final arabic = jsonDecode(
      File('lib/l10n/app_ar.arb').readAsStringSync(),
    ) as Map<String, dynamic>;

    Set<String> messageKeys(Map<String, dynamic> source) => source.keys
        .where((key) => !key.startsWith('@'))
        .toSet();

    expect(messageKeys(arabic), messageKeys(english));
  });

  test('localization contains both required locales', () {
    final english = jsonDecode(
      File('lib/l10n/app_en.arb').readAsStringSync(),
    ) as Map<String, dynamic>;
    final arabic = jsonDecode(
      File('lib/l10n/app_ar.arb').readAsStringSync(),
    ) as Map<String, dynamic>;

    expect(english['@@locale'], 'en');
    expect(arabic['@@locale'], 'ar');
  });
}
