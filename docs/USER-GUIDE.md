# Using MoveBreak

## Install the test version

Download the current beta DMG linked in the root README. Open it, drag MoveBreak.app onto Applications, eject the disk image, and open MoveBreak from Applications. The app contains its executable, localized catalogs, images, and icon. No Terminal, development tools, runtime installation, account, or service is required. The currently installed beta.3 on the development Mac has been launched and tested.

The beta is ad-hoc signed and not Apple notarized. A downloaded copy may be blocked by Gatekeeper. The app does not remove quarantine or alter system protections. A fully trusted first launch awaits Developer ID credentials and notarization; this is separate from bundling all runtime requirements. See SECURITY-STATUS.md for verified evidence.

## Daily workflow

Home displays the movement countdown, activity status, current illustration, and today's completion/work estimates. Pause stops active-time accounting; resume continues it. Restart begins new movement and eye intervals without deleting history. Take a break opens a manual movement break. Closing the main window keeps the app in the menu bar; choose Quit MoveBreak there to terminate it.

A break panel offers completed, skipped, and snoozed outcomes. Completed means you chose that action, not that the app measured exercise. Skipped moves on without increasing completion totals. Snoozed schedules the relevant reminder after five active minutes. Eye and movement schedules are independent, with movement priority when both are due. Exercise duration is guidance, not an enforced session timer.

The library lists all 18 bundled exercises. History displays recent outcomes and a seven-day completion chart. Development smoke tests may appear in history on this development Mac; they are not evidence of actual movement.

## Preferences

Movement defaults to 45 active minutes, configurable from 1 to 120; idle defaults to 3 minutes, configurable from 1 to 30. Idle time, sleep, inactive sessions, pause, and an unresolved break stop work accounting. Eye reminders occur after 20 active minutes when enabled. Presentation mode defers reminder delivery; it does not detect fullscreen apps automatically. Save settings starts a new interval when no break is pending. Language changes apply immediately without resetting the countdown.

Choose English, Persian, Spanish, Turkish, or German. Persian mirrors application layouts and navigation. Dates and numbers follow the chosen locale. System-owned dialogs/menus follow macOS language. Choose system, light, or dark appearance.

Notifications and launch at login are optional. Request notification permission in Settings; denial leaves the app's own break panel available. The recovery link opens the macOS notification page. A test notification reports scheduling and, when observed, delivery to Notification Center. Focus and banner preferences can suppress visible presentation. Launch-at-login status reflects SMAppService registration, including required approval. Actual launch on a later login is a separate test from registration.

## Data, recovery, and removal

The app stores preferences, break outcomes, and daily work estimates in `~/Library/Application Support/MoveBreak/state.json`. Quit before backing up the containing folder. To reset safely, move that folder to a backup location while the app is closed. Do not edit the live file. Unreadable or unsupported data is preserved and writes are disabled for that run; the UI reports the error. No Windows database import is provided.

To remove the app, disable Launch at login, quit MoveBreak, and move the app from Applications to Trash. Keep the Application Support folder if you want to retain history. Deleting the app does not imply deleting its saved data.

Report issues with app version, macOS version, architecture, steps, expected/actual behavior, and a screenshot without private information. Do not upload your entire state file or system logs by default.
