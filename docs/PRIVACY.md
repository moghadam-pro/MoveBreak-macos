# Privacy and local data

The app works offline and has no network client, telemetry, analytics SDK, account, or cloud service. It samples aggregate time since the last input event; it does not read input content, keystrokes, screenshots, or document names.

Preferences, dated break outcomes, exercise IDs, and estimated active-work totals stay in `~/Library/Application Support/MoveBreak/state.json`. System notifications are delivered through macOS. Login registration is managed by macOS only when requested in Settings.

To back up data, quit MoveBreak and copy its Application Support folder. To reset it, quit and move that folder to a backup location before reopening. Windows data is not imported. Timer deadlines restart when the app launches, while saved history and work totals persist.
