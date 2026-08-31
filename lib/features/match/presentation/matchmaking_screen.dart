import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/cosmic_background.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../profile/domain/player_profile.dart';
import '../data/match_backend.dart';
import '../domain/match_ticket.dart';
import 'match_room_screen.dart';

class MatchmakingScreen extends StatefulWidget {
  const MatchmakingScreen({
    super.key,
    required this.profile,
    required this.matchBackend,
    this.wagerCoins = 0,
  });

  final PlayerProfile profile;
  final MatchBackend matchBackend;
  final int wagerCoins;

  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen> {
  String? _error;
  bool _joining = true;
  bool _leaving = false;
  bool _navigating = false;
  int _effectiveWagerCoins = 0;

  @override
  void initState() {
    super.initState();
    _effectiveWagerCoins = widget.wagerCoins;
    WidgetsBinding.instance.addPostFrameCallback((_) => _prepareJoin());
  }

  Future<void> _prepareJoin() async {
    if (!mounted) return;
    if (widget.matchBackend is RankedWagerMatchBackend && _effectiveWagerCoins <= 0) {
      final wager = await _askForWager();
      if (!mounted) return;
      if (wager == null) {
        Navigator.of(context).pop();
        return;
      }
      setState(() => _effectiveWagerCoins = wager);
    }
    await _join();
  }

  Future<int?> _askForWager() async {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    final controller = TextEditingController();
    String? validation;
    final result = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          icon: const Icon(Icons.toll_rounded),
          title: Text(ar ? 'حدد الرهان' : 'Choose your wager'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                ar
                    ? 'سيتم خصم الرهان فقط عند العثور على لاعب يختار نفس القيمة. الفائز يحصل على مجموع الرهانين.'
                    : 'Your wager is held only when a player with the same wager is matched. The winner receives the full pot.',
              ),
              const SizedBox(height: GameSpacing.md),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: ar ? 'Coins للرهان' : 'Wager Coins',
                  errorText: validation,
                  prefixIcon: const Icon(Icons.monetization_on_outlined),
                ),
                onSubmitted: (_) {
                  final value = int.tryParse(controller.text);
                  if (value == null || value <= 0) {
                    setDialogState(() {
                      validation = ar ? 'أدخل قيمة أكبر من صفر' : 'Enter a value greater than zero';
                    });
                    return;
                  }
                  Navigator.of(dialogContext).pop(value);
                },
              ),
              const SizedBox(height: GameSpacing.sm),
              Text(
                ar
                    ? 'إذا لم يكن رصيدك كافيًا سيرفض السيرفر الرهان ولن يتم خصم أي Coins.'
                    : 'If your balance is insufficient, the server rejects the wager and no Coins are deducted.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(ar ? 'إلغاء' : 'Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = int.tryParse(controller.text);
                if (value == null || value <= 0) {
                  setDialogState(() {
                    validation = ar ? 'أدخل قيمة أكبر من صفر' : 'Enter a value greater than zero';
                  });
                  return;
                }
                Navigator.of(dialogContext).pop(value);
              },
              child: Text(ar ? 'ابدأ البحث' : 'Find opponent'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _join() async {
    if (mounted) {
      setState(() {
        _joining = true;
        _error = null;
      });
    }
    try {
      final backend = widget.matchBackend;
      if (backend is RankedWagerMatchBackend) {
        if (_effectiveWagerCoins <= 0) {
          throw StateError('Ranked wager is required.');
        }
        await backend.joinQueueWithWager(
          widget.profile,
          wagerCoins: _effectiveWagerCoins,
        );
      } else {
        await backend.joinQueue(widget.profile);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = AppLocalizations.of(context).matchmakingFailed);
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  Future<void> _cancel() async {
    if (_leaving || _navigating) return;
    setState(() => _leaving = true);
    try {
      await widget.matchBackend.leaveQueue(widget.profile.uid);
    } finally {
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _openMatch(String matchId) {
    if (_navigating) return;
    _navigating = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => MatchRoomScreen(
            matchId: matchId,
            uid: widget.profile.uid,
            matchBackend: widget.matchBackend,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _cancel();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(l10n.findingOpponent),
          automaticallyImplyLeading: false,
        ),
        body: CosmicBackground(
          child: SafeArea(
            top: false,
            child: StreamBuilder<MatchTicket?>(
              stream: widget.matchBackend.watchTicket(widget.profile.uid),
              builder: (context, snapshot) {
                final ticket = snapshot.data;
                if (ticket?.status == MatchTicketStatus.matched && ticket?.matchId != null) {
                  _openMatch(ticket!.matchId!);
                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                    GameSpacing.lg,
                    GameSpacing.md,
                    GameSpacing.lg,
                    GameSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(),
                      Center(
                        child: SizedBox.square(
                          dimension: 230,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 230,
                                height: 230,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [Color(0x2426E3EE), Color(0x007957F5)],
                                  ),
                                ),
                              ),
                              SizedBox.square(
                                dimension: 194,
                                child: CircularProgressIndicator(
                                  strokeWidth: 4,
                                  color: GameColors.accentBright,
                                  backgroundColor: GameColors.surfaceStrong,
                                ),
                              ),
                              Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: GameColors.surfaceGlass,
                                  border: Border.all(
                                    color: GameColors.violet.withValues(alpha: 0.45),
                                  ),
                                  boxShadow: GameShadows.primaryGlow,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _joining
                                          ? Icons.sync_rounded
                                          : Icons.rocket_launch_rounded,
                                      color: GameColors.accentBright,
                                      size: 36,
                                    ),
                                    const SizedBox(height: GameSpacing.sm),
                                    Text(
                                      '3:00',
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                            fontWeight: FontWeight.w900,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: GameSpacing.xl),
                      Text(
                        _joining ? l10n.joiningQueue : l10n.searchingForPlayer,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      if (_effectiveWagerCoins > 0) ...[
                        const SizedBox(height: GameSpacing.sm),
                        Center(
                          child: Chip(
                            avatar: const Icon(Icons.toll_rounded, size: 18),
                            label: Text(
                              ar
                                  ? 'الرهان $_effectiveWagerCoins • الجائزة ${_effectiveWagerCoins * 2}'
                                  : 'Wager $_effectiveWagerCoins • Pot ${_effectiveWagerCoins * 2}',
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: GameSpacing.sm),
                      Text(
                        l10n.fairMatchMessage,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                      ),
                      const SizedBox(height: GameSpacing.lg),
                      if (_error != null)
                        CosmicPanel(
                          child: Column(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: GameColors.danger),
                              const SizedBox(height: GameSpacing.sm),
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: GameColors.danger),
                              ),
                              const SizedBox(height: GameSpacing.sm),
                              OutlinedButton(
                                onPressed: _joining ? null : _join,
                                child: Text(l10n.tryAgain),
                              ),
                            ],
                          ),
                        )
                      else
                        CosmicPanel(
                          child: Row(
                            children: [
                              const Icon(Icons.shield_outlined, color: GameColors.violet),
                              const SizedBox(width: GameSpacing.sm),
                              Expanded(
                                child: Text(
                                  l10n.fairMatchMessage,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const Spacer(),
                      OutlinedButton.icon(
                        onPressed: _leaving ? null : _cancel,
                        icon: const Icon(Icons.close_rounded),
                        label: Text(_leaving ? l10n.leaving : l10n.cancel),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
