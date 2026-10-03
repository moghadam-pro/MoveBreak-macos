#!/bin/bash
# Maintainer-only release task. End users never run scripts.
set -euo pipefail
cd "$(dirname "$0")/.."
: "${MOVEBREAK_SIGNING_IDENTITY:?Set a Developer ID Application signing identity}"
: "${MOVEBREAK_NOTARY_PROFILE:?Set the name of a notarytool keychain profile}"
version="$(tr -d '\n' < VERSION)"
scripts/build-app.sh release universal
archive="$PWD/artifacts/MoveBreak-$version-notary.zip"
ditto -c -k --sequesterRsrc --keepParent artifacts/MoveBreak.app "$archive"
xcrun notarytool submit "$archive" --keychain-profile "$MOVEBREAK_NOTARY_PROFILE" --wait
xcrun stapler staple artifacts/MoveBreak.app
xcrun stapler validate artifacts/MoveBreak.app
spctl --assess --type execute --verbose=2 artifacts/MoveBreak.app
scripts/build-dmg.sh
installer="$PWD/artifacts/MoveBreak-$version-macOS.dmg"
xcrun notarytool submit "$installer" --keychain-profile "$MOVEBREAK_NOTARY_PROFILE" --wait
xcrun stapler staple "$installer"
xcrun stapler validate "$installer"
hdiutil verify "$installer"
(cd artifacts && shasum -a 256 "$(basename "$installer")" > "$(basename "$installer").sha256")
