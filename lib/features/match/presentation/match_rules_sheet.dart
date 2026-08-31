import 'package:flutter/material.dart';

import '../../../core/theme/arena_ui.dart';
import '../../../core/theme/design_tokens.dart';

Future<void> showMatchRulesSheet(BuildContext context) {
  final isArabic =
      Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _MatchRulesSheet(isArabic: isArabic),
  );
}

class _MatchRulesSheet extends StatelessWidget {
  const _MatchRulesSheet({required this.isArabic});

  final bool isArabic;

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: FractionallySizedBox(
        heightFactor: .9,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          decoration: const BoxDecoration(
            color: GameColors.backgroundDeep,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: GameColors.surfaceStrong,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: GameColors.accentBright,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      t('قواعد المواجهة', 'MATCH RULES'),
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: t('إغلاق', 'Close'),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Expanded(
                child: ListView(
                  children: [
                    _RuleCard(
                      number: '1',
                      title: t('الرهان قبل البحث', 'CHOOSE YOUR WAGER'),
                      body: t(
                        'اختر تحدي 100 أو 250 أو 500 Gold. يبحث النظام عن خصم اختار نفس القيمة، وعند تكوين المباراة يحجز الخادم الرهان من الطرفين. مثال: تحدي 250 = مجموع رهان 500 Gold.',
                        'Choose a 100, 250, or 500 Gold challenge. You are matched with a rival who chose the same amount, and the server locks both wagers when the match is created. Example: 250 each = 500 Gold pool.',
                      ),
                    ),
                    _RuleCard(
                      number: '2',
                      title: t('اختيار الألعاب', 'GAME SELECTION'),
                      body: t(
                        'كل لاعب يختار لعبتين. تصبح المواجهة 4 ألعاب مختلفة، ويقفل الخادم الألعاب الأربع قبل السماح بزر جاهز.',
                        'Each player chooses 2 games. The match becomes 4 different games, locked by the server before Ready is allowed.',
                      ),
                    ),
                    _RuleCard(
                      number: '3',
                      title: t('قاعدة 1000 نقطة', 'THE 1000-POINT RULE'),
                      body: t(
                        'إكمال هدف أي لعبة بالكامل = 1000 نقطة. عدم إكمال الهدف قبل انتهاء وقت اللعبة = 0 نقطة. لا توجد معادلات سرية أو خصم نقاط بسبب الأخطاء.',
                        'Fully completing any game objective = 1000 points. Failing to complete it before its time ends = 0 points. There are no hidden formulas or mistake-based point deductions.',
                      ),
                    ),
                    _RuleCard(
                      number: '4',
                      title: t('الجولات والقلوب والأخطاء', 'ROUNDS, LIVES & MISTAKES'),
                      body: t(
                        'مثال Level Devil: يجب إنهاء الجولات الثلاث للحصول على 1000 نقطة. الموت والقلوب والأخطاء تظهر في تقرير الأداء لتعرف أين تحتاج إلى التحسن، لكنها لا تخصم نقاطًا.',
                        'Example — Level Devil: all 3 rounds must be cleared to earn 1000 points. Deaths, lives and mistakes appear in the performance report so you can improve, but they never deduct points.',
                      ),
                    ),
                    _RuleCard(
                      number: '5',
                      title: t('إذا انتهى وقت المواجهة', 'WHEN MATCH TIME EXPIRES'),
                      body: t(
                        'نقارن أولًا مجموع النقاط. إذا تساوت، يتقدم اللاعب الذي وصل إلى لعبة أبعد في ترتيب الألعاب الأربع. مثال: لاعب في اللعبة 2 والآخر وصل إلى اللعبة 3؛ اللاعب الثاني أعلى.',
                        'Total points are compared first. If tied, the player who reached a later game in the locked 4-game order is ahead. Example: game 2 loses to reaching game 3.',
                      ),
                    ),
                    _RuleCard(
                      number: '6',
                      title: t('الفشل المتعادل', 'DOUBLE FAIL'),
                      body: t(
                        'إذا تساوت النقاط وكان اللاعبان عند نفس مرحلة التقدم عند انتهاء الوقت ولم يكملا المواجهة، لا نستخدم الأخطاء أو الموت أو الزمن لاختراع فائز. تسجل Double Fail.',
                        'If points and progress are tied when time expires and neither player completed the match, mistakes, deaths and time do not invent a winner. The result is Double Fail.',
                      ),
                      warning: true,
                    ),
                    _RuleCard(
                      number: '7',
                      title: t('الوقت يحسم فقط 4000–4000', 'TIME ONLY BREAKS 4000–4000'),
                      body: t(
                        'إذا أكمل اللاعبان الألعاب الأربع بنجاح وأصبح المجموع 4000 مقابل 4000، يفوز صاحب مجموع وقت الإكمال الأقل.',
                        'If both players correctly clear all 4 games for 4000–4000, the lower total completion time wins.',
                      ),
                    ),
                    _RuleCard(
                      number: '8',
                      title: t('تعادل ناجح كامل', 'EXACT SUCCESSFUL DRAW'),
                      body: t(
                        'إذا أكمل اللاعبان الأربع ألعاب بـ4000 نقطة وتساوى مجموع الوقت أيضًا تمامًا، لا توجد عقوبة فشل ولا فائز عشوائي: يعاد رهان Gold كاملًا للطرفين.',
                        'If both players finish all 4 games at 4000 and total completion time is also exactly equal, there is no failure penalty and no random winner: both Gold wagers are fully refunded.',
                      ),
                    ),
                    _RuleCard(
                      number: '9',
                      title: t('عقوبة Double Fail', 'DOUBLE-FAIL PENALTY'),
                      body: t(
                        'في Double Fail يعاد لكل لاعب 50% فقط من Gold الذي راهن به ويخصم 50% كعقوبة فشل. مثال: رهان 500 Gold لكل لاعب → يعود 250 Gold لكل لاعب.',
                        'In a Double Fail, each player receives only 50% of their wager back and loses 50% as the failure penalty. Example: 500 Gold wager each → 250 Gold returned to each.',
                      ),
                      warning: true,
                    ),
                    _RuleCard(
                      number: '10',
                      title: t('الفائز والـGold', 'WINNER & GOLD'),
                      body: t(
                        'عند وجود فائز يستلم كامل مجموع الرهان. مثال: رهان 250 لكل لاعب → الفائز يستلم 500 Gold؛ صافي ربحه +250 والخاسر صافي خسارته -250.',
                        'When there is a winner, they receive the full wager pool. Example: 250 each → winner receives 500 Gold; net +250 for the winner and -250 for the loser.',
                      ),
                    ),
                    _RuleCard(
                      number: '11',
                      title: t('تقرير واضح بعد المباراة', 'CLEAR POST-MATCH REPORT'),
                      body: t(
                        'يظهر التقرير نتيجة كل لعبة، هل اكتملت أم فشلت، التقدم، الوقت، الأخطاء والموت أو القلوب عند وجودها، ثم سبب النتيجة وGold وRP وXP وCoins التي تمت تسويتها.',
                        'The report shows each game result, completion or failure, progress, time, mistakes, deaths or lives when applicable, then the decision reason and settled Gold, RP, XP and Coins.',
                      ),
                    ),
                    const SizedBox(height: 8),
                    ArenaCard(
                      accent: GameColors.success,
                      child: Text(
                        t(
                          'مثال: A أنهى لعبتين = 2000 نقطة وتوقف في اللعبة 3. B أنهى لعبتين = 2000 نقطة لكنه وصل إلى اللعبة 4، إذن B يفوز. وإذا كان الاثنان عند اللعبة 3 بنفس 2000 نقطة عند انتهاء الوقت فهي Double Fail.',
                          'Example: A clears 2 games = 2000 and stops in game 3. B also has 2000 but reaches game 4, so B wins. If both are in game 3 at the same 2000 when time ends, it is a Double Fail.',
                        ),
                        style: const TextStyle(
                          color: GameColors.textSoft,
                          height: 1.55,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({
    required this.number,
    required this.title,
    required this.body,
    this.warning = false,
  });

  final String number;
  final String title;
  final String body;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final color = warning ? GameColors.warning : GameColors.accentBright;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ArenaCard(
        accent: color,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Text(
                number,
                style: TextStyle(color: color, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    body,
                    style: const TextStyle(
                      color: GameColors.textSoft,
                      height: 1.5,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
