import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EconomyManager {
  static const int normalMaxLives = 10;
  static const int vipMaxLives = 30;
  static const int rewardedLifeDailyLimit = 10;
  static const String _rewardedDateKey = 'ld_rewarded_life_date';
  static const String _rewardedCountKey = 'ld_rewarded_life_count';

  static bool _isVipActive(SharedPreferences prefs) {
    final vip = prefs.getBool('ld_vip') ?? false;
    final expiry = prefs.getInt('ld_vip_expiry') ?? 0;
    if (!vip) return false;
    if (expiry > 0 && DateTime.now().millisecondsSinceEpoch >= expiry) return false;
    return true;
  }

  // Normal refill cadence: the first life takes 3 minutes, then each
  // following life takes one minute longer, until the normal 10-life cap.
  static int _refillMinutesForNextLife(int lives) =>
      (lives + 3).clamp(3, 12);

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

    if (mails.length > 100) {
      mails.removeRange(100, mails.length);
    }

    await prefs.setStringList('ld_mailbox', mails);
    await prefs.setString('ld_vip_last_daily_date', today);
  }

  static Future<void> activateWeeklyVip() async {
    final prefs = await SharedPreferences.getInstance();

    final alreadyActive = _isVipActive(prefs);
    if (alreadyActive) return;

    final expiry = DateTime.now()
        .add(const Duration(days: 7))
        .millisecondsSinceEpoch;

    await prefs.setBool('ld_vip', true);
    await prefs.setInt('ld_vip_expiry', expiry);
    await prefs.setInt('ld_lives', vipMaxLives);
    await prefs.remove('ld_zero_timestamp');
    await prefs.remove('ld_refill_started_at');
    await prefs.remove('ld_refill_minutes');

    // The 500-Gem activation bonus is granted once when VIP is activated.
    await prefs.setInt(
      'ld_gems',
      (prefs.getInt('ld_gems') ?? 0) + 500,
    );

    // Daily VIP mailbox rewards begin with the next daily cycle; activation
    // itself is already compensated by the immediate 500-Gem bonus.
    await prefs.setString(
      'ld_vip_last_daily_date',
      DateTime.now().toIso8601String().substring(0, 10),
    );
  }

  static Future<void> deductLife() async {
    final prefs = await SharedPreferences.getInstance();
    final isVip = _isVipActive(prefs);
    final maxLives = isVip ? vipMaxLives : normalMaxLives;
    var lives = prefs.getInt('ld_lives') ?? maxLives;

    // Keep the stored value consistent with the currently active cap.
    if (lives > maxLives) {
      lives = maxLives;
      await prefs.setInt('ld_lives', lives);
    }

    if (lives <= 0) return;

    lives--;
    await prefs.setInt('ld_lives', lives);

    if (lives == 0) {
      if (isVip) {
        await prefs.remove('ld_refill_started_at');
        await prefs.remove('ld_refill_minutes');
      } else {
        await prefs.setInt(
          'ld_refill_started_at',
          DateTime.now().millisecondsSinceEpoch,
        );
        await prefs.setInt('ld_refill_minutes', 3);
      }
    }
  }

  static Future<bool> buyLivesWithGems(int quantity) async {
    if (quantity <= 0) return false;
    final prefs = await SharedPreferences.getInstance();
    final isVip = _isVipActive(prefs);
    final maxLives = isVip ? vipMaxLives : normalMaxLives;
    final lives = (prefs.getInt('ld_lives') ?? maxLives).clamp(0, maxLives);
    final gems = prefs.getInt('ld_gems') ?? 0;
    final actual = quantity.clamp(0, maxLives - lives);
    final cost = actual * 50;
    if (actual <= 0 || gems < cost) return false;
    await prefs.setInt('ld_gems', gems - cost);
    await prefs.setInt('ld_lives', lives + actual);
    return true;
  }

  static Future<bool> exchangeGoldForGems(int quantity) async {
    if (quantity <= 0) return false;
    final prefs = await SharedPreferences.getInstance();
    final cost = quantity * 1000;
    final gold = prefs.getInt('ld_gold') ?? 0;
    if (gold < cost) return false;
    await prefs.setInt('ld_gold', gold - cost);
    await prefs.setInt('ld_gems', (prefs.getInt('ld_gems') ?? 0) + quantity * 10);
    return true;
  }

  static Future<bool> grantRewardedLife() async {
    final prefs = await SharedPreferences.getInstance();
    final isVip = _isVipActive(prefs);
    final maxLives = isVip ? vipMaxLives : normalMaxLives;
    final lives = (prefs.getInt('ld_lives') ?? maxLives).clamp(0, maxLives);
    if (lives >= maxLives) return false;

    final today = DateTime.now().toIso8601String().substring(0, 10);
    var used = prefs.getInt(_rewardedCountKey) ?? 0;
    if (prefs.getString(_rewardedDateKey) != today) used = 0;
    if (!isVip && used >= rewardedLifeDailyLimit) return false;

    await prefs.setInt('ld_lives', lives + 1);
    await prefs.setString(_rewardedDateKey, today);
    await prefs.setInt(_rewardedCountKey, used + 1);
    if (lives == 0 && !isVip) {
      await prefs.setInt('ld_refill_started_at', DateTime.now().millisecondsSinceEpoch);
      await prefs.setInt('ld_refill_minutes', 4);
    }
    return true;
  }

  static Future<Map<String, dynamic>> checkEconomy() async {
    final prefs = await SharedPreferences.getInstance();
    await _ensureVipDailyMail(prefs);

    final isVip = _isVipActive(prefs);
    final maxLives = isVip ? vipMaxLives : normalMaxLives;
    var lives = prefs.getInt('ld_lives') ?? maxLives;

    // A normal account cannot keep the VIP-only 30-life capacity after VIP
    // has expired. Preserve the normal cap for the active economy state.
    if (!isVip && lives > normalMaxLives) {
      lives = normalMaxLives;
      await prefs.setInt('ld_lives', lives);
    }

    int? targetTime;

    if (!isVip && lives < normalMaxLives) {
      int startedAt = prefs.getInt('ld_refill_started_at') ?? 0;
      int refillMinutes = prefs.getInt('ld_refill_minutes') ?? 0;

      if (startedAt == 0 || refillMinutes == 0) {
        startedAt = DateTime.now().millisecondsSinceEpoch;
        refillMinutes = _refillMinutesForNextLife(lives);
        await prefs.setInt('ld_refill_started_at', startedAt);
        await prefs.setInt('ld_refill_minutes', refillMinutes);
      }

      // Catch up every elapsed refill while the app was closed, rather than
      // granting only one life per check.
      var now = DateTime.now().millisecondsSinceEpoch;
      while (lives < normalMaxLives &&
          now - startedAt >= refillMinutes * 60000) {
        startedAt += refillMinutes * 60000;
        lives++;
        if (lives >= normalMaxLives) break;
        refillMinutes = _refillMinutesForNextLife(lives);
      }

      await prefs.setInt('ld_lives', lives);

      if (lives >= normalMaxLives) {
        await prefs.remove('ld_refill_started_at');
        await prefs.remove('ld_refill_minutes');
      } else {
        await prefs.setInt('ld_refill_started_at', startedAt);
        await prefs.setInt('ld_refill_minutes', refillMinutes);
        targetTime = startedAt + refillMinutes * 60000;
      }
    }

    final mails = prefs.getStringList('ld_mailbox') ?? [];
    final unreadCount = mails.where((raw) {
      try {
        return jsonDecode(raw)['claimed'] != true;
      } catch (_) {
        return true;
      }
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

  static Future<bool> claimVipLifeMailById(String mailId) async {
    final prefs = await SharedPreferences.getInstance();
    if (!_isVipActive(prefs)) return false;

    final mails = prefs.getStringList('ld_mailbox') ?? [];
    final index = mails.indexWhere((raw) {
      try {
        return jsonDecode(raw)['id'] == mailId;
      } catch (_) {
        return false;
      }
    });
    if (index < 0) return false;

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

  // Kept for compatibility with existing callers while the mailbox UI is
  // migrated to ID-based claims.
  static Future<bool> claimVipLifeMail(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final mails = prefs.getStringList('ld_mailbox') ?? [];
    if (index < 0 || index >= mails.length) return false;

    try {
      final id = (jsonDecode(mails[index]) as Map<String, dynamic>)['id'];
      if (id is! String || id.isEmpty) return false;
      return claimVipLifeMailById(id);
    } catch (_) {
      return false;
    }
  }

  static const List<int> seasonUnlockGemCosts = <int>[
    0,
    0,
    150,
    400,
    900,
    1600,
    2450,
  ];

  static int seasonStartStage(int season) =>
      season == 6 ? 101 : ((season - 1) * 20) + 1;

  static int seasonStageCount(int season) => season == 6 ? 75 : 20;

  static Future<int> completedStagesInSeason(int season) async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getStringList('ld_completed_rounds') ?? <String>[];
    final start = seasonStartStage(season);
    final end = start + seasonStageCount(season) - 1;
    return completed.where((raw) {
      final id = int.tryParse(raw);
      return id != null && id >= start && id <= end;
    }).length;
  }

  static Future<bool> isSeasonUnlocked(int season) async {
    if (season <= 1) return true;
    if (season > 6) return false;
    final previousCompleted = await completedStagesInSeason(season - 1);
    final required = (seasonStageCount(season - 1) * 70 + 99) ~/ 100;
    if (previousCompleted < required) return false;

    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('ld_season_${season}_unlocked') ?? false;
  }

  static Future<Map<String, dynamic>> seasonUnlockState(int season) async {
    if (season <= 1) {
      return {'unlocked': true, 'eligible': true, 'requiredStages': 0, 'completedStages': 0, 'cost': 0};
    }
    final completed = await completedStagesInSeason(season - 1);
    final required = (seasonStageCount(season - 1) * 70 + 99) ~/ 100;
    final prefs = await SharedPreferences.getInstance();
    final unlocked = prefs.getBool('ld_season_${season}_unlocked') ?? false;
    return {
      'unlocked': unlocked,
      'eligible': completed >= required,
      'requiredStages': required,
      'completedStages': completed,
      'cost': seasonUnlockGemCosts[season],
      'gems': prefs.getInt('ld_gems') ?? 0,
    };
  }

  static Future<bool> unlockSeason(int season) async {
    if (season <= 1 || season > 6) return season == 1;
    final state = await seasonUnlockState(season);
    if (state['unlocked'] == true || state['eligible'] != true) return false;
    final cost = state['cost'] as int;
    final prefs = await SharedPreferences.getInstance();
    final gems = prefs.getInt('ld_gems') ?? 0;
    if (gems < cost) return false;
    await prefs.setInt('ld_gems', gems - cost);
    await prefs.setBool('ld_season_${season}_unlocked', true);
    return true;
  }

  /// Settles the reward for a globally numbered stage (1..175).
  ///
  /// First clear: Gems according to the stage's 3-stage reward cycle.
  /// Repeat clear: Gold according to the same cycle.
  /// The global stage id is intentional: Season 6 stage 101 must not be
  /// treated as local round 1.
  static Future<Map<String, dynamic>> processWin(int stageId) async {
    if (stageId < 1) {
      throw ArgumentError.value(stageId, 'stageId', 'Must be >= 1.');
    }
    final prefs = await SharedPreferences.getInstance();
    final completed =
        prefs.getStringList('ld_completed_rounds') ?? <String>[];
    final stageKey = stageId.toString();
    final isFirst = !completed.contains(stageKey);
    final season = stageId <= 100 ? ((stageId - 1) ~/ 20) + 1 : 6;
    final seasonStart = seasonStartStage(season);
    // Difficulty/reward cycle restarts at the beginning of every season:
    // Easy -> Medium -> Hard. Season 6 therefore starts at stage 101 as Easy.
    final diff = (stageId - seasonStart) % 3;

    int gems = 0;
    int gold = 0;

    if (isFirst) {
      // First-clear gems: Easy 1 / Medium 3 / Hard 5.
      gems = diff == 0 ? 1 : diff == 1 ? 3 : 5;
      completed.add(stageKey);
      await prefs.setStringList('ld_completed_rounds', completed);
    } else {
      // Repeat/farming reward scales by season while preserving the
      // agreed Season 1 values and the 100 Gold = 1 Gem exchange rate.
      final base = diff == 0 ? 250 : diff == 1 ? 500 : 750;
      gold = base * season;
    }

    if (gems > 0) {
      await prefs.setInt(
        'ld_gems',
        (prefs.getInt('ld_gems') ?? 0) + gems,
      );
    }
    if (gold > 0) {
      await prefs.setInt(
        'ld_gold',
        (prefs.getInt('ld_gold') ?? 0) + gold,
      );
    }

    return {
      'gems': gems,
      'gold': gold,
      'isFirst': isFirst,
    };
  }
}
