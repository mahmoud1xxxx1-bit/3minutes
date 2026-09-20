import 'package:flutter/foundation.dart';

import '../domain/ranked_settlement_player.dart';

class RankPromotionEvent {
  const RankPromotionEvent({
    required this.matchId,
    required this.settlement,
  });

  final String matchId;
  final RankedSettlementPlayer settlement;
}

class RankPromotionEvents {
  const RankPromotionEvents._();

  static final ValueNotifier<RankPromotionEvent?> current =
      ValueNotifier<RankPromotionEvent?>(null);

  static final Set<String> _shownMatchIds = <String>{};

  static void publish(String matchId, RankedSettlementPlayer settlement) {
    if (!settlement.promoted || matchId.isEmpty || _shownMatchIds.contains(matchId)) {
      return;
    }
    _shownMatchIds.add(matchId);
    current.value = RankPromotionEvent(matchId: matchId, settlement: settlement);
  }

  static void dismiss() {
    current.value = null;
  }

  @visibleForTesting
  static void resetForTesting() {
    _shownMatchIds.clear();
    current.value = null;
  }
}
