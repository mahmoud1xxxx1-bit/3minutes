import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../../economy/presentation/avatar_artwork.dart';
import '../data/competitive_leaderboard_repository.dart';

class CompetitiveLeaderboardScreen extends StatefulWidget {
  const CompetitiveLeaderboardScreen({
    super.key,
    required this.uid,
    required this.repository,
  });

  final String uid;
  final CompetitiveLeaderboardRepository repository;

  @override
  State<CompetitiveLeaderboardScreen> createState() => _CompetitiveLeaderboardScreenState();
}

class _CompetitiveLeaderboardScreenState extends State<CompetitiveLeaderboardScreen> {
  CompetitiveLeaderboardType _type = CompetitiveLeaderboardType.rp;

  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      backgroundColor: GameColors.backgroundDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(ar ? 'لوحة المتصدرين' : 'LEADERBOARDS'),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: GameColors.arenaGradient),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SegmentedButton<CompetitiveLeaderboardType>(
                segments: const [
                  ButtonSegment(
                    value: CompetitiveLeaderboardType.rp,
                    label: Text('RP RANKING'),
                    icon: Icon(Icons.military_tech_rounded),
                  ),
                  ButtonSegment(
                    value: CompetitiveLeaderboardType.gold,
                    label: Text('GOLD RANKING'),
                    icon: Icon(Icons.workspace_premium_rounded),
                  ),
                ],
                selected: <CompetitiveLeaderboardType>{_type},
                onSelectionChanged: (selection) => setState(() => _type = selection.first),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<CompetitiveLeaderboardEntry>>(
                stream: widget.repository.watchTop(_type),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final entries = snapshot.data!;
                  if (entries.isEmpty) {
                    return Center(
                      child: Text(ar ? 'لا توجد نتائج بعد' : 'No rankings yet'),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final mine = entry.uid == widget.uid;
                      final medalColor = switch (index) {
                        0 => GameColors.rewardGoldBright,
                        1 => GameColors.rankSilver,
                        2 => GameColors.rankBronze,
                        _ => GameColors.textSoft,
                      };
                      return Container(
                        margin: const EdgeInsets.only(bottom: 9),
                        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                        decoration: BoxDecoration(
                          color: mine ? GameColors.accentSoft : GameColors.surfaceGlass,
                          borderRadius: BorderRadius.circular(GameRadii.card),
                          border: Border.all(
                            color: mine ? GameColors.accentBright : GameColors.surfaceStrong,
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 34,
                              child: Text(
                                '#${index + 1}',
                                style: TextStyle(color: medalColor, fontWeight: FontWeight.w900),
                              ),
                            ),
                            AvatarArtwork(
                              avatarId: entry.avatarId,
                              size: 42,
                              borderRadius: 21,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                            Text(
                              '${entry.value} ${_type == CompetitiveLeaderboardType.rp ? 'RP' : 'GOLD'}',
                              style: TextStyle(
                                color: _type == CompetitiveLeaderboardType.rp
                                    ? GameColors.rp
                                    : GameColors.rewardGoldBright,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
