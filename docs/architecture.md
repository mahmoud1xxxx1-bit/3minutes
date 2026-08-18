# 3 Minutes — Architecture

## Product constraints

- Android first.
- Flutter application with a lightweight classic UI.
- Firebase Spark initially.
- Google Sign-In only.
- Fixed match duration: 180 seconds.
- Default match size: 8 mini-games.
- Mini-games never access Firebase directly.
- No game engine unless a future mini-game genuinely requires one.

## Blaze-ready boundary

The app must not know whether a sensitive operation is implemented directly with Firebase Spark-era services or later through Cloud Functions.

When Blaze is enabled, result validation, ranked points, seasonal rewards, economy writes, and anti-cheat checks move behind a server-authoritative backend boundary without rewriting the mini-games or UI.

## Three build sections

1. Foundation: Firebase, Google Sign-In, player profile, home shell, security rules.
2. Multiplayer core: matchmaking, synchronized 3-minute match, deterministic seed, mini-game SDK, results and rematch.
3. Competition and launch: ranking, 30-day seasons, stars, cosmetics, Blaze authority, content expansion toward 100 mini-games.

## Mini-game isolation rule

A mini-game receives deterministic configuration and a seed, then returns a normalized result. It must not read or write authentication, Firestore, ranking, season, shop, or economy data directly.
