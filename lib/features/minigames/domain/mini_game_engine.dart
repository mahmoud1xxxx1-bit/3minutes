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
    'quick_math': MiniGameEngine.choice,
    'color_match': MiniGameEngine.choice,
    'odd_one_out': MiniGameEngine.choice,
    'shape_count': MiniGameEngine.choice,
    'symbol_pair': MiniGameEngine.choice,
    'tap_target': MiniGameEngine.target,
    'mole_strike': MiniGameEngine.target,
    'number_order': MiniGameEngine.sequence,
    'memory_flash': MiniGameEngine.sequence,
    'direction_swipe': MiniGameEngine.swipe,
    'reaction_stop': MiniGameEngine.reaction,
  };

  static MiniGameEngine engineFor(String gameId) {
    final engine = byGameId[gameId];
    if (engine == null) {
      throw StateError('No mini-game engine registered for $gameId.');
    }
    return engine;
  }
}
