import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../domain/competitive_match_rules.dart';

class SelectableGame {
  const SelectableGame({required this.id, required this.name});
  final String id;
  final String name;
}

class GameSelectionScreen extends StatefulWidget {
  const GameSelectionScreen({
    super.key,
    required this.games,
    required this.opponentGameIds,
    required this.onConfirm,
  });

  final List<SelectableGame> games;
  final Set<String> opponentGameIds;
  final Future<void> Function(List<String>) onConfirm;

  @override
  State<GameSelectionScreen> createState() => _GameSelectionScreenState();
}

class _GameSelectionScreenState extends State<GameSelectionScreen> {
  final Set<String> _selected = <String>{};
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.backgroundDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('CHOOSE 2 GAMES  ${_selected.length}/2'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: GameColors.arenaGradient),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(GameSpacing.md),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.35,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: widget.games.length,
                itemBuilder: (context, index) {
                  final game = widget.games[index];
                  final blocked = widget.opponentGameIds.contains(game.id);
                  final selected = _selected.contains(game.id);
                  return Opacity(
                    opacity: blocked ? .3 : 1,
                    child: InkWell(
                      onTap: blocked
                          ? null
                          : () {
                              setState(() {
                                if (selected) {
                                  _selected.remove(game.id);
                                } else if (_selected.length < CompetitiveMatchRules.picksPerPlayer) {
                                  _selected.add(game.id);
                                }
                              });
                            },
                      borderRadius: BorderRadius.circular(GameRadii.card),
                      child: Container(
                        decoration: BoxDecoration(
                          color: selected ? GameColors.accentSoft : GameColors.surfaceGlass,
                          borderRadius: BorderRadius.circular(GameRadii.card),
                          border: Border.all(
                            color: selected ? GameColors.accentBright : GameColors.surfaceStrong,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(selected ? Icons.check_circle_rounded : Icons.sports_esports_rounded,
                                color: selected ? GameColors.accentBright : GameColors.textSoft,
                                size: 34),
                            const SizedBox(height: 10),
                            Text(game.name, textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: FontWeight.w800)),
                            if (blocked) const Text('OPPONENT PICK', style: TextStyle(fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(GameSpacing.md),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _selected.length != CompetitiveMatchRules.picksPerPlayer || _busy
                        ? null
                        : () async {
                            setState(() => _busy = true);
                            try {
                              await widget.onConfirm(_selected.toList(growable: false));
                            } finally {
                              if (mounted) setState(() => _busy = false);
                            }
                          },
                    child: Text(_busy ? 'CONFIRMING…' : 'LOCK PICKS'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
