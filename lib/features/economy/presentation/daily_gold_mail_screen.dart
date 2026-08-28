import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../data/competitive_economy_service.dart';
import '../data/competitive_wallet_repository.dart';

class DailyGoldMailScreen extends StatefulWidget {
  const DailyGoldMailScreen({
    super.key,
    required this.uid,
    required this.walletRepository,
    required this.economyService,
  });

  final String uid;
  final CompetitiveWalletRepository walletRepository;
  final CompetitiveEconomyService economyService;

  @override
  State<DailyGoldMailScreen> createState() => _DailyGoldMailScreenState();
}

class _DailyGoldMailScreenState extends State<DailyGoldMailScreen> {
  bool _claiming = false;

  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      backgroundColor: GameColors.backgroundDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(ar ? 'البريد' : 'Mail'),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: GameColors.arenaGradient),
        child: StreamBuilder(
          stream: widget.walletRepository.watchTodayMail(widget.uid),
          builder: (context, snapshot) {
            final mail = snapshot.data;
            final claimed = mail?.claimed == true;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(GameSpacing.lg),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: GameColors.surfaceGlass,
                    borderRadius: BorderRadius.circular(GameRadii.panel),
                    border: Border.all(color: GameColors.rewardGold),
                    boxShadow: GameShadows.goldGlow,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.mark_email_unread_rounded,
                          size: 62, color: GameColors.rewardGoldBright),
                      const SizedBox(height: 16),
                      Text(
                        ar ? 'ذهب يومي' : 'DAILY GOLD',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '1,000 GOLD',
                        style: TextStyle(
                          color: GameColors.rewardGoldBright,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        claimed
                            ? (ar ? 'تم الاستلام اليوم' : 'Claimed today')
                            : (ar ? 'متاح اليوم' : 'Available today'),
                        style: const TextStyle(color: GameColors.textSoft),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: claimed || _claiming
                              ? null
                              : () async {
                                  setState(() => _claiming = true);
                                  try {
                                    final result = await widget.economyService.claimDailyGold();
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          ar
                                              ? 'تم إضافة ${result.amount} GOLD'
                                              : '${result.amount} GOLD added',
                                        ),
                                      ),
                                    );
                                  } finally {
                                    if (mounted) setState(() => _claiming = false);
                                  }
                                },
                          style: FilledButton.styleFrom(
                            backgroundColor: GameColors.wagerGold,
                            foregroundColor: GameColors.backgroundDeep,
                          ),
                          child: Text(
                            claimed
                                ? (ar ? 'تم الاستلام' : 'CLAIMED')
                                : _claiming
                                    ? (ar ? 'جارٍ الاستلام…' : 'CLAIMING…')
                                    : (ar ? 'استلام' : 'CLAIM'),
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
