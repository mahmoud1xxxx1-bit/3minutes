# MiniGame Integration Contract (Phase 6)

This contract defines the idempotent, atomic, and safe way to add any future mini-game to the 3 Minutes ecosystem **WITHOUT** modifying the Match Engine, Settlement Engine, Economy (RP/Gold/XP), or Leaderboards.

## Flow: Template -> Manifest -> GameContract -> Registry

### 1. Template & Implementation
Every mini-game MUST accept a MiniGameConfig (which provides a deterministic seed and difficulty) and a ValueChanged<MiniGameResult> onComplete callback.
Games must NEVER communicate directly with Firebase, the Matchmaking system, or the Profile system. They are pure functions: (Config, UserInput) -> Result.
- **Score:** Must be between 0 and 10,000.
- **Accuracy:** Must be a float between 0.0 and 1.0.
- **Duration:** Must accurately reflect the active playtime (minimum 0s, maximum 180s).
- **Idempotency:** Calling onComplete multiple times is safely ignored by the host, but games should ideally call it exactly once.

### 2. Manifest (gameId)
To register a game, define its manifest in lib/features/minigames/domain/mini_game_contract.dart (or via GameRegistry.games).
You must assign it a unique gameId and a MiniGameCategory (reaction, logic, memory, precision) to balance the ranked sequence.

### 3. GameContract
The MiniGameResult object is the definitive boundary. The Match Engine accepts this object, calculates elapsed time and validity, and generates MiniGameEvidence.
- Adding a game requires **0 modifications** to lib/features/multiplayer/, unctions/src/match.ts, or unctions/src/settlement.ts.

### 4. Registry
1. Add the game to GameRegistry.games in lib/features/minigames/data/game_registry.dart.
2. Add the engine mapping in MiniGameEngineRegistry.byGameId.
3. Add the Widget route in MiniGameHost.build().
4. (Server) Add the exact same ID and Category to APPROVED_GAMES in unctions/src/registry.ts.
5. Increment REGISTRY_VERSION on both client and server if the change is pushed to production (to prevent version mismatch attacks).

### 5. Contract Tests
Any newly added game will automatically be tested by mini_game_integration_contract_test.dart to ensure it resolves safely via MiniGameHost and does not crash the UI.
