import 'package:flutter_test/flutter_test.dart';
import 'package:game/core/config/app_config.dart';

void main() {
  test('server-authoritative features stay disabled on Spark', () {
    expect(AppConfig.rankedAuthorityEnabled, isFalse);
    expect(AppConfig.economyPurchasesEnabled, isFalse);
    expect(AppConfig.liveLeaderboardEnabled, isFalse);
  });
}
