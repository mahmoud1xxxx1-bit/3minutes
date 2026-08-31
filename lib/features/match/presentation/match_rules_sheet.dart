import 'package:flutter/material.dart';

import '../../../core/theme/arena_ui.dart';
import '../../../core/theme/design_tokens.dart';

Future<void> showMatchRulesSheet(BuildContext context) {
  final isArabic = Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
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
        heightFactor: .88,
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
                  const Icon(Icons.info_outline_rounded, color: GameColors.accentBright),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      t('قواعد المواجهة', 'MATCH RULES'),
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
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
                      title: t('اختيار الألعاب', 'GAME SELECTION'),
                      body: t(
                        'كل لاعب يختار لعبتين. مجموع المواجهة 4 ألعاب، ويُقفل الاختيار قبل بدء العد التنازلي.',
                        'Each player chooses 2 games. The match contains 4 games total, locked before countdown.',
                      ),
                    ),
                    _RuleCard(
                      number: '2',
                      title: t('النقاط', 'SCORING'),
                      body: t(
                        'إكمال هدف اللعبة بالكامل = 1000 نقطة. مثال: في لعبة من 3 جولات، إنهاء الجولات الثلاث بنجاح يمنح 1000 نقطة. الموت والأخطاء لا تخصم نقاطًا؛ تُحفظ فقط في تقرير الأداء.',
                        'Fully completing a game objective = 1000 points. Example: in a 3-round game, clearing all 3 rounds awards 1000. Deaths and mistakes do not reduce points; they are kept only in the performance report.',
                      ),
                    ),
                    _RuleCard(
                      number: '3',
                      title: t('إذا انتهى الوقت قبل الإكمال', 'WHEN TIME EXPIRES'),
                      body: t(
                        'إذا فشل اللاعبان في إكمال اللعبة، نقارن آخر مرحلة صحيحة وصل إليها كل لاعب. من وصل أبعد تكون نتيجته أعلى. مثال: لاعب وصل للجولة 2 والآخر للجولة 3، صاحب الجولة 3 يتفوق.',
                        'If neither player completes the game, the last valid progress stage is compared. The player who reached farther ranks higher. Example: round 3 outranks round 2.',
                      ),
                    ),
                    _RuleCard(
                      number: '4',
                      title: t('التعادل داخل الفشل', 'FAILED-GAME TIE'),
                      body: t(
                        'إذا انتهى الوقت واللاعبان عند نفس مرحلة التقدم، تُسجل الحالة تعادل فشل. لا يتم اختراع فائز عشوائي.',
                        'If time expires with both players at the same progress stage, it is recorded as a failed-game tie. No random winner is invented.',
                      ),
                    ),
                    _RuleCard(
                      number: '5',
                      title: t('حسم المباراة', 'MATCH DECISION'),
                      body: t(
                        'بعد الألعاب الأربع تُقارن النتيجة الإجمالية. إذا تعادلت النقاط بعد إكمال الألعاب، يحسم مجموع الوقت الأقل المباراة.',
                        'After all 4 games, total score is compared. If completed-match points are tied, the lower total completion time wins.',
                      ),
                    ),
                    _RuleCard(
                      number: '6',
                      title: t('عقوبة الفشل المتعادل', 'DOUBLE-FAIL PENALTY'),
                      body: t(
                        'إذا انتهت المواجهة بحالة فشل متعادل بدون فائز وفق القواعد، يعود لكل لاعب 50% فقط من رهانه ويُخصم 50% كعقوبة فشل. مثال: رهان 500 Gold → يعود 250 Gold لكل لاعب.',
                        'If the match ends in an unresolved double-fail, each player receives only 50% of their wager back and 50% is deducted as a failure penalty. Example: 500 Gold wager → 250 Gold returned to each player.',
                      ),
                      warning: true,
                    ),
                    _RuleCard(
                      number: '7',
                      title: t('تقرير الأداء', 'PERFORMANCE REPORT'),
                      body: t(
                        'بعد المباراة تظهر لكل لاعب تفاصيل كل لعبة: الإكمال، المرحلة التي وصل إليها، الوقت، الأخطاء، مرات الموت أو القلوب عند وجودها، وسبب الفوز أو الخسارة أو التعادل.',
                        'After the match, each player sees per-game details: completion, reached stage, time, mistakes, deaths or lives when applicable, and the exact win/loss/tie reason.',
                      ),
                    ),
                    const SizedBox(height: 8),
                    ArenaCard(
                      accent: GameColors.success,
                      child: Text(
                        t(
                          'مثال كامل: لاعب A أنهى 4 ألعاب = 4000 نقطة. لاعب B أنهى 3 ألعاب فقط = أقل من A. إذا أنهى الاثنان الأربع وأصبح المجموع 4000 مقابل 4000، يفوز صاحب الوقت الإجمالي الأقل.',
                          'Full example: Player A clears all 4 games = 4000 points. Player B clears only 3 = lower result. If both finish all 4 at 4000–4000, the lower total completion time wins.',
                        ),
                        style: const TextStyle(color: GameColors.textSoft, height: 1.55, fontWeight: FontWeight.w700),
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
              child: Text(number, style: TextStyle(color: color, fontWeight: FontWeight.w900)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                  const SizedBox(height: 5),
                  Text(body, style: const TextStyle(color: GameColors.textSoft, height: 1.5, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
