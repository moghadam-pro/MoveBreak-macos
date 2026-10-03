#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
configuration="${1:-release}"
if [[ "$configuration" != release && "$configuration" != debug ]]; then
  echo 'Usage: scripts/build-app.sh [release|debug]' >&2
  exit 2
fi
swift build -c "$configuration"
bin_dir="$(swift build -c "$configuration" --show-bin-path)"
app_dir="$PWD/artifacts/MoveBreak.app"
mkdir -p "$app_dir/Contents/MacOS" "$app_dir/Contents/Resources"
cp "$bin_dir/MoveBreak" "$app_dir/Contents/MacOS/MoveBreak"
# SwiftPM resolves resources through Bundle.main.resourceURL in an app bundle.
cp -R "$bin_dir/MoveBreak_MoveBreak.bundle" "$app_dir/Contents/Resources/"
version="$(tr -d '\n' < VERSION)"
cat > "$app_dir/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>pro.moghadam.MoveBreak</string>
<key>CFBundleName</key><string>MoveBreak</string>
<key>CFBundleDisplayName</key><string>MoveBreak</string>
<key>CFBundleExecutable</key><string>MoveBreak</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>$version</string>
<key>CFBundleVersion</key><string>1</string>
<key>LSMinimumSystemVersion</key><string>14.0</string>
<key>NSHighResolutionCapable</key><true/>
<key>CFBundleIconFile</key><string>AppIcon</string>
<key>LSApplicationCategoryType</key><string>public.app-category.healthcare-fitness</string>
</dict></plist>
PLIST
iconset="$PWD/artifacts/AppIcon.iconset"
mkdir -p "$iconset"
for size in 16 32 128 256 512; do
  sips -z "$size" "$size" Sources/MoveBreak/Resources/MoveBreak.png --out "$iconset/icon_${size}x${size}.png" >/dev/null
  double=$((size * 2))
  sips -z "$double" "$double" Sources/MoveBreak/Resources/MoveBreak.png --out "$iconset/icon_${size}x${size}@2x.png" >/dev/null
done
iconutil -c icns "$iconset" -o "$app_dir/Contents/Resources/AppIcon.icns"
codesign --force --deep --sign - "$app_dir"
echo "Built $app_dir (local ad-hoc signature; not notarized)."
