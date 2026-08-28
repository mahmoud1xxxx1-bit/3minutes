import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: GameColors.backgroundDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.mail),
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
                child: AnimatedContainer(
                  duration: GameDurations.normal,
                  width: double.infinity,
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: GameColors.surfaceGlass,
                    borderRadius: BorderRadius.circular(GameRadii.panel),
                    border: Border.all(color: claimed ? GameColors.success : GameColors.rewardGold),
                    boxShadow: claimed ? GameShadows.card : GameShadows.goldGlow,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        claimed ? Icons.mark_email_read_rounded : Icons.mark_email_unread_rounded,
                        size: 62,
                        color: claimed ? GameColors.success : GameColors.rewardGoldBright,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.dailyGold,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.dailyGoldAmount,
                        style: const TextStyle(
                          color: GameColors.rewardGoldBright,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        claimed ? l10n.claimedToday : l10n.availableToday,
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
                                      SnackBar(content: Text(l10n.goldAdded(result.amount))),
                                    );
                                  } finally {
                                    if (mounted) setState(() => _claiming = false);
                                  }
                                },
                          style: FilledButton.styleFrom(
                            backgroundColor: GameColors.wagerGold,
                            foregroundColor: GameColors.backgroundDeep,
                          ),
                          child: AnimatedSwitcher(
                            duration: GameDurations.normal,
                            child: Text(
                              claimed
                                  ? l10n.claimed
                                  : _claiming
                                      ? l10n.claiming
                                      : l10n.claim,
                              key: ValueKey('$claimed-$_claiming'),
                              style: const TextStyle(fontWeight: FontWeight.w900),
                            ),
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
