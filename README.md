# MoveBreak for macOS

A calm, offline movement and eye-rest reminder for people who spend long hours at a desk. This native SwiftUI adaptation of [MoveBreak by hedieh-hj](https://github.com/hedieh-hj/MoveBreak) preserves the original exercise artwork and product direction.

**Current version:** 0.2.0-beta.3 · **macOS 14+** · **Apple Silicon and Intel universal app**.

## Download and install

Download the [0.2.0-beta.3 DMG](https://github.com/moghadam-pro/MoveBreak-macos/releases/download/v0.2.0-beta.3/MoveBreak-0.2.0-beta.3-macOS.dmg) from [GitHub Releases](https://github.com/moghadam-pro/MoveBreak-macos/releases/tag/v0.2.0-beta.3). Open the disk image, drag **MoveBreak.app** onto **Applications**, then double-click MoveBreak in Applications. Eject the disk image after copying.

The app is completely bundled. Users do not need Terminal, shell scripts, Xcode, Swift, .NET, a setup command, a runtime download, or an account. An Applications shortcut and readable installation guide are included in the disk image. A SHA-256 checksum accompanies each installer.

**Beta security status:** the current beta has a local ad-hoc signature and hardened runtime. It is **not Developer ID signed or Apple notarized**. macOS Gatekeeper may block a downloaded copy. A seamless downloaded first launch requires Apple distribution credentials even outside the App Store. The installer does not change security settings. See [Apple's explanation](https://support.apple.com/102445) and the [verified security status](docs/SECURITY-STATUS.md). Developer ID/notarization tooling is prepared for when credentials become available; no notarized release is claimed.

## Languages and accessibility

Select **English**, **فارسی**, **Español**, **Türkçe**, or **Deutsch** in Settings. Switching takes effect immediately and is saved. The initial language follows the first supported preferred macOS language, falling back to English.

Application controls, statuses, exercise titles/instructions, notifications, outcomes, categories, and wellness guidance are translated. Persian mirrors the dashboard, navigation tabs, forms, cards, history rows, and break actions; numbers and dates use the selected locale. The countdown keeps a consistent time order. macOS permission prompts and OS-generated menus follow the operating system's language.

## Features

- Menu bar countdown with pause/resume, open, manual presentation deferral, and quit.
- Configurable movement reminders, defaulting to 45 active minutes.
- Independent eye-rest reminders every 20 active minutes.
- Automatic pause for idle time, sleep/display sleep, and inactive sessions.
- Illustrated break prompt with completed, skipped, and five-active-minute snooze actions.
- 18 offline exercises for neck, shoulders, back, wrists, legs, and eyes.
- Local history, seven-day completion chart, and estimated active-work totals.
- System, light, and dark appearance.
- Optional system notifications with permission status, recovery link, and test notification.
- Optional launch at login with actual macOS registration status and a Login Items link.
- No account, cloud service, telemetry, or external package dependency.

## Permissions and first use

MoveBreak starts its timer when opened. Closing the main window leaves it running in the menu bar. Pause or restart from Home, or take a break immediately. On a reminder, complete, skip, or snooze it. Countdown deadlines start fresh after reopening; history remains saved.

Notification permission is optional. In Settings, select **Enable system notifications**, then respond to the macOS prompt. If denied, the app still displays its own break panel. Use **Open notification settings** to change the permission and **Send test notification** to check delivery. macOS Focus, display sharing, and notification preferences control whether a banner is shown. The app refreshes permission status when activated and periodically while running.

Enable **Launch at login** only if desired. macOS may require approval in Login Items. The in-app link opens that page, and the displayed state reflects the system's registration state. Disabling the option unregisters the app.

No Accessibility, Input Monitoring, Screen Recording, Full Disk Access, camera, or microphone permission is needed. Automatic fullscreen detection is outside the current requested scope. Manual presentation deferral remains available.

## Local data

Preferences, break outcomes, and estimated daily active-work totals stay in `~/Library/Application Support/MoveBreak/state.json`. Writes are atomic and checkpointed every 15 timer ticks; forced termination can lose work since the last checkpoint. Existing 0.1.0 data remains readable, including when no language field is present. Unsupported or unreadable data is preserved rather than overwritten. See [privacy and backup instructions](docs/PRIVACY.md).

## Development

These commands are for contributors. End users install the DMG and run the app directly.

Requirements: Xcode with selected command-line tools, Swift 6.0+, and macOS 14+. Development was verified with Xcode 27.0 / Swift 6.4 on Apple Silicon.

```sh
git clone https://github.com/moghadam-pro/MoveBreak-macos.git
cd MoveBreak-macos
swift test
python3 scripts/validate-localization.py
scripts/build-app.sh release universal
scripts/build-dmg.sh
```

Open `Package.swift` in Xcode to edit/debug. The packaging script generates an app icon, version metadata, both resource bundles, a universal executable, and an ad-hoc hardened-runtime signature. Use the installed app for notification/login tests. [Release maintainers](docs/RELEASING.md) can opt into Developer ID signing and notarization without changing the source.

## Source layout and documentation

```text
Sources/
  MoveBreakCore/          Pure reminder policy, records, localization catalogs
  MoveBreak/              Native app, views, macOS integrations
    Resources/           Exercise catalog and illustrations
Tests/MoveBreakCoreTests/ Timer and localization tests
scripts/                 Build, DMG, validation, notarization tasks for maintainers
docs/                    Architecture, stages, tests, privacy, releases, security
VERSION                  Semantic version, including beta identifiers
BUILD_NUMBER             Monotonic macOS bundle build number
```

Read the [architecture](docs/ARCHITECTURE.md), [localization design](docs/LOCALIZATION.md), [Windows review](docs/WINDOWS-REVIEW.md), [stage log](docs/PLAN.md), [testing record](docs/TESTING.md), [security status](docs/SECURITY-STATUS.md), [release process](docs/RELEASING.md), and [changelog](CHANGELOG.md). The full Windows source remains preserved in [`backup/windows-2026-10-03`](https://github.com/moghadam-pro/MoveBreak-macos/tree/backup/windows-2026-10-03).

## Verification and remaining checks

CI checks tests, universal packaging, a packaged-app startup smoke test, and beta publication. Ten automated tests cover timer policy and localization. All five catalogs and 18 exercise translations are validated. The installed app has been used to inspect Persian RTL and translated interfaces, permission denial/recovery, and login-item registration/removal. The exact published beta.3 DMG was downloaded, checksum-verified, installed in Applications, and successfully tested for startup, Persian resources, notification delivery, and login-item registration/removal. [Release CI passed](https://github.com/moghadam-pro/MoveBreak-macos/actions/runs/37152838414) with Xcode 16.4. See TESTING.md for the exact final-build evidence.

Public Apple signing/notarization remains blocked by missing credentials. Actual logout/login, minimum macOS 14 runtime, Intel runtime, clean-machine download, and all physical lock/sleep scenarios still require their corresponding environments. A universal build proves both slices are present, not that an Intel Mac has been tested. Saved countdown restoration and large-history retention remain future work.

## Attribution and licensing

Original product design, illustrations, and English/Persian/Spanish exercise descriptions come from MoveBreak by hedieh-hj. See [provenance](THIRD_PARTY_NOTICES.md). No LICENSE file was present at the reviewed source commit; no new license is assigned to original materials.

MoveBreak provides general wellness guidance, not medical advice. Move gently, stop if a movement causes pain, and seek professional guidance when appropriate.
