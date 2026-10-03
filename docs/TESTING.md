# Testing record

## 0.2.0-beta.3 — 2026-10-03

Environment: Apple Silicon Mac, Xcode 27.0 / Swift 6.4. Deployment target is macOS 14. The installed test app is `/Applications/MoveBreak.app`.

### Automated and packaging verification

- All **10 Swift Testing tests** passed: seven timer-policy cases and three localization cases.
- Catalog validator passed for **82 UI keys**, all five languages, formatting arguments, 18 unique exercise IDs, all localized titles/instructions, and illustration files.
- Universal release build completed. `lipo` confirmed arm64 and x86_64 slices. `vtool` confirmed minimum macOS **14.0** in both slices.
- Hardened-runtime ad-hoc app signature passed strict/deep verification; Info.plist passed lint.
- Both application and core localization resource bundles are packaged and loaded in the installed app.
- DMG creation and checksum verification completed. Mounted the final image read-only, verified its app signature, Applications symlink, and readable HTML guide, then detached it. SHA-256 verification passed from the artifact directory. No shell/runtime setup is part of installation.
- Xcode 27 emits an Intel architecture deprecation warning while building; the generated slices still report macOS 14.0 minimum. This is not proof of Intel runtime compatibility.

### Native UI and permission checks

- Installed the app in Applications and launched it successfully with previous saved data.
- Checked English settings, exercise catalog, and status controls.
- Switched to Persian and inspected settings, mirrored dashboard, reversed tab ordering, localized countdown/statistics, Persian exercise text, and RTL break-panel actions.
- Quit/reopened and confirmed the saved Persian language was restored.
- Exercised a Persian manual break and skip; the panel closed and a different exercise was selected.
- Switched to Spanish, Turkish, and German and checked translated settings, numeric labels, statuses, and locale changes. Inspected German long-label layout and Turkish exercise instructions.
- Found delayed external permission refresh and fixed it with app-activation and periodic refresh. Found unmirrored tab order and fixed it with stable explicit selection tags. Found a test-delivery message retaining the previous language and changed it to a lookup key rendered in the current language; rebuilt/reinstalled and confirmed German-to-Persian switching updates the delivered message.
- Requested notification permission from the installed app. Located the native macOS permission prompt and chose Don't Allow. The app reported Denied, showed a recoverable explanation, and continued working.
- Used the in-app link to open macOS notification settings; enabled only MoveBreak's notifications and confirmed the app later reported Allowed.
- Requested a Persian test notification. The app's delivered-notification check confirmed delivery to Notification Center. Visible banner behavior is controlled by macOS and was not used as the sole delivery criterion.
- Enabled launch at login, confirmed MoveBreak.app appeared under Open at Login in macOS System Settings, then disabled the option and verified the app's registration state returned to Off. The original disabled startup preference was restored.
- No privileged privacy permission was requested during these checks. Notification permission is enabled on this development Mac after the recovery test.

### Distribution trust checks

- `security find-identity -v -p codesigning`: zero valid identities.
- `notarytool history --keychain-profile MoveBreak`: no stored profile credentials.
- `spctl --assess --type execute`: rejected the ad-hoc app, as expected without trusted Apple distribution signing.
- Developer ID signing and notarization are **blocked**, not passed. Maintainer scripts are prepared but authenticated execution is unverified.

### CI compatibility correction

The 0.2.0-beta.1 tag did not publish an installer because Xcode 16.4 rejected transferring `[UNNotification]` across the main-actor boundary; the newer Xcode 27 SDK accepted it. Replaced that transfer with a synchronous callback adapter that inspects framework objects locally and returns only a Sendable Boolean through a continuation. The corrected build is 0.2.0-beta.2 (bundle build 3). Beta.1 remains an immutable historical tag, with no published release artifact.

### Published artifact verification

[Beta.2 tag CI](https://github.com/moghadam-pro/MoveBreak-macos/actions/runs/37152264658) passed with Xcode 16.4: all tests, catalog validation, universal app/DMG packaging, artifact upload, and prerelease publication succeeded. [The release](https://github.com/moghadam-pro/MoveBreak-macos/releases/tag/v0.2.0-beta.2) contains the DMG and checksum.

Downloaded that exact published DMG, matched its published SHA-256, mounted it read-only, verified its app signature, and confirmed arm64/x86_64 slices with macOS 14.0 minimum and SDK 15.5. The locally built beta.2 was also installed/launched, showed the correct version/Persian UI, and successfully delivered a test notification through the corrected callback.

The exact beta.2 CI artifact crashed at startup after the user unlocked the Mac and testing resumed. Crash diagnostics identified a runtime actor-isolation assertion in the notification-settings callback. The older SDK imported the callback without Sendable annotation, causing implicit main-actor inheritance even though macOS invokes it on a background queue. Explicit Sendable callback annotations remove that unsafe inheritance. Beta.3 adds a packaged-app startup test to CI and supersedes the faulty beta.2 release. Successful compilation alone was not treated as runtime validation.

### Environment-dependent checks still required

Actual logout/login startup, all physical lock/unlock/sleep/display-sleep/session-switch transitions, clean-machine downloaded installation, minimum macOS 14 runtime, Intel runtime, multi-monitor/Spaces behavior, and a complete VoiceOver/keyboard matrix remain manual checks. The user's computer was not logged out, restarted, or locked during testing. Notification Focus and screen-sharing suppression are OS policies; global notification/security settings were not weakened.

The existing history contains development smoke-test outcomes. They are not evidence of actual physical exercises. No user data was reset for these tests.

---

## 0.1.0 baseline verification

Date: 2026-10-03. Environment: Apple Silicon Mac, Xcode 27.0 (27A266a), Swift 6.4, current host OS. Deployment target: macOS 14.

## Verified

- `swift test`: 7 Swift Testing policy tests passed with no failures. The separate XCTest summary reports zero XCTest cases because these cases use Swift Testing.
- `scripts/build-app.sh debug`: successfully compiled and packaged the native application.
- `scripts/build-app.sh release`: successfully compiled an optimized app bundle.
- `plutil -lint` accepted the packaged Info.plist.
- Resource catalog extraction asserted exactly 18 exercises; all source image files and three language fields were preserved.
- A real launch found an initial packaging defect: the SwiftPM resource bundle was placed beside the executable, but the installed app resolves it through its Resources directory. Corrected the script, rebuilt, and confirmed a running native window with illustrations.
- Inspected the dashboard screenshot: countdown, green accent, rounded cards, original illustration, readable instructions, and statistics displayed correctly.
- Opened a manual break panel and verified the exercise, duration, skip/snooze/completed actions, and wellness text through the native accessibility tree.
- Completed that break and verified the dashboard count changed to 1, a completed history row appeared, and today's chart count changed to 1.
- Inspected the exercise library and settings controls in the running application.
- Confirmed remote backup tag before replacing Windows files.
- No valid Developer ID signing identity was available; packaging uses a local ad-hoc signature.

The smoke test creates one local completed break record. It is development data in this Mac's application support folder.

## Policy tests

| Test | Behavior |
| --- | --- |
| idleAndPauseDoNotCount | Idle and manual pause freeze countdown |
| deferredReminderAndSingleDelivery | Due reminder waits for deferral to end; pending break stops counting; movement snooze resets to 300 seconds |
| eyeReminderIsIndependent | Eyes become due at 20 minutes while movement countdown remains independent |
| invalidElapsedTimeIsIgnored | NaN and negative deltas cannot alter the timer |
| manualBreakDoesNotConsumeWorkTime | Manual request creates a break without inventing work time |
| eyeSnoozeKeepsMovementDeadline | Eye snooze leaves movement deadline unchanged |
| disabledEyesAndRestart | Disabled eye rule creates no eye reminder; restart clears pending state |

## Manual checks still required

- Test actual active input and idle threshold on macOS 14 and the current macOS; verify screen lock, unlock, sleep, wake, fast user switching, and display sleep.
- Verify movement/eye due reminders end to end, all three outcome buttons, pause during snooze, and deferral until presentation mode ends.
- Check macOS notification authorization accepted and denied, notification sound, Focus suppression, and notification preferences.
- Install in Applications and verify login-item registration, approval, launch at login, and removal.
- Check closing/reopening through the menu bar, app termination, multiple displays, fullscreen Spaces, keyboard navigation, VoiceOver, contrast, and small-screen layout.
- Check settings persistence after relaunch, storage write failures, unreadable data handling, timezone/midnight changes, and checkpoint behavior during forced termination.
- Validate Intel or universal builds before advertising Intel support. Current verification is Apple Silicon only.
- Confirm signed/notarized installation on a clean Mac before public release.

Build success and smoke checks do not establish complete platform or distribution readiness. CI has been configured but its remote result is not part of the initial local verification.
