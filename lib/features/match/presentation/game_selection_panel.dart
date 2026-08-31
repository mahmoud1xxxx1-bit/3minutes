import 'package:flutter/material.dart';

import '../../../core/theme/arena_ui.dart';
import '../../../core/theme/design_tokens.dart';
import '../../minigames/data/game_registry.dart';
import '../data/match_backend.dart';
import '../domain/match_session.dart';
import 'match_rules_sheet.dart';

class GameSelectionPanel extends StatefulWidget {
  const GameSelectionPanel({
    super.key,
    required this.match,
    required this.uid,
    required this.backend,
  });

  final MatchSession match;
  final String uid;
  final MatchGameSelectionBackend backend;

  @override
  State<GameSelectionPanel> createState() => _GameSelectionPanelState();
}

class _GameSelectionPanelState extends State<GameSelectionPanel> {
  final Set<String> _draft = <String>{};
  bool _submitting = false;
  String? _error;

  bool get _isArabic =>
      Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';

  String _t(String ar, String en) => _isArabic ? ar : en;

  String _gameName(String id) {
    final ar = <String, String>{
      'find_differences': 'اكتشف الاختلافات',
      'follow_the_cup': 'اتبع الكأس',
      'key_escape': 'هروب المفتاح',
      'level_devil': 'Level Devil',
      'mirror_control': 'التحكم المعكوس',
      'mole_strike': 'اضرب الخلد',
      'ninja_slice': 'ضربة النينجا',
      'onet_connect': 'توصيل الأزواج',
      'path_rush': 'اندفاع المسار',
      'traffic_loop': 'حلقة المرور',
      'hidden_pigeon': 'الحمامة المخفية',
    };
    final en = <String, String>{
      'find_differences': 'Find Differences',
      'follow_the_cup': 'Follow the Cup',
      'key_escape': 'Key Escape',
      'level_devil': 'Level Devil',
      'mirror_control': 'Mirror Control',
      'mole_strike': 'Mole Strike',
      'ninja_slice': 'Ninja Slice',
      'onet_connect': 'Onet Connect',
      'path_rush': 'Path Rush',
      'traffic_loop': 'Traffic Loop',
      'hidden_pigeon': 'Hidden Pigeon',
    };
    return (_isArabic ? ar[id] : en[id]) ?? id.replaceAll('_', ' ');
  }

  Future<void> _submit() async {
    if (_draft.length != 2 || _submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await widget.backend.submitGameSelection(
        matchId: widget.match.id,
        uid: widget.uid,
        gameIds: _draft.toList(growable: false),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = _t(
          'تعذر تثبيت الاختيار. قد يكون المنافس اختار إحدى اللعبتين؛ اختر لعبتين متاحتين وحاول مجددًا.',
          'Could not lock the selection. Your rival may have taken one of these games; choose two available games and try again.',
        );
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ownLocked = widget.match.selectedGamesFor(widget.uid);
    final opponentLocked = widget.match.opponentSelectedGames(widget.uid);

    if (widget.match.gameSelectionLocked) {
      return ArenaCard(
        accent: GameColors.success,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _t('تم تثبيت الألعاب الأربع', 'FOUR GAMES LOCKED'),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: widget.match.lockedGameIds
                  .map((id) => ArenaPill(label: _gameName(id), color: GameColors.success))
                  .toList(growable: false),
            ),
          ],
        ),
      );
    }

    if (ownLocked.length == 2) {
      return ArenaCard(
        accent: GameColors.warning,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lock_rounded, color: GameColors.warning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _t('اختيارك مثبت — بانتظار المنافس', 'YOUR PICKS ARE LOCKED — WAITING FOR RIVAL'),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                IconButton(
                  tooltip: _t('القواعد', 'Rules'),
                  onPressed: () => showMatchRulesSheet(context),
                  icon: const Icon(Icons.info_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: ownLocked
                  .map((id) => ArenaPill(label: _gameName(id), color: GameColors.accentBright))
                  .toList(growable: false),
            ),
          ],
        ),
      );
    }

    return ArenaCard(
      accent: GameColors.accentBright,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _t('اختر لعبتين', 'CHOOSE 2 GAMES'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _t(
                        'أنت تختار لعبتين والمنافس يختار لعبتين. لا تتكرر أي لعبة.',
                        'You choose 2 games and your rival chooses 2. No game can repeat.',
                      ),
                      style: const TextStyle(color: GameColors.muted, fontSize: 10),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: _t('القواعد', 'Rules'),
                onPressed: () => showMatchRulesSheet(context),
                icon: const Icon(Icons.info_outline_rounded, color: GameColors.accentBright),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: GameRegistry.games.map((game) {
                  final taken = opponentLocked.contains(game.id);
                  final selected = _draft.contains(game.id);
                  return FilterChip(
                    label: Text(_gameName(game.id)),
                    selected: selected,
                    onSelected: taken || _submitting
                        ? null
                        : (value) {
                            setState(() {
                              _error = null;
                              if (value) {
                                if (_draft.length < 2) _draft.add(game.id);
                              } else {
                                _draft.remove(game.id);
                              }
                            });
                          },
                    avatar: taken
                        ? const Icon(Icons.lock_outline_rounded, size: 16)
                        : selected
                            ? const Icon(Icons.check_rounded, size: 16)
                            : null,
                  );
                }).toList(growable: false),
              ),
            ),
          ),
          if (opponentLocked.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              _t('اختيارات المنافس محجوزة ولا يمكن تكرارها.', 'Rival picks are reserved and cannot be repeated.'),
              style: const TextStyle(color: GameColors.warning, fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: GameColors.danger, fontSize: 10)),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _draft.length == 2 && !_submitting ? _submit : null,
              icon: _submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.lock_rounded),
              label: Text(
                _submitting
                    ? _t('جارٍ التثبيت...', 'LOCKING...')
                    : _t('تثبيت اللعبتين (${_draft.length}/2)', 'LOCK 2 GAMES (${_draft.length}/2)'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
