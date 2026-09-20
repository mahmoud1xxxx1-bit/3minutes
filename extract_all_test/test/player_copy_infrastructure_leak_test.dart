import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('player-facing presentation copy does not expose infrastructure names', () {
    final roots = <Directory>[
      Directory('lib/features'),
      Directory('lib/l10n'),
    ];
    final forbidden = RegExp(
      r'''(['"]).*\b(Spark|Blaze|Firebase|Firestore|Cloud Functions)\b.*\1''',
      caseSensitive: false,
    );
    final leaks = <String>[];

    for (final root in roots) {
      if (!root.existsSync()) continue;
      for (final entity in root.listSync(recursive: true)) {
        if (entity is! File) continue;
        final path = entity.path.replaceAll('\\', '/');
        final isPresentation = path.contains('/presentation/');
        final isArb = path.endsWith('.arb');
        if (!isPresentation && !isArb) continue;
        final text = entity.readAsStringSync();
        for (final line in text.split('\n')) {
          if (forbidden.hasMatch(line)) leaks.add('$path: ${line.trim()}');
        }
      }
    }

    expect(
      leaks,
      isEmpty,
      reason: 'Infrastructure/deployment names must never be visible in player-facing copy:\n${leaks.join('\n')}',
    );
  });
}
