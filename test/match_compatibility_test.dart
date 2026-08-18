import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/match/domain/match_compatibility.dart';

void main() {
  test('match registry must exactly match the app registry', () {
    expect(
      MatchCompatibility.supportsRegistry(
        matchRegistryVersion: 2,
        appRegistryVersion: 2,
      ),
      isTrue,
    );
    expect(
      MatchCompatibility.supportsRegistry(
        matchRegistryVersion: 1,
        appRegistryVersion: 2,
      ),
      isFalse,
    );
  });
}
