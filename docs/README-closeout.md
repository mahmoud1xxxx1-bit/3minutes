# Closeout documentation index

- `approved-avatar-rank-artwork-2026-08-19.md` — authoritative owner-approved artwork identity and production policy for all 45 Avatars and 8 competitive rank emblems.
- `artwork-restoration-progress-2026-08-19.md` — active restoration ledger; records the incomplete HD bundle upload and supersedes older claims that the vector/96px artwork is visually final.
- `owner-report-pre-device-acceptance-2026-08-19.md` — comprehensive owner-facing report covering every current game option, subsystem, deployment boundary, outstanding device gate, and priority matrix.
- `project-master-closeout.md` — master project closeout reference.
- `field-qa-2026-08-19.md` — physical-device findings and earlier remediation/APK evidence; artwork-finality claims are superseded by the two artwork-specific documents above.
- `economy-scale-audit-2026-08-19.md` — latest economy, scale, cost, abuse and Premium/Prestige clarification audit.
- `economy-simulation-matrix-2026-08-19.md` — quantitative 20/50/100/200/500-match player simulations plus million-user DAU/stress cost matrices.
- `final-system-audit-checklist.md` — system-wide audit checklist.
- `closeout-audit-2026-08-19.md` — detailed earlier verification ledger covering every user-facing subsystem and deployment boundary; historical claims superseded by later Field-QA/economy/artwork audits where explicitly noted.
- `final-apk-validation-2026-08-19.md` — earlier APK provenance, CI run, artifact, hashes, signing and OAuth evidence; these APKs are not the final artwork-accepted build.
- `premium-season-pass-policy.md` — authoritative Premium Season Pass policy and entitlement rules, including the approved gameplay-earned five-Star maximum.
- `quick-mode-policy.md` — Quick Match policy, rewards and authority boundaries.
- `cosmetics-policy.md` — cosmetic economy and ownership rules.
- `season-progression-policy.md` — season progression / Stars policy.
- `season-system-closeout.md` — season implementation closeout.
- `rank-system-closeout.md` — rank/prestige implementation closeout.
- `rank-emblems-final-validation.md` — earlier rank emblem validation record; artwork resolution/finality is superseded by the latest artwork-specific documents.
- `blaze-activation-checklist.md` — external production activation steps.
- `cloud-functions-contracts.md` — trusted server callable/function contracts.

## Precedence rule

When an older broad closeout conflicts with a later subsystem-specific audit, use the later dated/specialized document. In particular:

- `approved-avatar-rank-artwork-2026-08-19.md` is the authority for artwork identity and prohibits autonomous redesign.
- `artwork-restoration-progress-2026-08-19.md` is the authority for the current technical restoration state. The temporary vector Avatar runtime and 96px rank atlas remain non-final, and the partially committed `approved_hd_00.b64` is not a complete production asset.
- Premium Season Pass may expose up to five permanent Prestige Stars per season only through verified Premium access plus gameplay milestones at levels 6/12/18/24/30. The Stars are not granted merely for payment and are never spent as currency.
- Earlier Field-QA APK validation/provenance remains valid as historical CI evidence, but no earlier APK is the final artwork-accepted build after the owner's artwork lock.
- The latest economy/balance/cost conclusions are in `economy-scale-audit-2026-08-19.md` and `economy-simulation-matrix-2026-08-19.md`.

Temporary CI pull requests used for validation are marker-only and must be closed without merge.
