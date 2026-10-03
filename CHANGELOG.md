# Changelog

All notable changes are documented here. Native macOS versions follow Semantic Versioning. Dates use YYYY-MM-DD.

## [Unreleased]

### Documentation and open-source project foundation
- Add actual installed beta.3 screenshots throughout README, with capture provenance and test-state captions.
- Add a documentation reading map, user guide, implementation walkthrough, contributor workflow, and contribution guide.
- Record the owner's permanent requirement for complete English documentation with every change in AGENTS.md.
- License the complete current macOS project under MIT after the owner confirmed original rights-holder permission for inherited artwork, content, and design assets.
- Keep the existing standalone beta.3 artifact unchanged; defer authenticated Apple distribution signing to a later owner-assisted stage.

## [0.2.0-beta.3] - 2026-10-03

### Fixed
- Explicitly mark UserNotifications callbacks Sendable so older SDKs do not inherit main-actor isolation for callbacks executed on background queues.
- Fix the packaged beta.2 startup crash found by installing the exact published CI artifact.
- Add an actual packaged-app startup smoke test to CI, in addition to compilation and policy tests.
- Mark the beta.2 release as superseded with a startup-crash notice; retain immutable Git history.

### Verified
- Pass Xcode 16.4 CI including the packaged-app startup test and publish the universal installer.
- Install and launch the exact downloaded beta.3 artifact; verify its checksum/signature, Persian UI/resources, test-notification delivery, and login-item registration/removal.

## [0.2.0-beta.2] - 2026-10-03

### Fixed
- Keep UserNotifications framework objects inside their callback and transfer only a Boolean delivery result to the main actor, supporting Swift 6 with older SDK concurrency annotations.
- Increment the beta version/build number after the beta.1 tag failed CI before any installer was published.
- Pass Xcode 16.4 release CI and publish the universal DMG/checksum; verify the downloaded artifact integrity and minimum-OS slices.

## [0.2.0-beta.1] - 2026-10-03

### Stage 5 — Multilingual installable beta
- Added complete application-owned UI and exercise translations for English, Persian, Spanish, Turkish, and German.
- Added Persian RTL across dashboard, navigation, forms, history, exercise cards, and break actions, with localized numbers/dates.
- Added immediate persisted language selection and compatibility with previous saved preferences.
- Added universal Apple Silicon/Intel app packaging, a drag-to-Applications DMG, installation guide, and SHA-256 checksum.
- Added hardened-runtime local signing and optional maintainer-only Developer ID/notarization workflow.
- Added actual permission status, system settings recovery links, test notifications, and foreground notification presentation.
- Tested notification denial/recovery and login-item registration/removal in the installed app.
- Corrected permission refresh, Persian navigation order, and test-delivery message localization found during native UI checks.
- Added localization policy tests, complete catalog/exercise validation, and beta artifact publishing CI.
- Updated README, release instructions, localization documentation, stage log, and explicit signing/notarization status.

### Distribution status
- Apple signing/notarization cannot complete without Developer ID and notarization credentials, which are absent.
- Gatekeeper rejects the ad-hoc build; seamless first launch of downloaded copies is not guaranteed.
- Automatic fullscreen detection is outside the current scope. OS-version, Intel runtime, and physical login/lock/sleep verification remain documented manual checks.

## [0.1.0] - 2026-10-03

### Stage 1 — Preservation and review
- Preserved the complete Windows source under annotated tag `backup/windows-2026-10-03` and a local Git bundle.
- Reviewed the original architecture and documented migration decisions and implementation risks.

### Stage 2 — Foundation
- Replaced Windows implementation files with a native macOS 14+ Swift package.
- Added a pure timer policy, independent eye reminders, and deterministic regression tests.
- Retained all 18 illustrations, identity artwork, and three-language exercise descriptions.
- Added schema-versioned, atomic local storage with safe handling of unreadable data.

### Stage 3 — Application
- Added a SwiftUI dashboard, exercise library, history, seven-day chart, and preferences.
- Added pause/resume, restart, manual breaks, outcome actions, and five-minute snooze.
- Added a menu bar interface, floating reminder panel, idle/sleep/session monitoring, notification authorization, and login-item integration.
- Added manual presentation deferral and system/light/dark appearance.

### Stage 4 — Delivery
- Added app packaging, local ad-hoc signing, generated app icon, and macOS CI.
- Added English architecture, testing, privacy, stage log, release process, and attribution documentation.

### Known limitations
- English UI only; multilingual exercise catalog is preserved.
- Automatic fullscreen/meeting detection is not implemented.
- Timer deadlines restart on app launch; large-history retention is not implemented.
- Distribution signing/notarization and manual platform behavior checks remain outstanding.
