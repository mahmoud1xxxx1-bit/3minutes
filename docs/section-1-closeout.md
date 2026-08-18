# Section 1 Closeout — Foundation

Status: CLOSED

Section 1 establishes the lightweight Android foundation for 3 Minutes. It does not implement real matchmaking, ranked competition, economy, seasons, or playable mini-games.

## Included

- Flutter Android application using package `com.threeminutes.game`.
- Firebase Core configuration for Android.
- Google Sign-In through Firebase Authentication.
- Cloud Firestore player profiles.
- Production Firestore rules that allow a player to manage only public profile fields while competitive fields remain protected.
- First-run profile creation with player name and bundled avatar selection.
- Central player-name normalization and validation.
- Duplicate-submit protection during profile creation and editing.
- Retryable profile-loading error state for connection failures.
- Home screen showing player name, level, rank points, stars, and placeholders for Play, Leaderboard, Profile, and Shop.
- Editable player profile for name and avatar only.
- Fixed match configuration contract: 3-minute matches and 8 mini-games per match.
- Lightweight architecture prepared for a later Spark-to-Blaze backend boundary.
- Automated Dart/Flutter tests and GitHub Flutter CI configuration.

## Final verification

The foundation was manually exercised on a physical Android phone and then revalidated after the closeout hardening changes:

1. Google authentication completed successfully.
2. First-run profile setup opened correctly.
3. Player name and avatar were saved to Firestore.
4. Home screen loaded the saved profile.
5. `flutter pub get` completed successfully.
6. `flutter analyze` completed with `No issues found!`.
7. `flutter test` completed with `All tests passed!` (4 tests).
8. `flutter build apk --debug` completed successfully and produced `app-debug.apk`.

Final verified closeout base before this status-only commit: `385ce29`.

## Security boundary

Clients may create their own initial profile with zeroed competitive statistics and may update only `gameName`, `avatarId`, and `updatedAt` afterward. Rank points, stars, XP, level, wins, losses, and games played are not client-editable through Firestore rules.

These competitive fields will become server-authoritative when the project moves to Blaze and Cloud Functions.

## Explicitly deferred to Section 2+

- Matchmaking queue.
- Match room and two-player synchronization.
- Deterministic match seed and game sequence.
- 3-2-1 synchronized start.
- Live 3-minute match timer.
- Disconnect/reconnect handling.
- Match results, ties, rematch, and history.
- Mini-Game SDK and GameRegistry.
- Representative playable mini-games.
- Ranked scoring, seasons, economy, shop behavior, and server-authoritative anti-cheat.

Section 1 is now frozen as the stable foundation. New gameplay and multiplayer development starts in Section 2.
