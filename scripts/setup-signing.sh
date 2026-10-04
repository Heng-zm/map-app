#!/usr/bin/env bash
#
# setup-signing.sh
# MapViewer CI/CD
#
# Configures an ephemeral keychain and installs Apple code signing certificates and provisioning profiles.
#

set -euo pipefail

echo "=========================================="
echo " Setting up Apple Code Signing Environment"
echo "=========================================="

if [[ -z "${BUILD_CERTIFICATE_BASE64:-}" ]] || [[ -z "${P12_PASSWORD:-}" ]]; then
    echo "⚠️ Warning: Code signing certificate or password not provided in environment."
    echo "Skipping keychain and certificate import."
    exit 0
fi

KEYCHAIN_PATH="${RUNNER_TEMP:-/tmp}/app-signing.keychain-db"
KEYCHAIN_PWD="${KEYCHAIN_PASSWORD:-$(openssl rand -hex 16)}"

echo "Creating ephemeral keychain at ${KEYCHAIN_PATH}..."
security create-keychain -p "${KEYCHAIN_PWD}" "${KEYCHAIN_PATH}"
security set-keychain-settings -lut 21600 "${KEYCHAIN_PATH}"
security unlock-keychain -p "${KEYCHAIN_PWD}" "${KEYCHAIN_PATH}"

# Add to keychain search list
ORIGINAL_KEYCHAINS=$(security list-keychains -d user | tr -d '"' | tr '\n' ' ')
security list-keychains -d user -s "${KEYCHAIN_PATH}" ${ORIGINAL_KEYCHAINS}

CERT_TMP_PATH="${RUNNER_TEMP:-/tmp}/build_cert.p12"
echo "${BUILD_CERTIFICATE_BASE64}" | base64 --decode > "${CERT_TMP_PATH}"

echo "Importing certificate into temporary keychain..."
security import "${CERT_TMP_PATH}" \
    -k "${KEYCHAIN_PATH}" \
    -P "${P12_PASSWORD}" \
    -T /usr/bin/codesign \
    -T /usr/bin/security

rm -f "${CERT_TMP_PATH}"

# Allow codesign tool access without UI prompt
security set-key-partition-list \
    -S apple-tool:,apple:,codesign: \
    -s \
    -k "${KEYCHAIN_PWD}" \
    "${KEYCHAIN_PATH}" > /dev/null 2>&1 || true

# Install provisioning profile if present
if [[ -n "${PROVISIONING_PROFILE_BASE64:-}" ]]; then
    PROFILE_DIR="${HOME}/Library/MobileDevice/Provisioning Profiles"
    mkdir -p "${PROFILE_DIR}"
    
    PROFILE_TMP_PATH="${RUNNER_TEMP:-/tmp}/profile.mobileprovision"
    echo "${PROVISIONING_PROFILE_BASE64}" | base64 --decode > "${PROFILE_TMP_PATH}"
    
    # Extract UUID using PlistBuddy and security cms
    PROFILE_UUID=$(/usr/libexec/PlistBuddy -c "Print UUID" /dev/stdin <<< $(security cms -D -i "${PROFILE_TMP_PATH}") 2>/dev/null || echo "")
    
    if [[ -n "${PROFILE_UUID}" ]]; then
        echo "Installed Provisioning Profile UUID: ${PROFILE_UUID}"
        cp "${PROFILE_TMP_PATH}" "${PROFILE_DIR}/${PROFILE_UUID}.mobileprovision"
    else
        echo "Copying profile as default.mobileprovision..."
        cp "${PROFILE_TMP_PATH}" "${PROFILE_DIR}/default.mobileprovision"
    fi
    
    rm -f "${PROFILE_TMP_PATH}"
fi

echo "✅ Code signing environment successfully configured."
