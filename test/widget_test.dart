import 'package:flutter_test/flutter_test.dart';
import 'package:game/core/config/app_config.dart';
import 'package:game/features/profile/domain/player_name_rules.dart';
import 'package:game/features/profile/domain/player_profile.dart';

void main() {
  test('match configuration stays fixed at three minutes', () {
    expect(AppConfig.matchDuration, const Duration(minutes: 3));
    expect(AppConfig.gamesPerMatch, 8);
  });

  test('player profile map keeps safe defaults', () {
    final profile = PlayerProfile.fromMap('uid-1', const {});

    expect(profile.uid, 'uid-1');
    expect(profile.gameName, 'Player');
    expect(profile.level, 1);
    expect(profile.rankPoints, 0);
    expect(profile.stars, 0);
  });

  test('player name normalization trims and collapses spaces', () {
    expect(PlayerNameRules.validate('  Player   One  '), 'Player One');
    expect(PlayerNameRules.validate('  لاعب   واحد  '), 'لاعب واحد');
  });

  test('player name rejects empty and symbol-only values', () {
    expect(() => PlayerNameRules.validate('   '), throwsArgumentError);
    expect(() => PlayerNameRules.validate('---'), throwsArgumentError);
    expect(() => PlayerNameRules.validate('ab'), throwsArgumentError);
  });
}
