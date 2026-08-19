# Closeout documentation index

- `project-master-closeout.md` — master project closeout reference.
- `field-qa-2026-08-19.md` — latest physical-device findings, remediation and replacement APK evidence; supersedes older visual/audio assumptions where they conflict.
- `economy-scale-audit-2026-08-19.md` — latest economy, scale, cost, abuse and Premium/Prestige clarification audit.
- `final-system-audit-checklist.md` — system-wide audit checklist.
- `closeout-audit-2026-08-19.md` — detailed earlier verification ledger covering every user-facing subsystem and deployment boundary; historical claims superseded by later Field-QA/economy audits where explicitly noted.
- `final-apk-validation-2026-08-19.md` — earlier final APK provenance, CI run, artifact, hashes, signing and OAuth evidence; the latest replacement APK evidence is additionally recorded in `field-qa-2026-08-19.md`.
- `premium-season-pass-policy.md` — authoritative Premium Season Pass policy and entitlement rules, including the approved gameplay-earned five-Star maximum.
- `quick-mode-policy.md` — Quick Match policy, rewards and authority boundaries.
- `cosmetics-policy.md` — cosmetic economy and ownership rules.
- `season-progression-policy.md` — season progression / Stars policy.
- `season-system-closeout.md` — season implementation closeout.
- `rank-system-closeout.md` — rank/prestige implementation closeout.
- `rank-emblems-final-validation.md` — approved rank emblem validation record.
- `blaze-activation-checklist.md` — external production activation steps.
- `cloud-functions-contracts.md` — trusted server callable/function contracts.

## Precedence rule

When an older broad closeout conflicts with a later subsystem-specific audit, use the later dated/specialized document. In particular:

- Premium Season Pass may expose up to five permanent Prestige Stars per season only through verified Premium access plus gameplay milestones at levels 6/12/18/24/30. The Stars are not granted merely for payment and are never spent as currency.
- The current avatar runtime is the Field-QA vector implementation, not the older low-resolution atlas runtime.
- The latest replacement APK validation/provenance is recorded in `field-qa-2026-08-19.md`.

Temporary CI pull requests used for validation are marker-only and must be closed without merge.