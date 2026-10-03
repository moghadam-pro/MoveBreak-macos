# MoveBreak for macOS

A calm, offline movement and eye-rest reminder for people who spend long hours at a desk. This native SwiftUI adaptation of [MoveBreak by hedieh-hj](https://github.com/hedieh-hj/MoveBreak) preserves the original exercise artwork and product direction.

**Status:** 0.1.0 native development baseline. Requires **macOS 14 or later**. The interface is English. The full Windows source is preserved in [`backup/windows-2026-10-03`](https://github.com/moghadam-pro/MoveBreak-macos/tree/backup/windows-2026-10-03).

## Features

- Menu bar countdown with pause/resume, open, presentation mode, and quit.
- Configurable movement reminders, defaulting to 45 active minutes.
- Independent eye-rest reminders every 20 active minutes.
- Automatic pause for idle time, sleep/display sleep, and inactive sessions.
- Illustrated break prompt with completed, skipped, and five-minute snooze actions.
- 18 offline exercises for neck, shoulders, back, wrists, legs, and eyes.
- Local break history, seven-day completion chart, and estimated active-work totals.
- System, light, and dark appearance; optional system notifications and launch at login.
- No account, cloud service, telemetry, or external package dependency.

## Build and run

Install Xcode with its command-line tools selected. The package requires Swift 6.0+; initial development was verified with Xcode 27.0 / Swift 6.4 on Apple Silicon.

```sh
git clone https://github.com/moghadam-pro/MoveBreak-macos.git
cd MoveBreak-macos
swift test
scripts/build-app.sh debug
open artifacts/MoveBreak.app
```

Open `Package.swift` in Xcode to edit and debug the package. Use the packaged `.app` for notification and login-item integration checks; launching the raw SwiftPM executable is not the supported integration path. Run `scripts/build-app.sh release` for an optimized local app. The generated bundle has a local ad-hoc signature and is not a notarized public release.

## Using MoveBreak

The timer starts when the app opens and counts estimated active work. Closing the main window leaves it running in the menu bar. Pause or restart from Home, or take a break immediately. When a reminder appears, complete, skip, or snooze it. Skipping chooses a different next exercise.

In Settings, choose the reminder interval, idle threshold, eye rule, sound, appearance, and optional launch at login, then save settings. Use **Enable system notifications** to request macOS notification permission. The illustrated panel works without that permission. macOS may require approval in System Settings for launch at login.

Enable **Defer reminders (presentation mode)** before presentations or focused work. Automatic fullscreen/meeting detection is not included. Eye reminders are independent of movement reminders; simultaneous deadlines are handled as a movement break. Snooze is five active minutes. History persists, but countdown deadlines start fresh after reopening.

## Local data

Data is stored at `~/Library/Application Support/MoveBreak/state.json`. Active-work totals are estimates, not posture or sitting measurements. Writes are atomic and checkpointed every 15 timer ticks; forced termination can lose work since the last checkpoint. Unsupported or unreadable data is preserved rather than overwritten. See [privacy and backup instructions](docs/PRIVACY.md).

## Source layout

```text
Sources/
  MoveBreakCore/       Pure reminder policy and records
  MoveBreak/           Native application, views, and platform adapters
    Resources/        Exercise catalog and illustrations
Tests/
  MoveBreakCoreTests/  Deterministic policy tests
scripts/              App bundle packaging
docs/                 Architecture, review, stages, testing, privacy, releases
```

Read the [architecture](docs/ARCHITECTURE.md), [Windows review](docs/WINDOWS-REVIEW.md), [stage log and roadmap](docs/PLAN.md), [testing record](docs/TESTING.md), [release/versioning process](docs/RELEASING.md), and [changelog](CHANGELOG.md). Build CI tests the policy and packages a macOS artifact; it does not publish a signed release.

## Known limitations and next work

Manual validation of minimum-OS behavior, lock/unlock, notification permission, login items, accessibility, multiple displays, and Intel support is still required. Dashboard layout, bundled illustrations, manual break completion, history, and settings were inspected in the running native app. Complete interface localization, automatic meeting/fullscreen deferral, large-history retention, saved countdown restoration, and public signing/notarization are future milestones.

## Attribution and licensing

Original product design, illustrations, and multilingual exercise descriptions come from MoveBreak by hedieh-hj. See [provenance](THIRD_PARTY_NOTICES.md). The source reviewed did not include a LICENSE file; no new license is assigned to the original materials. Confirm licensing with the original author before public redistribution.

MoveBreak provides general wellness guidance, not medical advice. Move gently, stop if a movement causes pain, and seek professional guidance when appropriate.
