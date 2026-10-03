# Development workflow

## Environment and first build

Use macOS 14+, Xcode with its command-line tools selected, Swift 6.0+, and Python 3 for resource validation. There are no external Swift package dependencies. Xcode 16.4 is used in CI; Xcode 27/Swift 6.4 is verified locally. Do not assume a newer SDK's concurrency annotations exist in the CI SDK.

```sh
git clone https://github.com/moghadam-pro/MoveBreak-macos.git
cd MoveBreak-macos
swift test
python3 scripts/validate-localization.py
scripts/build-app.sh debug host
```

Open Package.swift in Xcode for source editing and debugging. The raw SwiftPM executable is not the end-user artifact. Use the generated `artifacts/MoveBreak.app` for application-bundle behavior; notification and login checks use a copy installed in Applications. Quit an existing instance before replacing its bundle. A development build uses the same bundle identity and data path as the installed beta, so back up local state before tests that modify outcomes/preferences. No isolated test-data launch switch exists yet.

## Where to change things

| Task | Files and required companion updates |
| --- | --- |
| Timer policy | BreakEngine.swift, policy tests, ARCHITECTURE/IMPLEMENTATION |
| Platform integration or storage | AppModel.swift, permissions/privacy/test records |
| Windows, menu, app lifecycle | MoveBreakApp.swift, user guide and lifecycle docs |
| Visual UI | Views.swift, all translation catalogs if text changes, screenshots |
| Language support | Localization.swift, catalogs, exercises.json, validation/tests, LOCALIZATION |
| Packaging | scripts/build-app.sh/build-dmg.sh, release/install/security docs |
| Publication | .github/workflows/macos.yml, RELEASING, version files and changelog |

Use a `codex/` branch by default for agent work and Conventional Commit messages. Keep main buildable, make focused changes, and retain immutable backup/release tags. Do not bump app versions for documentation-only changes. App releases use VERSION and monotonically increasing BUILD_NUMBER together.

## Verification appropriate to the change

Run `swift test` for policy/localization changes and the catalog validator for text/resources. Build a packaged app for UI/integration changes. Run `scripts/smoke-test-app.sh` only when no valuable running development session could be interrupted; it launches and terminates a test process, and can touch the normal application data directory. Inspect the actual UI for layout, translations, and resources. A startup smoke test proves survival during its observation window, not the full macOS permission matrix.

Before release, build universal, package the DMG, then test the exact artifact produced by CI. See TESTING for performed checks and remaining hardware/session tests. Use RELEASING for trusted signing; credentials never belong in the repo. Contributors use shell commands; users never need them.

## Troubleshooting

Missing images or translations usually indicate missing SwiftPM resource bundles in Contents/Resources. Validate both application and core bundles and use the packaging script. Notification denial is handled in System Settings, not by rebuilding. Login registration should be tested with the app installed in Applications. Data decode errors preserve the original file; back it up before attempting recovery. A codesign integrity pass does not mean Gatekeeper trusts an ad-hoc app.

Older SDK notification callbacks may run off the main actor. Keep framework objects in their callback, explicitly mark Sendable closures, and transfer only safe values to MainActor. Beta.2 demonstrated why local compilation and successful CI builds alone cannot establish installed runtime correctness.
