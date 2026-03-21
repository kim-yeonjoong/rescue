#!/bin/bash
# Build Rescue and run it as a proper .app bundle.
# UNUserNotificationCenter requires a bundle ID, so swift run alone won't work.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$SCRIPT_DIR/.run/Rescue.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "Building..."
cd "$SCRIPT_DIR"
swift build 2>&1

BUILD_DIR="$SCRIPT_DIR/.build/debug"

echo "Creating .app bundle..."
rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copy binary
cp "$BUILD_DIR/Rescue" "$MACOS_DIR/Rescue"

# Copy resource bundle (SVG icons, etc.)
if [ -d "$BUILD_DIR/Rescue_Rescue.bundle" ]; then
    cp -r "$BUILD_DIR/Rescue_Rescue.bundle" "$RESOURCES_DIR/"
fi

# Copy app icon
ICON_SRC="$SCRIPT_DIR/Sources/Rescue/Resources/AppIcon.icns"
if [ -f "$ICON_SRC" ]; then
    cp "$ICON_SRC" "$RESOURCES_DIR/AppIcon.icns"
fi

# Copy .lproj directories into main bundle Resources so Bundle.main can find them
for lproj_dir in "$BUILD_DIR/Rescue_Rescue.bundle"/*.lproj; do
    if [ -d "$lproj_dir" ]; then
        cp -r "$lproj_dir" "$RESOURCES_DIR/"
    fi
done

# Create Info.plist with bundle ID required for notifications
cat > "$CONTENTS_DIR/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>Rescue</string>
    <key>CFBundleIdentifier</key>
    <string>dev.rescue</string>
    <key>CFBundleName</key>
    <string>Rescue</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSUserNotificationAlertStyle</key>
    <string>alert</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
</dict>
</plist>
EOF

# Ad-hoc code sign (required for macOS to accept the .app)
codesign --force --deep --sign - "$APP_DIR"

# Kill existing instance if running
pkill -x Rescue 2>/dev/null || true
sleep 0.3

echo "Launching Rescue.app..."
open "$APP_DIR"
