# Changelog

All notable changes are documented here. Native macOS versions follow Semantic Versioning. Dates use YYYY-MM-DD.

## [Unreleased]

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
