**Superseded — do not use this build.**

An actual installation of the CI-produced 0.2.0-beta.2 artifact revealed a startup crash in a UserNotifications callback. The newer local SDK build had passed, but the older release SDK imported the callback with different concurrency annotations.

Use [MoveBreak 0.2.0-beta.3](https://github.com/moghadam-pro/MoveBreak-macos/releases/tag/v0.2.0-beta.3) instead. It explicitly marks background notification callbacks Sendable and adds a packaged-app startup smoke test to CI. This historical tag remains unchanged for traceability.

The beta remains ad-hoc signed and not Apple notarized; see the current release notes for security status.
