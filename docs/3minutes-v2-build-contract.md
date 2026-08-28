# 3 Minutes — Competitive Shell V2 Build Contract

Status: ACTIVE
Baseline: `795dc83780fc2d90495fa2e093478b78fe41ad8b`

## Non-negotiable product rules

- Existing mini-games are not modified during the shell rebuild.
- The application is the authority around games: matchmaking, wager, session timer, score aggregation, settlement, rewards, rank, history and presentation.
- COINS remain the existing independent economy and keep their current uses.
- GOLD is a separate competitive/wager currency.
- Every player can claim 1,000 GOLD once per server day through in-game Mail.
- Supported wager tiers at launch: 180, 500 and 1,000 GOLD.
- Matchmaking pairs players on the same wager tier.
- Each player selects exactly two games. The match consists of four selected games played by both players.
- Both players must be Ready before the synchronized 3-2-1 countdown.
- The competitive session has one authoritative three-minute match clock.
- The winner receives the opponent wager (net GOLD gain), RP and COINS according to the reward policy.
- Rankings have independent GOLD and RP leaderboards.
- Rank ladder remains: Bronze, Silver, Gold, Platinum, Diamond, Master, Grand Master, Legendary, with the star concept preserved.
- The game integration layer must support adding game 17+ without changing the match engine.

## Four build sections

### 1. Application shell and economy
Build the approved premium dark competitive visual system, Home, navigation, Profile, existing COINS surfaces, GOLD wallet, Mail/daily claim, Shop surfaces and settings. Financial mutations must be auditable and idempotent.

### 2. Competition
Build wager selection, escrow/reservation, same-tier matchmaking, opponent-found state, two-game selection per player, Ready state, synchronized countdown, three-minute session, disconnect/reconnect, surrender, cancellation and settlement. No client-only settlement.

### 3. Game host and results
Define a stable game contract. Games return score/progress/completion/duration/game-specific statistics; the shell owns the match result. Add score adapters so heterogeneous games can be normalized fairly. Build detailed result presentation and match history.

### 4. Security, QA and final integration
Server-authoritative sensitive mutations, anti-double-claim/double-settlement protections, lifecycle/reconnect tests, localization/accessibility/performance QA, then integrate the final 16-game ZIP through adapters without rewriting the shell.

## Approved UX direction

Primary loop:
`Home -> Play -> Wager -> Matchmaking -> Opponent -> Pick 2 games each -> Ready -> 3-2-1 -> 3-minute battle -> Detailed result -> Rewards -> Rematch/Home`

Primary bottom navigation target:
`Home | Play | Rank | Shop | Profile`

Home prioritizes player identity/rank, COINS and GOLD balances, Mail, a dominant 3 MINUTES PLAY CTA, Rank/Leaderboards/Shop shortcuts and clear competitive status.

## Architecture boundary for future games

A future mini-game must not own wallet/RP/rank/match settlement. It integrates through a shell-owned adapter and returns a structured result. The host controls lifecycle and timing and can add/remove games through a registry without changing core competition rules.

## Safety rules

- GOLD reservation/settlement must be transactional and idempotent.
- Daily GOLD claim uses server time and an idempotency key/server-day key.
- Match rewards settle once.
- Cancellation before a valid match restores reserved GOLD.
- A confirmed surrender is a loss; disconnect policy must allow a defined reconnect grace period before forfeit.
- Draw policy and exact RP/COINS formulas remain configuration decisions and must not be hard-coded arbitrarily before approval.
