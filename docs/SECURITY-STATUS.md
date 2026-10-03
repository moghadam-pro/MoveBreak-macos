# Security and distribution status

## Verified status for 0.2.0-beta.3

The application is a standalone universal `.app` distributed inside a read-only DMG. Both app and core localization bundles are embedded. Installation requires dragging the app to Applications and opening it. No end-user script, shell, runtime download, account, elevated installer, or security setting modification is included.

The local build is ad-hoc signed with hardened runtime and passes `codesign --verify --deep --strict`. It has no Apple Developer team identity. The development machine reports **0 valid code-signing identities**, and `notarytool history --keychain-profile MoveBreak` reports no stored credentials. Gatekeeper's `spctl --assess --type execute` rejects this ad-hoc application. These are different checks: a valid local signature does not establish trusted Apple distribution.

**Developer ID signing and Apple notarization were not completed.** They cannot be completed without a valid Developer ID Application certificate/private key and authorized Apple notarization credentials. App Store membership is not the only relevant milestone; trusted distribution outside the App Store also needs these prerequisites. See [Apple Developer ID](https://developer.apple.com/developer-id/) and [Apple notarization workflow](https://developer.apple.com/documentation/security/customizing-the-notarization-workflow).

The Developer ID build path and maintainer-only `scripts/notarize.sh` are prepared. Their authenticated execution remains unverified until credentials are supplied. The script requires notarization acceptance, staples tickets, and assesses the exact app before proceeding. It does not strip quarantine or disable Gatekeeper. The beta installer cannot promise a security-dialog-free launch after downloading.

## Runtime permissions

| Capability | API / access | User control | Test status |
| --- | --- | --- | --- |
| System notifications | UserNotifications alert/sound authorization | Explicit opt-in; System Settings recovery link | Prompt, denial, recovery, status refresh, and delivery to Notification Center verified |
| Launch at login | SMAppService main app registration | Optional switch and Login Items link | Registration, system listing, unregistration, and disabled state exercised |
| Aggregate idle duration | CGEventSource event timing | No input content collected | Used by the running app; no privileged permission requested |
| Sleep and active session | NSWorkspace notifications | No extra privacy permission | Integration implemented; physical lock/sleep matrix remains manual |
| Local storage | Own Application Support folder | User can back up or reset the local file | Existing saved data loaded and language choice persisted |

No Accessibility, Input Monitoring, Screen Recording, Full Disk Access, camera, microphone, or network entitlement is requested. Fullscreen detection is not part of this work.

## Boundaries of testing

The tests do not log out, restart, or physically lock the user's computer. Therefore next-login startup, every lock/wake path, and clean-machine installation are not marked passed. Minimum macOS 14 and Intel runtime need separate machines or suitable test environments. Notification banners may be suppressed by the OS while the display is shared or Focus is active; delivered-notification checks are separate from visible banner checks.

App Store submission, sandbox configuration, distribution certificates, provisioning, and store compliance are future stable-release tasks, as requested by the project owner.
