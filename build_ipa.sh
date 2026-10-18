
#!/bin/bash
# Build IPA cho ShellFish Clone - chạy trên Mac có Xcode

set -e

PROJECT_NAME="ShellFishClone"
SCHEME="ShellFishClone"
ARCHIVE_PATH="./build/${PROJECT_NAME}.xcarchive"
IPA_DIR="./build/ipa"

echo "=== ShellFish Clone - Build IPA ==="
echo "1. Cleaning..."
rm -rf build
mkdir -p build

echo "2. Archiving..."
xcodebuild archive \
  -project "${PROJECT_NAME}.xcodeproj" \
  -scheme "${SCHEME}" \
  -configuration Release \
  -archivePath "${ARCHIVE_PATH}" \
  -allowProvisioningUpdates \
  CODE_SIGN_STYLE=Automatic

echo "3. Exporting IPA..."
cat > ExportOptions.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>ad-hoc</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
EOF

xcodebuild -exportArchive \
  -archivePath "${ARCHIVE_PATH}" \
  -exportPath "${IPA_DIR}" \
  -exportOptionsPlist ExportOptions.plist

echo "✅ Xong! IPA ở: ${IPA_DIR}/${PROJECT_NAME}.ipa"
echo "Cài bằng AltStore, Apple Configurator, hoặc kéo vào Finder (iPhone cắm cáp)"
