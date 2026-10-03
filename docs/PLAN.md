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
3. Have native speakers review the five-language interface and exercise translations.
4. Keep automatic fullscreen detection outside the current scope; improve platform reliability using the documented test matrix.
5. Confirm asset license, configure Developer ID signing and notarization, validate Intel/universal packaging, and prepare a distributable release.

## Stage 5 — Installable multilingual beta (2026-10-03)

Implemented five-language UI and all 18 exercise translations, Persian RTL including mirrored navigation, localized numbers/dates, immediate language selection, and backwards-compatible language persistence. Added catalog/formatting tests and a resource validator. Upgraded to 0.2.0-beta.2 with independent numeric bundle build metadata.

Built a universal standalone app and a drag-to-Applications DMG, installation guide, checksum, and beta artifact publishing workflow. Added optional Developer ID signing and authenticated notarization automation for maintainers. No user shell or setup runtime is required.

Installed the beta in Applications and exercised notification prompt denial/recovery, status controls, and login-item registration/unregistration through macOS UI. Found and corrected delayed notification-status refresh, Persian tab order, and test-message localization during the checks. Confirmed a Persian test notification reached Notification Center. Final-build evidence is recorded in TESTING.md.

Distribution trust remains externally blocked: the keychain has zero valid code-signing identities and no MoveBreak notary profile. Gatekeeper rejects the ad-hoc app. No notarization success or frictionless downloaded launch is claimed. Physical logout/login, lock/sleep matrix, minimum-OS runtime, and Intel runtime are outstanding environment-dependent checks. Automatic fullscreen detection is outside the current requested scope. The project owner plans to obtain stable/App Store security prerequisites later.

## Stage 6 — CI SDK compatibility (2026-10-03)

Xcode 16.4 rejected the async delivered-notification array because its SDK lacks Sendable annotations on UNNotification. Kept those framework objects inside a callback and transfer only a Boolean to the main actor. Incremented the beta version to 0.2.0-beta.2/build 3 without rewriting the failed beta.1 tag. No beta.1 release artifact was published. Revalidated locally and sent the corrected source through CI before publishing.

## Stage 7 — Published beta verification (2026-10-03)

Beta.2 passed all Xcode 16.4 CI jobs, including universal packaging and prerelease publication. Downloaded the published DMG, matched its checksum, verified its mounted app signature and both minimum-OS architecture slices. The local beta.2 app successfully launched and delivered a test notification. The exact CI-produced app's final UI launch was interrupted by a locked Mac; requested manual unlock and documented that remaining check. Main, immutable beta tags, release artifact, README, and verification reports are available on GitHub.

## Stage 8 — Exact artifact startup correction (2026-10-03)

After the user unlocked the Mac, installed the exact CI-produced beta.2 artifact and found a startup crash. The older SDK callback inherited main-actor isolation but executed on a background queue. Added explicit Sendable annotations to UserNotifications callbacks, added a packaged-app startup smoke test to CI, and incremented to beta.3/build 4. The beta.2 release is marked superseded rather than rewriting its historical tag.


## Stage 9 — Final published beta verification (2026-10-03)

Beta.3/build 4 passed the complete Xcode 16.4 tag CI, including the new packaged-app startup smoke test, and published the universal DMG/checksum. Downloaded the exact release image, verified SHA-256 and its embedded app signature, installed it in Applications, and confirmed successful startup, resource loading, Persian RTL, the release version, notification delivery, and login-item registration/removal. Restored launch at login to Off. Updated README, changelog, and the testing record with this final evidence. Developer ID/notarization and the documented environment-dependent platform checks remain outstanding; no trusted distribution claim is made.


## Stage 10 — Public documentation and open-source foundation (2026-10-03)

Captured real beta.3 English/Persian dashboard, exercise library, and settings windows and embedded relevant views between README explanations. Added screenshot provenance with explicit development-state captions. Added a documentation map, user guide, source-level implementation walkthrough, development workflow, and contribution guide. Established AGENTS.md with the owner's mandatory ongoing complete-English-documentation rule. The owner confirmed MIT licensing for the entire current macOS tree with permission from the original rights holder; added LICENSE and updated provenance without rewriting historical tags or upstream licensing. The existing fully bundled beta.3 remains the test deliverable installed on this Mac. Apple credentials/signing/notarization are deferred to a later collaborative stage; Gatekeeper trust is not inferred from packaging.
