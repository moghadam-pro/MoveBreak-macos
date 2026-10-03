Native macOS beta for macOS 14+, bundled for Apple Silicon and Intel.

Download the DMG, open it, drag MoveBreak.app to Applications, and open MoveBreak from Applications. No Terminal, development tools, shell scripts, account, or additional runtime is required.

Includes English, Persian with RTL layout, Spanish, Turkish, and German interfaces and exercise instructions; independent movement/eye timers; local history; menu bar controls; and optional system notifications and login startup.

**Security status:** this beta uses a local ad-hoc signature. It is not Developer ID signed or Apple notarized. Gatekeeper may block a downloaded copy. A frictionless downloaded first launch cannot be guaranteed until Apple distribution credentials are supplied. The installer does not disable security checks. See Apple's guidance: https://support.apple.com/102445.

Notification permission denial/recovery and login-item registration/removal were tested on the development Mac. Actual logout/login, clean-machine installation, minimum macOS 14 runtime, and Intel runtime remain manual release checks. System Focus and screen-sharing policies may suppress notification banners.

SHA-256 checksums are included. Full verification and limitations are recorded in docs/TESTING.md and docs/SECURITY-STATUS.md.

## Verified release artifact

The exact published DMG was downloaded, checksum-verified, installed in Applications, and successfully launched. Persian RTL/resources, test-notification delivery, and launch-at-login registration/removal were verified. All 10 tests, catalog validation, universal packaging, and packaged startup smoke passed in [release CI](https://github.com/moghadam-pro/MoveBreak-macos/actions/runs/37152838414).

## Documentation and license

MoveBreak is free and open source under MIT. The current repository includes the license and original-material attribution with rights-holder permission confirmed by the project owner. The immutable beta.3 installer predates that licensing/documentation update and has not been replaced.

Read the [README with real application screenshots](https://github.com/moghadam-pro/MoveBreak-macos#readme), [documentation reading map](https://github.com/moghadam-pro/MoveBreak-macos/blob/main/docs/README.md), [MIT license](https://github.com/moghadam-pro/MoveBreak-macos/blob/main/LICENSE), and [attribution](https://github.com/moghadam-pro/MoveBreak-macos/blob/main/THIRD_PARTY_NOTICES.md).

This remains a beta prerelease. Developer ID signing and notarization are deferred to a later release stage.
