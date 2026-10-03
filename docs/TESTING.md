# Testing record

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
