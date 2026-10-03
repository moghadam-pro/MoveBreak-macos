#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
app="$PWD/artifacts/MoveBreak.app"
[[ -d "$app" ]] || { echo 'Build the app before packaging.' >&2; exit 1; }
codesign --verify --deep --strict "$app"
version="$(tr -d '\n' < VERSION)"
staging="$(mktemp -d "$PWD/artifacts/.dmg-build.XXXXXX")"
trap 'rm -rf "$staging"' EXIT
ditto "$app" "$staging/MoveBreak.app"
ln -s /Applications "$staging/Applications"
cp docs/INSTALL.html "$staging/Read Me.html"
dmg="$PWD/artifacts/MoveBreak-$version-macOS.dmg"
[[ ! -e "$dmg" ]] || rm "$dmg"
hdiutil create -volname "MoveBreak $version" -srcfolder "$staging" -ov -format UDZO "$dmg"
if [[ -n "${MOVEBREAK_SIGNING_IDENTITY:-}" ]]; then
  codesign --force --timestamp --sign "$MOVEBREAK_SIGNING_IDENTITY" "$dmg"
fi
hdiutil verify "$dmg"
(cd artifacts && shasum -a 256 "$(basename "$dmg")" > "$(basename "$dmg").sha256")
echo "Installer: $dmg"
