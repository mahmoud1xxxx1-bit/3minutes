import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/economy_manager.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('normal account starts at 10/10', () async {
    final state = await EconomyManager.checkEconomy();
    expect(state['lives'], 10);
    expect(state['maxLives'], 10);
    expect(state['isVip'], false);
  });

  test('zero lives starts a three-minute refill', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ld_lives', 0);
    await EconomyManager.checkEconomy();
    expect(prefs.getInt('ld_refill_minutes'), 3);
  });

  test('rewarded life grants one life and enforces ten-per-day limit', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ld_lives', 0);
    for (var i = 0; i < 10; i++) {
      expect(await EconomyManager.grantRewardedLife(), true);
      await prefs.setInt('ld_lives', 0);
    }
    expect(await EconomyManager.grantRewardedLife(), false);
  });

  test('VIP activation grants 30 lives and 500 gems', () async {
    final prefs = await SharedPreferences.getInstance();
    await EconomyManager.activateWeeklyVip();
    expect(prefs.getInt('ld_lives'), 30);
    expect(prefs.getInt('ld_gems'), 500);
    expect(prefs.getBool('ld_vip'), true);
  });

  test('VIP life mailbox only claims at zero lives', () async {
    final prefs = await SharedPreferences.getInstance();
    await EconomyManager.activateWeeklyVip();
    await prefs.setString('ld_vip_last_daily_date', '2000-01-01');
    await EconomyManager.checkEconomy();
    final mails = prefs.getStringList('ld_mailbox')!;
    final vipLife = mails.firstWhere((raw) => raw.contains('"type":"vip_lives"'));
    final id = RegExp(r'"id":"([^"]+)"').firstMatch(vipLife)!.group(1)!;
    expect(await EconomyManager.claimVipLifeMailById(id), false);
    await prefs.setInt('ld_lives', 0);
    expect(await EconomyManager.claimVipLifeMailById(id), true);
    expect(prefs.getInt('ld_lives'), 30);
  });
}
