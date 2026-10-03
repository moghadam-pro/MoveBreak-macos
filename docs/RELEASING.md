# Versioning, packaging, and releases

Versions follow Semantic Versioning. Beta identifiers use `MAJOR.MINOR.PATCH-beta.N`, with matching annotated tags `vMAJOR.MINOR.PATCH-beta.N`. `VERSION` contains the full version; `BUILD_NUMBER` contains the monotonically increasing numeric build number. Packaging strips the prerelease suffix for `CFBundleShortVersionString`, writes the full version to `MBReleaseVersion`, and uses BUILD_NUMBER for `CFBundleVersion`. UI version display reads the bundle metadata.

Use Conventional Commit subjects and keep main buildable. Backup tags use `backup/` and never masquerade as release tags. Keep CHANGELOG entries dated and record each delivery stage in PLAN.md.

## End-user artifact

The deliverable is `MoveBreak-<version>-macOS.dmg`, containing MoveBreak.app, an Applications shortcut, and Read Me.html. The user opens the DMG, drags the app into Applications, and opens the app. No shell, SDK, Xcode, runtime installation, setup script, or account is part of the user flow.

## Maintainer build

Run policy/localization tests and catalog validation, then `scripts/build-app.sh release universal` and `scripts/build-dmg.sh`. Universal is the default and contains arm64 and x86_64 slices. `host` can be used for faster local development. The app build includes both SwiftPM resource bundles, generated icon, version metadata, and a hardened-runtime signature. Without MOVEBREAK_SIGNING_IDENTITY it uses local ad-hoc signing. Verify architecture/minimum OS with `lipo` and `vtool`, bundle integrity with `codesign`, and disk image integrity with `hdiutil verify`.

DMG packaging creates a checksum alongside the artifact. macOS CI tests, validates catalogs, and builds the universal app/DMG. Tags containing `-beta.` create a GitHub prerelease with the DMG and checksum. Stable tags do not automatically publish a release because Apple signing prerequisites must first be configured. The beta release notes explicitly disclose the ad-hoc signature and Gatekeeper limitation.

## Developer ID and notarization

Requirements: Apple Developer distribution access, a valid Developer ID Application certificate with its private key installed in the keychain, and authorized notarytool credentials stored in a keychain profile. Do not put private keys, passwords, tokens, or certificate exports in Git.

Set `MOVEBREAK_SIGNING_IDENTITY` to the certificate identity and `MOVEBREAK_NOTARY_PROFILE` to the keychain profile name, then run `scripts/notarize.sh`. These are maintainer tasks; users never run them. The script:

1. Builds a Developer ID signed universal app with hardened runtime and timestamp.
2. Submits an app archive with notarytool and waits for acceptance.
3. Staples/validates the app ticket and requires Gatekeeper assessment to pass.
4. Packages and signs the DMG.
5. Submits/staples/validates the DMG and regenerates its checksum.

Only successful authenticated execution confirms signing/notarization. Currently there are no valid signing identities or configured MoveBreak notary credentials on the development Mac. Ad-hoc signing cannot substitute for them. See SECURITY-STATUS.md and Apple's official documentation.

Before a stable release, validate exact downloaded artifacts on a clean Mac, macOS 14, and Intel, plus notification, login, accessibility, and sleep/lock checks. App Store distribution/sandboxing is a separate later task. Confirm original material licensing before choosing a new public license.

## Recover the Windows source

Use a separate worktree or detached checkout of `backup/windows-2026-10-03`. The complete-history companion `../MoveBreak-windows-2026-10-03.bundle` is a second local recovery artifact.
