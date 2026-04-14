#!/bin/bash
set -e

APP_NAME="GLMS"
BUNDLE="${APP_NAME}.app"

echo "Building ${APP_NAME} (release)..."
swift build -c release

echo "Creating ${BUNDLE}..."
rm -rf "${BUNDLE}"
mkdir -p "${BUNDLE}/Contents/MacOS"
mkdir -p "${BUNDLE}/Contents/Resources"

cp .build/release/GLMMonitor "${BUNDLE}/Contents/MacOS/${APP_NAME}"
cp GLMMonitor/AppIcon.icns "${BUNDLE}/Contents/Resources/AppIcon.icns"

cat > "${BUNDLE}/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>GLMS</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.leah.GLMS</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>GLMS</string>
    <key>CFBundleDisplayName</key>
    <string>GLMS</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>26.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

echo "Done! ${BUNDLE} created."
echo ""
echo "To install: cp -r ${BUNDLE} /Applications/"
echo "To run:     open ${BUNDLE}"
