#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
configuration="${1:-release}"
architecture="${2:-universal}"
if [[ "$configuration" != release && "$configuration" != debug ]]; then
  echo 'Usage: scripts/build-app.sh [release|debug] [universal|host]' >&2
  exit 2
fi
build_args=(-c "$configuration")
case "$architecture" in
  universal) build_args+=(--arch arm64 --arch x86_64) ;;
  host) ;;
  *) echo 'Architecture must be universal or host.' >&2; exit 2 ;;
esac
swift build "${build_args[@]}"
bin_dir="$(swift build "${build_args[@]}" --show-bin-path)"
mkdir -p artifacts
staging="$(mktemp -d "$PWD/artifacts/.app-build.XXXXXX")"
trap 'rm -rf "$staging"' EXIT
app_dir="$staging/MoveBreak.app"
mkdir -p "$app_dir/Contents/MacOS" "$app_dir/Contents/Resources"
cp "$bin_dir/MoveBreak" "$app_dir/Contents/MacOS/MoveBreak"
# Both the application and core localization bundles are runtime dependencies.
for bundle in MoveBreak_MoveBreak.bundle MoveBreak_MoveBreakCore.bundle; do
  cp -R "$bin_dir/$bundle" "$app_dir/Contents/Resources/"
done
version="$(tr -d '\n' < VERSION)"
marketing_version="${version%%-*}"
build_number="$(tr -d '\n' < BUILD_NUMBER)"
cat > "$app_dir/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>pro.moghadam.MoveBreak</string>
<key>CFBundleName</key><string>MoveBreak</string>
<key>CFBundleDisplayName</key><string>MoveBreak</string>
<key>CFBundleExecutable</key><string>MoveBreak</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>$marketing_version</string>
<key>CFBundleVersion</key><string>$build_number</string>
<key>MBReleaseVersion</key><string>$version</string>
<key>CFBundleDevelopmentRegion</key><string>en</string>
<key>CFBundleLocalizations</key><array><string>en</string><string>fa</string><string>es</string><string>tr</string><string>de</string></array>
<key>LSMinimumSystemVersion</key><string>14.0</string>
<key>NSHighResolutionCapable</key><true/>
<key>CFBundleIconFile</key><string>AppIcon</string>
<key>LSApplicationCategoryType</key><string>public.app-category.healthcare-fitness</string>
</dict></plist>
PLIST
iconset="$staging/AppIcon.iconset"
mkdir -p "$iconset"
for size in 16 32 128 256 512; do
  sips -z "$size" "$size" Sources/MoveBreak/Resources/MoveBreak.png --out "$iconset/icon_${size}x${size}.png" >/dev/null
  double=$((size * 2))
  sips -z "$double" "$double" Sources/MoveBreak/Resources/MoveBreak.png --out "$iconset/icon_${size}x${size}@2x.png" >/dev/null
done
iconutil -c icns "$iconset" -o "$app_dir/Contents/Resources/AppIcon.icns"
identity="${MOVEBREAK_SIGNING_IDENTITY:--}"
if [[ "$identity" == - ]]; then
  codesign --force --options runtime --sign - "$app_dir"
  echo 'Local ad-hoc signature applied. Apple notarization requires Developer ID.'
else
  codesign --force --options runtime --timestamp --sign "$identity" "$app_dir"
fi
codesign --verify --deep --strict "$app_dir"
plutil -lint "$app_dir/Contents/Info.plist"
rm -rf "$PWD/artifacts/MoveBreak.app"
mv "$app_dir" "$PWD/artifacts/MoveBreak.app"
echo "Built $PWD/artifacts/MoveBreak.app ($version, $architecture)."
