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



  test('stage rewards use the global stage id: stage 101 first clear gives gems, repeat gives gold', () async {
    final first = await EconomyManager.processWin(101);
    expect(first['isFirst'], true);
    expect(first['gems'], 3);
    expect(first['gold'], 0);

    final second = await EconomyManager.processWin(101);
    expect(second['isFirst'], false);
    expect(second['gems'], 0);
    expect(second['gold'], 1500);
  });

  test('season unlock follows 70 percent progression and staged gem prices', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ld_gems', 150);
    await prefs.setStringList('ld_completed_rounds',
      List<String>.generate(14, (i) => '\${i + 1}'));

    final state = await EconomyManager.seasonUnlockState(2);
    expect(state['requiredStages'], 14);
    expect(state['eligible'], true);
    expect(state['cost'], 150);

    expect(await EconomyManager.unlockSeason(2), true);
    expect(prefs.getInt('ld_gems'), 0);
    expect(await EconomyManager.isSeasonUnlocked(2), true);
  });

  test('gold exchange keeps the 100 Gold = 1 Gem value', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ld_gold', 1000);
    await prefs.setInt('ld_gems', 0);
    expect(await EconomyManager.exchangeGoldForGems(1), true);
    expect(prefs.getInt('ld_gold'), 0);
    expect(prefs.getInt('ld_gems'), 10);
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
