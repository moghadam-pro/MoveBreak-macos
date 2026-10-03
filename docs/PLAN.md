# Delivery plan and stage log

## Stage 1 — Review and preservation (2026-10-03)

Completed: fetched and reviewed the Windows repository, architecture document, README, timer, activity monitor, models, persistence, exercise catalog, presentation state, notification service, and application wiring. Confirmed Xcode 27.0 and Swift 6.4 on Apple Silicon. Created and pushed the annotated backup tag before removing Windows files from main. Created an additional full-history bundle beside the project.

Outcome: Windows MVP architecture is reasonable, with specific timer, eye-rule, migration, and statistics weaknesses documented in WINDOWS-REVIEW.md. Git transport can push even though `gh` authentication reports an invalid token. The user selected macOS 14+ and an English interface for the first version.

## Stage 2 — Native foundation (2026-10-03)

Completed: SwiftPM package, pure active-time policy, deterministic policy tests, version file, native source/resource layout, migrated 18 exercises and artwork, independent eye reminders, manual presentation deferral, and local versioned atomic storage.

Outcome: no external runtime or library is required. English UI scope is explicit; existing Persian and Spanish content is retained. Schema errors preserve original data.

## Stage 3 — Native experience (2026-10-03)

Completed: dashboard, countdown, pause/resume/restart, manual break, illustrated break panel, completed/skipped/snoozed records, recent history and seven-day chart, exercise library, settings, system/light/dark appearance, menu bar, idle/sleep/session monitoring, notification authorization, and launch-at-login integration.

Outcome: a locally buildable macOS app. Automatic fullscreen/meeting detection and complete translated interfaces remain future work. See TESTING.md for actual verification and manual checks that are still required.

## Stage 4 — Packaging and handoff (2026-10-03)

Completed: app-bundle build script, generated macOS icon, ad-hoc signing, macOS CI workflow, SemVer policy, changelog, architecture decisions, release/testing/privacy documentation, and README.

Outcome: first native development baseline 0.1.0. Public signing/notarization is blocked by the absence of a valid code-signing identity on this machine. No signed public release is claimed.

## Next milestones

1. Verify native UX and permissions on macOS 14 and the current OS, including lock/unlock, Focus, login, multiple displays, and accessibility.
2. Extract persistence/platform adapters as needed; add storage migrations and fault-injection tests before changing the schema.
3. Add full interface localization and RTL layout; retain original exercise translations.
4. Assess automatic fullscreen/meeting deferral with minimal permissions and explicit user controls.
5. Confirm asset license, configure Developer ID signing and notarization, validate Intel/universal packaging, and prepare a distributable release.
