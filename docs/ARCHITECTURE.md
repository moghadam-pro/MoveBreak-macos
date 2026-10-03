# Native macOS architecture

## Scope

MoveBreak 0.1.0 is an offline macOS 14+ desktop application with an English interface. It reuses all 18 illustrations and exercise descriptions from the Windows source. Persian and Spanish exercise text is preserved in the resource catalog for future interface localization. No Windows runtime, web view, third-party package, cloud account, or server is required.

## Layers

| Location | Responsibility | Dependencies |
| --- | --- | --- |
| `Sources/MoveBreakCore` | Deterministic timer state and break records | Foundation |
| `Sources/MoveBreak/AppModel.swift` | Observable application state, orchestration, local storage, platform services | Core, AppKit, CoreGraphics, UserNotifications, ServiceManagement |
| `Sources/MoveBreak/Views.swift` | Dashboard, exercise library, history, preferences, break prompt | SwiftUI, Charts |
| `Sources/MoveBreak/MoveBreakApp.swift` | Window lifecycle, menu bar, app scenes | SwiftUI, AppKit |
| `Sources/MoveBreak/Resources` | Offline artwork and multilingual exercise catalog | Bundled files |
| `Tests/MoveBreakCoreTests` | Timer policy regression tests | Swift Testing |

The pure core has no timer, UI, storage, notification, or operating-system dependency. The `@MainActor` model serializes mutations. The current application adapter is deliberately compact; split persistence and platform adapters into separate injected services when their complexity grows. No dependency injection framework is needed at this scale.

## Reminder policy

The platform adapter samples monotonic system uptime every second and passes elapsed time to the core. Paused, idle, sleeping, inactive-session, and pending-break states do not count as active work. A sampling gap longer than five seconds is discarded because its activity cannot be established reliably. Work time is an estimate, not measured sitting time.

Movement reminders default to 45 active minutes. Eye reminders have their own 20-active-minute deadline. If both are due together, movement takes precedence; a resolved movement break also resets the eye deadline. A pending reminder is delivered once and freezes work accounting until completed, skipped, or snoozed. Snooze lasts five active minutes. Skipping selects a different next exercise. Manual breaks do not invent active work seconds. Restart resets deadlines but preserves accumulated work statistics.

Presentation mode keeps reminders pending at zero until manual deferral is disabled and activity resumes. Automatic fullscreen or meeting detection is not implemented. This avoids requiring speculative Accessibility or Screen Recording permissions in the initial version.

## macOS integration

- `MenuBarExtra` exposes countdown, open, pause/resume, presentation mode, settings, and quit. Closing the main window leaves the application running.
- An AppKit floating panel shows a break without forcibly activating another application's workspace. It is scrollable and has explicit outcome actions.
- CoreGraphics reads aggregate idle duration. No input content, event tap, or keystrokes are recorded.
- NSWorkspace sleep, display-sleep, wake, and active-session notifications protect work accounting. Lock/unlock behavior still needs manual verification on the deployment OS.
- UserNotifications authorization is requested only through the explicit settings button. The local panel works independently of notification permission. System Focus rules may suppress system notifications.
- `SMAppService.mainApp` manages launch at login and reports registration errors. Registration and system approval require manual testing in an installed app.

## Persistence

`~/Library/Application Support/MoveBreak/state.json` contains schema version 1, preferences, outcome records, and daily active-work totals. JSON is suitable for this initial small local dataset and avoids adding an ORM or SQLite dependency. Writes are atomic, occur every 15 timer ticks, on outcomes/settings changes, and on normal termination. A forced termination can lose up to the checkpoint interval of work time. Restarting the app starts a new timer interval; deadlines are not restored across launches.

Unreadable or unsupported data is preserved and further writes are disabled for that launch; the UI reports the path and error. Future schema upgrades must add an explicit migration before increasing `schemaVersion`. History is currently unbounded in storage and limited to 100 recent rows in the UI. Large-history performance and retention are future work. Windows database migration is out of scope.

## Build and distribution

Swift Package Manager is the checked-in build system; open `Package.swift` directly in Xcode. The packaging script assembles the executable, SwiftPM resource bundle, generated app icon, and Info.plist into an app with a local ad-hoc signature. It is a local development artifact, not a Developer ID signed or notarized public release. See `RELEASING.md`.

## Platform references

- [Apple: SMAppService main app login item](https://developer.apple.com/documentation/servicemanagement/smappservice/mainapp)
- [Apple: login-item registration](https://developer.apple.com/documentation/servicemanagement/smappservice/register%28%29)
- [Apple: CGEventSource aggregate event timing](https://developer.apple.com/documentation/coregraphics/cgeventsource)
