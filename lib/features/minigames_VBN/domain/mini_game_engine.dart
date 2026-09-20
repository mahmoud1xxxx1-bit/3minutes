enum MiniGameEngine {
  choice,
  target,
  sequence,
  swipe,
  reaction,
}

class MiniGameEngineRegistry {
  const MiniGameEngineRegistry._();

  static const Map<String, MiniGameEngine> byGameId = {
    'path_rush': MiniGameEngine.choice,
    'mole_strike': MiniGameEngine.target,
    'find_differences': MiniGameEngine.target,
    'follow_the_cup': MiniGameEngine.sequence,
    'mirror_control': MiniGameEngine.target,
    'traffic_loop': MiniGameEngine.target,
    'level_devil': MiniGameEngine.reaction,
  };

  static MiniGameEngine engineFor(String gameId) {
    final engine = byGameId[gameId];
    if (engine == null) throw StateError('No mini-game engine registered for $gameId.');
    return engine;
  }
}
