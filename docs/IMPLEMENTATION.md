# Implementation walkthrough

Read ARCHITECTURE first for rationale. This document follows the current source from launch through reminder delivery, persistence, and packaging. Paths are relative to the repository root.

## Startup and lifecycle

`MoveBreakApp.swift` constructs one `@StateObject AppModel` and shares it with the main Window, MenuBarExtra, and Settings scene. AppDelegate installs the UserNotifications delegate and saves on normal termination. Closing the last window does not terminate the app. LocalizationModifier supplies locale and layoutDirection and refreshes permission status on activation/scene changes.

AppModel initialization resolves the Application Support file, decodes the bundled exercise catalog, and loads saved JSON if present. An invalid bundled catalog is a build/content defect and fails startup; resource validation prevents this in CI. An invalid saved file sets an error and disables subsequent writes rather than replacing the file. Saved intervals are clamped to valid ranges. The model starts a fresh engine, selects the first exercise, reads permissions, subscribes to NSWorkspace events, and creates a one-second timer.

## Tick to reminder

`tick()` computes elapsed monotonic uptime, samples aggregate idle duration, and combines sleep/session/idle state into `inactive`. It discards gaps over five seconds. `BreakEngine.advance` receives only seconds, activity, and deferral. It returns counted seconds for workByDay and may set pending. AppModel notices the transition from no pending reminder to pending, chooses an exercise, opens the panel, and attempts an optional notification. Every 15 ticks it checkpoints storage and refreshes permissions.

The pure value-type engine rejects nonfinite/nonpositive elapsed time and does not count paused, inactive, or pending-break time. It decreases movement and enabled eye deadlines, prioritizes movement when both reach zero, and leaves zero deadlines deferred until presentation mode ends. Delivery creates a pending state so subsequent ticks cannot deliver the same break again.

`takeBreak()` requests movement immediately; an already pending break simply reopens its panel. `resolve()` creates a dated BreakRecord, resolves the engine, closes the panel, saves, and chooses another exercise. A movement completion/skip resets movement to interval and eyes to 20 minutes. Movement snooze sets movement to 5 minutes without resetting eyes. Eye snooze sets eyes to 5 minutes without moving the movement deadline. Eye completion/skip resets eyes to 20 minutes. Selection excludes the previously displayed exercise when alternatives exist; eye reminders filter the Eye category. Manual breaks do not add work time.

## State and storage contract

| Type/field | Meaning |
| --- | --- |
| LocalData.schemaVersion | Currently 1; unsupported versions stop writes |
| preferences | languageCode (optional), reminderMinutes, idleMinutes, sound, eyes, appearance, deferReminders |
| records | UUID, Date, exerciseID, movement/eyes kind, completed/skipped/snoozed outcome |
| workByDay | Local-calendar YYYY-MM-DD keys mapped to estimated active seconds |
| BreakEngine | In-memory remaining/eyeRemaining, pending, paused, interval, eyesEnabled |

JSONEncoder/Decoder use their default Date representation (seconds relative to Apple's reference date), not ISO-8601. IDs and dates are stored with records. Timer deadlines, pause state, current exercise, transient errors, panel, and permission status are not persisted. Launch-at-login state comes from macOS instead of a copied preference. LanguageCode is optional so older schema-1 data remains readable. Language changes save immediately. Normal settings save updates policy and restarts intervals if no break is pending.

Writes create the containing directory and atomically replace state.json. The checkpoint is based on timer ticks, not a guarantee of exactly 15 wall-clock seconds. Failed writes surface an error. Unreadable original data is not migrated automatically. History is unbounded on disk; the UI shows up to 100 recent rows. Charts derive completions from dated outcomes, while work totals are estimates. Future retention/migration must be explicit and tested.

## Native services and concurrency

All model mutations are on MainActor. Timer and NSWorkspace observers schedule main-actor work. UserNotifications callbacks explicitly use Sendable closures because older SDK imports can otherwise inherit actor isolation incorrectly. Notification framework objects remain in their callback; only status, strings, or delivery Boolean cross to the model. The foreground delegate permits banner, sound, and list presentation. Permission denial skips notification delivery while leaving the panel working.

SMAppService registers/unregisters the installed main app and reports enabled/requiresApproval/error states. CoreGraphics observes aggregate idle seconds without recording input. NSWorkspace sleep/display/session events protect counting; full physical event coverage remains in the manual test matrix. No Accessibility/event-tap/screen-capture service is used.

## Views, content, and localization

`Views.swift` owns dashboard, exercise cards/library, history/chart, preferences, and break view. It observes the shared model; outcome buttons call model methods. Main tabs have stable tags and explicitly reversed Persian ordering. Localized environment values mirror content, while countdown order remains consistent. `Localization.swift` owns the supported language enum, preferred-language selection, locale, and UI catalog loading. JSON UI catalogs live in MoveBreakCore resources. The exercise catalog stores ID/category/duration/image plus title/instruction dictionaries for all five languages. Images resolve through the executable target's Bundle.module. Missing translations fall back to English; the validator requires complete committed catalogs so fallback should not mask release omissions.

## Artifact and CI path

Package.swift has a Foundation-only core target, executable app target, and core test target. SwiftPM processes resources into two bundles. build-app.sh compiles host/universal, stages an app, embeds both bundles in Contents/Resources, generates icon/Info.plist metadata, signs, verifies, and replaces the local artifact. build-dmg.sh copies the app and HTML guide, adds an Applications link, makes a compressed image, verifies it, and writes SHA-256. End users run none of these commands.

CI uses Xcode 16.4 for tests, resource validation, universal packaging, and startup smoke. A successful beta tag then publishes a prerelease; stable tags do not automatically publish. VERSION/BUILD_NUMBER map to semantic display version and numeric bundle metadata. notarize.sh is prepared for authenticated Developer ID distribution, currently deferred. Ad-hoc integrity verification and a successful startup are separate from Gatekeeper trust.

## Limits and next decisions

The adapter currently combines platform services and persistence in AppModel. Split it into injected services when complexity or integration tests require it, without moving OS APIs into the pure engine. Countdown restoration, retention, Windows-data import, automatic fullscreen detection, App Store sandboxing, and full hardware/session/accessibility verification are not implemented or fully validated. See TESTING for evidence and PLAN for history.
