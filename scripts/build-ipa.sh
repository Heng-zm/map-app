#!/usr/bin/env bash
#
# build-ipa.sh
# MapViewer Local & CI IPA Build Script
#
# Performs complete validation, dependency resolution, clean archive, IPA export, and inspection.
#

set -euo pipefail

SCHEME="MapViewer"
PROJECT="MapViewer.xcodeproj"
CONFIGURATION="${CONFIGURATION:-Release}"
EXPORT_METHOD="${EXPORT_METHOD:-development}" # ad-hoc, app-store, development
ARCHIVE_PATH="build/MapViewer.xcarchive"
EXPORT_PATH="build/export"
EXPORT_OPTIONS_PLIST="${EXPORT_OPTIONS_PLIST:-build/ExportOptions.plist}"
TEAM_ID="${TEAM_ID:-}"
BUNDLE_ID="com.antigravity.mapviewer"

echo "=========================================="
echo " Map Viewer — Production iOS IPA Builder"
echo "=========================================="
echo "Scheme:        ${SCHEME}"
echo "Configuration: ${CONFIGURATION}"
echo "Export Method: ${EXPORT_METHOD}"
echo "=========================================="

# 1. Environment & Xcode Validation
echo "--- 1. Validating Build Environment ---"
xcodebuild -version
swift --version

if [[ ! -d "${PROJECT}" ]]; then
    echo "❌ Error: Project ${PROJECT} not found in current directory."
    exit 1
fi

echo "Verifying available schemes in ${PROJECT}..."
xcodebuild -list -project "${PROJECT}"

# 2. Resolve SPM Dependencies
echo "--- 2. Resolving Dependencies ---"
xcodebuild -resolvePackageDependencies -project "${PROJECT}" -scheme "${SCHEME}"

# 3. Clean Build Folder
echo "--- 3. Cleaning Previous Artifacts ---"
rm -rf build/
mkdir -p build/ "${EXPORT_PATH}"
xcodebuild clean -project "${PROJECT}" -scheme "${SCHEME}" -configuration "${CONFIGURATION}"

# 4. Generate ExportOptions.plist if not provided
if [[ ! -f "${EXPORT_OPTIONS_PLIST}" ]]; then
    echo "Generating dynamic ${EXPORT_OPTIONS_PLIST} for method: ${EXPORT_METHOD}..."
    cat > "${EXPORT_OPTIONS_PLIST}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>${EXPORT_METHOD}</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
    <key>thinning</key>
    <string>&lt;none&gt;</string>
EOF
    if [[ -n "${TEAM_ID}" ]]; then
        cat >> "${EXPORT_OPTIONS_PLIST}" <<EOF
    <key>teamID</key>
    <string>${TEAM_ID}</string>
EOF
    fi
    cat >> "${EXPORT_OPTIONS_PLIST}" <<EOF
</dict>
</plist>
EOF
fi

# 5. Archive for generic iOS Device
echo "--- 4. Creating Release Device Archive ---"
BUILD_NUMBER="${GITHUB_RUN_NUMBER:-$(date +%Y%m%d%H%M)}"
HAS_SIGNING="${HAS_SIGNING:-false}"

if [[ "${HAS_SIGNING}" == "true" ]]; then
    echo "Archiving with code signing certificate..."
    xcodebuild archive \
        -project "${PROJECT}" \
        -scheme "${SCHEME}" \
        -configuration "${CONFIGURATION}" \
        -destination "generic/platform=iOS" \
        -archivePath "${ARCHIVE_PATH}" \
        CURRENT_PROJECT_VERSION="${BUILD_NUMBER}" \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES
else
    echo "Archiving with local code sign bypass..."
    xcodebuild archive \
        -project "${PROJECT}" \
        -scheme "${SCHEME}" \
        -configuration "${CONFIGURATION}" \
        -destination "generic/platform=iOS" \
        -archivePath "${ARCHIVE_PATH}" \
        CURRENT_PROJECT_VERSION="${BUILD_NUMBER}" \
        CODE_SIGNING_ALLOWED=NO \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGN_IDENTITY="" \
        SKIP_INSTALL=NO
fi

if [[ ! -d "${ARCHIVE_PATH}" ]]; then
    echo "❌ Error: Archive creation failed. ${ARCHIVE_PATH} does not exist."
    exit 1
fi
echo "✅ Archive successfully created at ${ARCHIVE_PATH}"

# 6. Export IPA
echo "--- 5. Exporting IPA ---"
if [[ "${HAS_SIGNING}" == "true" ]]; then
    echo "Exporting signed IPA with xcodebuild -exportArchive..."
    xcodebuild -exportArchive \
        -archivePath "${ARCHIVE_PATH}" \
        -exportPath "${EXPORT_PATH}" \
        -exportOptionsPlist "${EXPORT_OPTIONS_PLIST}"
else
    echo "Attempting exportArchive with local profile..."
    if ! xcodebuild -exportArchive \
        -archivePath "${ARCHIVE_PATH}" \
        -exportPath "${EXPORT_PATH}" \
        -exportOptionsPlist "${EXPORT_OPTIONS_PLIST}" 2>/dev/null; then
        echo "Packaging device .app from xcarchive into distributable .ipa container..."
        mkdir -p build/ipa_staging/Payload
        cp -R "${ARCHIVE_PATH}/Products/Applications/${SCHEME}.app" build/ipa_staging/Payload/
        (cd build/ipa_staging && zip -r -q "../export/${SCHEME}.ipa" Payload)
        rm -rf build/ipa_staging
    fi
fi

# 7. Validate Resulting IPA
echo "--- 6. Validating IPA Artifact ---"
IPA_FILE="${EXPORT_PATH}/${SCHEME}.ipa"

# If output IPA is named differently, locate any .ipa in export folder
if [[ ! -f "${IPA_FILE}" ]]; then
    FOUND_IPA=$(find "${EXPORT_PATH}" -maxdepth 1 -name "*.ipa" | head -n 1)
    if [[ -n "${FOUND_IPA}" ]]; then
        mv "${FOUND_IPA}" "${IPA_FILE}"
    fi
fi

if [[ ! -f "${IPA_FILE}" ]]; then
    echo "❌ Error: Expected IPA not found at ${IPA_FILE}"
    exit 1
fi

echo "Verifying IPA contents..."
unzip -l "${IPA_FILE}" | grep -E "Payload/${SCHEME}.app/" > /dev/null

IPA_SIZE=$(du -h "${IPA_FILE}" | cut -f1)

echo "=========================================="
echo " 🎉 Build & IPA Export Succeeded!"
echo "=========================================="
echo "App Name:          Map Viewer"
echo "Bundle ID:         ${BUNDLE_ID}"
echo "Build Number:      ${BUILD_NUMBER}"
echo "IPA Path:          ${IPA_FILE}"
echo "IPA Size:          ${IPA_SIZE}"
echo "=========================================="
