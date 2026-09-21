import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EconomyManager {
  static const int normalMaxLives = 10;
  static const int vipMaxLives = 30;
  static const int rewardedLifeDailyLimit = 10;

  static bool _isVipActive(SharedPreferences prefs) {
    final vip = prefs.getBool('ld_vip') ?? false;
    final expiry = prefs.getInt('ld_vip_expiry') ?? 0;
    if (!vip) return false;
    if (expiry > 0 && DateTime.now().millisecondsSinceEpoch >= expiry) return false;
    return true;
  }

  static int _refillMinutesForNextLife(int lives) =>
      (normalMaxLives - lives).clamp(1, normalMaxLives) + 2;

  static Future<void> _ensureVipDailyMail(SharedPreferences prefs) async {
    if (!_isVipActive(prefs)) return;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastDailyDate = prefs.getString('ld_vip_last_daily_date') ?? '';
    if (lastDailyDate == today) return;
    final mails = prefs.getStringList('ld_mailbox') ?? [];
    mails.insert(0, jsonEncode({
      'id': 'vip_daily_$today',
      'type': 'vip_daily_economy',
      'title': 'VIP Daily Reward',
      'body': 'Daily VIP reward: 10,000 Gold + 50 Gems.',
      'gold': 10000,
      'gems': 50,
      'claimed': false,
    }));
    mails.insert(0, jsonEncode({
      'id': 'vip_lives_$today',
      'type': 'vip_lives',
      'title': 'VIP 30 Lives',
      'body': '30 Lives are ready when your current lives reach zero.',
      'lives': vipMaxLives,
      'claimed': false,
    }));
    if (mails.length > 100) mails.removeRange(100, mails.length);
    await prefs.setStringList('ld_mailbox', mails);
    await prefs.setString('ld_vip_last_daily_date', today);
  }

  static Future<void> activateWeeklyVip() async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch;
    await prefs.setBool('ld_vip', true);
    await prefs.setInt('ld_vip_expiry', expiry);
    await prefs.setInt('ld_lives', vipMaxLives);
    await prefs.remove('ld_zero_timestamp');
    await prefs.remove('ld_refill_started_at');
    await prefs.remove('ld_refill_minutes');
    await prefs.setInt('ld_gems', (prefs.getInt('ld_gems') ?? 0) + 500);
    await _ensureVipDailyMail(prefs);
  }

  static Future<void> deductLife() async {
    final prefs = await SharedPreferences.getInstance();
    final maxLives = _isVipActive(prefs) ? vipMaxLives : normalMaxLives;
    var lives = prefs.getInt('ld_lives') ?? maxLives;
    if (lives <= 0) return;
    lives--;
    await prefs.setInt('ld_lives', lives);
    if (lives == 0) {
      if (_isVipActive(prefs)) {
        await prefs.remove('ld_refill_started_at');
        await prefs.remove('ld_refill_minutes');
      } else {
        await prefs.setInt('ld_refill_started_at', DateTime.now().millisecondsSinceEpoch);
        await prefs.setInt('ld_refill_minutes', 3);
      }
    }
  }

  static Future<Map<String, dynamic>> checkEconomy() async {
    final prefs = await SharedPreferences.getInstance();
    await _ensureVipDailyMail(prefs);
    final isVip = _isVipActive(prefs);
    final maxLives = isVip ? vipMaxLives : normalMaxLives;
    var lives = prefs.getInt('ld_lives') ?? maxLives;
    int? targetTime;

    if (!isVip && lives < normalMaxLives) {
      var startedAt = prefs.getInt('ld_refill_started_at');
      var refillMinutes = prefs.getInt('ld_refill_minutes');
      if (startedAt == null || refillMinutes == null) {
        startedAt = DateTime.now().millisecondsSinceEpoch;
        refillMinutes = _refillMinutesForNextLife(lives);
        await prefs.setInt('ld_refill_started_at', startedAt);
        await prefs.setInt('ld_refill_minutes', refillMinutes);
      }
      final elapsed = DateTime.now().millisecondsSinceEpoch - startedAt;
      if ((elapsed ~/ 60000) >= refillMinutes) {
        lives = (lives + 1).clamp(0, normalMaxLives);
        await prefs.setInt('ld_lives', lives);
        if (lives < normalMaxLives) {
          final nextMinutes = _refillMinutesForNextLife(lives);
          final cycleStart = startedAt + (refillMinutes * 60000);
          await prefs.setInt('ld_refill_started_at', cycleStart);
          await prefs.setInt('ld_refill_minutes', nextMinutes);
        } else {
          await prefs.remove('ld_refill_started_at');
          await prefs.remove('ld_refill_minutes');
        }
      }
      if (lives < normalMaxLives) {
        final currentStart = prefs.getInt('ld_refill_started_at')!;
        final currentMinutes = prefs.getInt('ld_refill_minutes')!;
        targetTime = currentStart + (currentMinutes * 60000);
      }
    }

    final mails = prefs.getStringList('ld_mailbox') ?? [];
    final unreadCount = mails.where((m) {
      try { return jsonDecode(m)['claimed'] != true; } catch (_) { return true; }
    }).length;

    return {
      'lives': lives,
      'maxLives': maxLives,
      'targetTime': targetTime,
      'gold': prefs.getInt('ld_gold') ?? 0,
      'gems': prefs.getInt('ld_gems') ?? 0,
      'unreadMail': unreadCount,
      'isVip': isVip,
    };
  }

  static Future<bool> claimVipLifeMail(int index) async {
    final prefs = await SharedPreferences.getInstance();
    if (!_isVipActive(prefs)) return false;
    final mails = prefs.getStringList('ld_mailbox') ?? [];
    if (index < 0 || index >= mails.length) return false;
    final mail = jsonDecode(mails[index]) as Map<String, dynamic>;
    if (mail['type'] != 'vip_lives' || mail['claimed'] == true) return false;
    final lives = prefs.getInt('ld_lives') ?? vipMaxLives;
    if (lives > 0) return false;
    await prefs.setInt('ld_lives', vipMaxLives);
    await prefs.remove('ld_refill_started_at');
    await prefs.remove('ld_refill_minutes');
    mail['claimed'] = true;
    mails[index] = jsonEncode(mail);
    await prefs.setStringList('ld_mailbox', mails);
    return true;
  }

  static Future<Map<String, dynamic>> processWin(int round) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> completed = prefs.getStringList('ld_completed_rounds') ?? [];
    final roundStr = round.toString();
    final isFirst = !completed.contains(roundStr);
    final diff = (round - 1) % 3;
    int gems = 0;
    int gold = 0;
    if (isFirst) {
      gems = diff == 0 ? 1 : diff == 1 ? 3 : 5;
      completed.add(roundStr);
      await prefs.setStringList('ld_completed_rounds', completed);
    } else {
      gold = diff == 0 ? 100 : diff == 1 ? 250 : 500;
    }
    if (gems > 0) await prefs.setInt('ld_gems', (prefs.getInt('ld_gems') ?? 0) + gems);
    if (gold > 0) await prefs.setInt('ld_gold', (prefs.getInt('ld_gold') ?? 0) + gold);
    return {'gems': gems, 'gold': gold, 'isFirst': isFirst};
  }
}

