# Final APK validation — 2026-08-19

Repository: `mahmoud1xxxx1-bit/3minutes`
Package: `com.threeminutes.game`
Firebase project: `minutes-d7dfc`

## Source provenance

- Runtime source base validated for the APK: main commit `225a02e5ca02c15c60d742d8fbbedb6e1900083b`.
- Temporary APK trigger branch: `validation/final-apk-r2`.
- Temporary trigger head: `5aa5d1dc195cd510f53ad9288e4b8062fc561921`.
- The trigger branch differs from the runtime base only by the CI marker `.ci-apk-trigger` used to start the dedicated APK workflow.
- Pull request #71 was marker-only and was closed without merge after successful validation.
- Later documentation commits on `main` do not change the APK runtime code.

## GitHub Actions evidence

Workflow: `APK Validation`
Run ID: `32227715972`
Job: `validate-apk`
Result: **SUCCESS**

All required stages completed successfully:

1. Checkout — PASS
2. Node 22 setup — PASS
3. Cloud Functions dependencies — PASS
4. Build and test Cloud Functions — PASS
5. Java 21 / Firebase emulator setup — PASS
6. Firestore rules and security validation — PASS
7. Flutter setup — PASS
8. Stable debug signing key restore — PASS
9. Debug signing fingerprint verification — PASS
10. Flutter dependency resolution — PASS
11. `flutter analyze` — PASS
12. `flutter test` — PASS
13. Android debug APK build — PASS
14. Generated Google OAuth resource verification — PASS
15. APK certificate verification — PASS
16. APK artifact upload — PASS

## Artifact

- Artifact ID: `9356279815`
- Artifact name: `3minutes-final-debug-apk`
- Artifact ZIP size: `80,523,495` bytes
- GitHub artifact digest: `sha256:5407a5714daa6205fe58a5200cf17f491b44b63e2e4c5b14632ddaa5ffbaa6ca`
- Created: `2026-08-19T07:31:31Z`
- Expires: `2026-08-26T07:31:25Z`

The downloaded artifact ZIP reproduced the same SHA-256 digest locally:

`5407a5714daa6205fe58a5200cf17f491b44b63e2e4c5b14632ddaa5ffbaa6ca`

## APK file

Extracted file: `app-debug.apk`

- APK size: `158,825,508` bytes
- APK SHA-256: `67361714d6d92bc93f4886ea6a546b5419c15322655ec6874d1235aa49871e02`

The user-delivery copy is named:

`3minutes-final-2026-08-19-debug.apk`

and has the same APK SHA-256 value above.

## Signing / OAuth validation

The workflow restored and verified the stable debug signing identity before build, then independently verified the certificate embedded in the produced APK.

Expected stable debug signing fingerprints enforced by CI:

- SHA-1: `9D:0C:AE:8A:CE:E4:97:46:EE:C8:1F:16:E6:B1:F1:7A:33:65:B9:EA`
- SHA-256: `4B:A2:BA:D2:AD:8F:B2:70:C0:F7:BA:B6:11:07:BA:6F:EE:33:2A:09:20:C9:50:39:CB:0E:83:BA:5D:FF:85:30`

The generated Google Services resources were verified to contain the expected web OAuth client ID used by the application.

## Important deployment boundary

This APK is a **validated debug build**, not evidence that Blaze-only production services are deployed.

`AppConfig.backendPhase` remains `spark`. Therefore trusted server-authority features such as production Ranked settlement, Quick authority, economy purchases, live leaderboard, Premium entitlement verification, and related Cloud Functions must remain gated until the reviewed Firebase Functions/Rules are deployed on Blaze and Google Play products are configured.

## Final APK validation status

**PASS** — the final debug APK was built, analyzed, tested, security-validated, OAuth-validated, certificate-validated, uploaded, downloaded, extracted, and SHA-256 verified.
