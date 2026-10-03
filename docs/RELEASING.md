# Versioning and releases

Use Semantic Versioning: `MAJOR.MINOR.PATCH`. Before 1.0, minor versions may introduce significant changes; patches fix compatible behavior. Native versions begin at 0.1.0 independently of the Windows version lineage. `VERSION` is the package metadata source for app packaging; update the displayed version and changelog with each release. The current bundle build number is 1; increment `CFBundleVersion` for subsequent distributed builds of a marketing version.

Use Conventional Commit subjects (`feat:`, `fix:`, `docs:`, `test:`, `build:`) and annotated release tags `vX.Y.Z`. Use `codex/` for work branches. Keep main buildable. Changelog entries follow Keep a Changelog, with Unreleased changes first and dated release sections. Backup tags use `backup/` and are never release tags.

## Local development build

Run `swift test`, then `scripts/build-app.sh release`. Open `artifacts/MoveBreak.app`. Output targets the host architecture. The script applies an ad-hoc signature for local development; this is not sufficient for a trusted public download. CI uploads a build artifact and does not automatically publish a GitHub Release.

## Public release gate

1. Complete the manual checks in TESTING.md and test minimum macOS 14 support.
2. Confirm original artwork/content licensing with the original author.
3. Choose the permanent bundle identifier and Apple Developer team.
4. Update VERSION, visible version, build number, and CHANGELOG.
5. Build and test the intended architectures; an Apple Silicon build does not prove Intel support.
6. Replace the local ad-hoc signature with a Developer ID Application signature, hardened runtime and appropriate entitlements. Sign nested executable code correctly; do not use deep signing as a production substitute.
7. Submit the signed archive with `xcrun notarytool`, wait for acceptance, staple with `xcrun stapler`, and validate with `codesign` and `spctl` on a clean machine.
8. Create the annotated version tag and attach the verified artifact to a GitHub Release, including installation steps, macOS requirement, checksum, and known limitations.

No valid code-signing identity was found during initial setup. Do not claim notarization until Apple accepts the exact distributed build. App Store distribution, sandboxing, updates, and installer packaging are separate future decisions.

## Recover the Windows source

`git switch --detach backup/windows-2026-10-03` checks out the preserved source. Return with `git switch main`. Prefer a separate worktree for comparison. The companion `../MoveBreak-windows-2026-10-03.bundle` contains Git history and refs as a second local recovery artifact.
